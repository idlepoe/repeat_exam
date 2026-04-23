"""Gemini로 문제 해설(aiExplanation) 생성 후 JSON에 저장.

사용 예시:
  python scripts/generate_ai_explanations.py --input assets/json/exams/test.json
  python scripts/generate_ai_explanations.py --input assets/json/exams
"""

from __future__ import annotations

import argparse
import json
import os
import time
from pathlib import Path
from typing import Any

from google import genai
from google.genai import types

MODEL_NAME = "gemini-2.5-flash-lite"
CACHE_MIN_TOKEN_COUNT = 1024
SYSTEM_INSTRUCTION = (
    "당신은 제과·제빵 기능사 시험 전문 강사입니다. "
    "수험생이 빠르게 정답을 찾을 수 있도록 '쪽집게 해설'을 제공합니다. "
    "불필요한 설명 없이 핵심 개념, 정답 근거, 오답 비교를 명확하게 설명합니다. "
    "특히 '틀린 것은?' 문제에서는 어떤 부분이 틀렸는지 정확히 짚어야 합니다."
)


def _read_dotenv_value(env_path: Path, key: str) -> str | None:
    if not env_path.exists():
        return None
    for raw_line in env_path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        k, v = line.split("=", 1)
        if k.strip() != key:
            continue
        value = v.strip().strip('"').strip("'")
        return value or None
    return None


def _load_api_key() -> str:
    """우선순위: 환경변수 > 프로젝트 .env > 스크립트 상위 .env"""
    env_key = os.getenv("GOOGLE_API_KEY") or os.getenv("GEMINI_API_KEY")
    if env_key:
        return env_key

    cwd_env = Path.cwd() / ".env"
    script_root_env = Path(__file__).resolve().parent.parent / ".env"
    for env_path in (cwd_env, script_root_env):
        key = _read_dotenv_value(env_path, "GOOGLE_API_KEY") or _read_dotenv_value(
            env_path, "GEMINI_API_KEY"
        )
        if key:
            return key

    raise RuntimeError(
        "API 키를 찾을 수 없습니다. .env에 GOOGLE_API_KEY(또는 GEMINI_API_KEY)를 설정하세요."
    )


def _item_payload(item: dict[str, Any]) -> dict[str, Any]:
    return {
        "id": item.get("id"),
        "question_text": item.get("question_text"),
        "question_image_url": item.get("question_image_url"),
        "choices": item.get("choices", []),
        "correct_answer": item.get("correct_answer"),
    }


def _build_prompt(batch: list[dict[str, Any]]) -> str:
    payload = [_item_payload(item) for item in batch]
    return (
        "아래 문제 정보를 참고해 시험 대비용 해설을 작성해줘.\n"
        "반드시 한국어로 답변하고 JSON 형식만 반환해.\n\n"
        "여러 문제를 한 번에 보낼 수 있으므로, 반드시 id를 키로 하는 객체 형태로 반환해.\n\n"
        "작성 규칙:\n"
        "1) correctExplanation:\n"
        "- 정답(틀린 보기)이 왜 틀렸는지 정확한 개념으로 설명\n"
        "- 반드시 '무엇이 잘못된 표현인지' 지적\n"
        "- 2~3문장, 단정형 문장 사용\n\n"
        "2) wrongAnswerNotes:\n"
        "- 각 보기별로 '맞는 이유 또는 틀린 이유'를 한 문장으로 정리\n"
        "- 개념 기준으로 설명 (단순 반복 금지)\n\n"
        "3) examTip:\n"
        "- 문제 키워드만 보고 정답을 찾는 한 줄 요령\n"
        "- 암기용 문장 형태로 작성\n\n"
        "{\n"
        '  "문제ID": {\n'
        '    "correctExplanation": "...",\n'
        '    "wrongAnswerNotes": ["1번: ...", "2번: ...", "3번: ...", "4번: ..."],\n'
        '    "examTip": "..."\n'
        "  }\n"
        "}\n\n"
        "문제 메타(JSON 배열):\n"
        f"{json.dumps(payload, ensure_ascii=False, indent=2)}"
    )


def _build_cache(client: genai.Client) -> str:
    """시스템 지시/출력 규칙을 캐싱해 요청 비용을 절감한다."""
    cache_seed_text = (
        SYSTEM_INSTRUCTION
        + "\n출력은 반드시 JSON으로만 반환.\n"
        + "correctExplanation/wrongAnswerNotes/examTip 3개 키를 유지.\n"
        + "wrongAnswerNotes는 반드시 키워드 기준으로 작성. 오답 보기 번호는 포함하지 않는다."
    )
    estimated_tokens = max(1, len(cache_seed_text) // 4)
    if estimated_tokens < CACHE_MIN_TOKEN_COUNT:
        raise ValueError(
            f"cache_seed_too_small: estimated={estimated_tokens}, "
            f"required>={CACHE_MIN_TOKEN_COUNT}"
        )

    cache = client.caches.create(
        model=MODEL_NAME,
        config=types.CreateCachedContentConfig(
            display_name="repeat_exam_ai_explanation_cache",
            system_instruction=SYSTEM_INSTRUCTION,
            contents=[
                types.Content(
                    role="user",
                    parts=[types.Part.from_text(text=cache_seed_text)],
                )
            ],
            ttl="3600s",
        ),
    )
    return cache.name


def _parse_response_json(text: str) -> dict[str, Any]:
    cleaned = text.strip()
    if cleaned.startswith("```"):
        cleaned = cleaned.strip("`")
        cleaned = cleaned.replace("json", "", 1).strip()
    return json.loads(cleaned)


def _target_paths(input_path: Path) -> list[Path]:
    if input_path.is_dir():
        return sorted(input_path.glob("*.json"))
    return [input_path]


def _chunked(items: list[dict[str, Any]], size: int) -> list[list[dict[str, Any]]]:
    return [items[i : i + size] for i in range(0, len(items), size)]


def generate_ai_explanations(
    input_path: Path,
    batch_size: int,
    skip_existing: bool,
    fail_fast: bool,
) -> None:
    api_key = _load_api_key()
    client = genai.Client(api_key=api_key)
    print(
        "[설정] "
        f"model={MODEL_NAME}, batch_size={batch_size}, skip_existing={skip_existing}, "
        f"fail_fast={fail_fast}"
    )
    cache_name: str | None = None
    try:
        cache_name = _build_cache(client)
        print(f"컨텍스트 캐시 사용: {cache_name}")
    except Exception as e:
        print(f"캐시 미사용(일반 호출로 진행): {e}")

    target_paths = _target_paths(input_path)
    if not target_paths:
        raise FileNotFoundError(f"처리할 JSON 파일이 없습니다: {input_path}")

    total_files = len(target_paths)
    total_processed = 0
    total_failed_batches = 0
    for file_index, target_path in enumerate(target_paths, start=1):
        file_start = time.perf_counter()
        data = json.loads(target_path.read_text(encoding="utf-8"))
        if not isinstance(data, list):
            raise ValueError(f"입력 JSON은 문제 객체 배열이어야 합니다: {target_path}")

        print(f"\n[{file_index}/{len(target_paths)}] 파일 처리: {target_path}")
        source_items = data
        if skip_existing:
            source_items = [item for item in data if "aiExplanation" not in item]
            skipped_count = len(data) - len(source_items)
            if skipped_count:
                print(f"  - 기존 aiExplanation 스킵: {skipped_count}개")

        if not source_items:
            print("  - 처리할 신규 문항이 없어 파일 저장을 건너뜁니다.")
            continue

        batches = _chunked(source_items, batch_size)
        processed = 0
        failed_batches: list[str] = []
        for batch_index, batch in enumerate(batches, start=1):
            batch_ids = [str(item.get("id")) for item in batch]
            print(
                f"  - 배치 시작 [{batch_index}/{len(batches)}] "
                f"size={len(batch)} ids={batch_ids[0]}..{batch_ids[-1]}"
            )
            prompt = _build_prompt(batch)
            config = types.GenerateContentConfig(
                response_mime_type="application/json",
                temperature=0.3,
            )
            if cache_name:
                config.cached_content = cache_name

            batch_start = time.perf_counter()
            try:
                resp = client.models.generate_content(
                    model=MODEL_NAME,
                    contents=prompt,
                    config=config,
                )
            except Exception as e:
                print(f"배치 실패: {e}")
                msg = (
                    f"배치 실패 [{batch_index}/{len(batches)}] "
                    f"ids={batch_ids}, batch_size={len(batch)}, "
                    f"error_type={type(e).__name__}: {e}"
                )
                if fail_fast:
                    raise RuntimeError(msg) from e
                failed_batches.append(msg)
                total_failed_batches += 1
                print(f"  - {msg}")
                continue
            if not resp.text:
                raise RuntimeError(f"{target_path} 배치 응답이 비어 있습니다.")

            explanation = _parse_response_json(resp.text)
            if not isinstance(explanation, dict):
                raise RuntimeError("배치 응답 형식이 올바르지 않습니다(dict 필요).")

            for item in batch:
                item_id = str(item.get("id"))
                if item_id not in explanation:
                    raise RuntimeError(f"배치 응답에 id 누락: {item_id}")
                item["aiExplanation"] = explanation[item_id]
                processed += 1
                total_processed += 1

            print(
                f"  - 배치 [{batch_index}/{len(batches)}] 완료 "
                f"(누적 {processed}/{len(source_items)}, "
                f"소요 {time.perf_counter() - batch_start:.1f}s)"
            )

        target_path.write_text(
            json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
        )
        print(f"저장 완료: {target_path}")
        if failed_batches:
            print(f"  - 실패 배치 {len(failed_batches)}건")
            for failed in failed_batches:
                print(f"    * {failed}")
        print(
            f"[{file_index}/{total_files}] 파일 완료: {target_path} "
            f"(소요 {time.perf_counter() - file_start:.1f}s)"
        )

    print(
        f"\n전체 완료: 파일 {total_files}개, 처리 문항 {total_processed}개, "
        f"실패 배치 {total_failed_batches}건"
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--input",
        default="assets/json/exams",
        help="해설을 추가할 JSON 파일 또는 폴더 경로(폴더면 *.json 전체 처리)",
    )
    parser.add_argument(
        "--batch-size",
        type=int,
        default=1,
        help="한 번의 API 호출에 포함할 문제 수 (기본 1, 권장 5)",
    )
    parser.add_argument(
        "--skip-existing",
        action="store_true",
        help="이미 aiExplanation가 있는 문항은 API 호출 없이 건너뜁니다.",
    )
    parser.add_argument(
        "--fail-fast",
        action="store_true",
        help="배치 실패 시 즉시 중단합니다(기본은 실패 배치 건너뛰고 계속).",
    )
    args = parser.parse_args()
    if args.batch_size < 1:
        raise ValueError("--batch-size는 1 이상이어야 합니다.")
    generate_ai_explanations(
        Path(args.input),
        batch_size=args.batch_size,
        skip_existing=args.skip_existing,
        fail_fast=args.fail_fast,
    )


if __name__ == "__main__":
    main()
