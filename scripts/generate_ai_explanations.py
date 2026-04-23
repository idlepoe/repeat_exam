"""Gemini로 문제 해설(aiExplanation) 생성 후 JSON에 저장.

사용 예시:
  python scripts/generate_ai_explanations.py --input assets/json/exams/test.json
  python scripts/generate_ai_explanations.py --input assets/json/exams
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any

from google import genai
from google.genai import types

MODEL_NAME = "gemini-flash-lite-latest"
CACHE_MIN_TOKEN_COUNT = 1024
SYSTEM_INSTRUCTION = (
    "당신은 제빵사입니다. 정답과 다른 보기에 대한 해설을 합니다. "
    "핵심과 오답노트를 알려줍니다. 문제에 무슨 단어가 있다면 정답은 무엇입니다. "
    "라는 식의 쪽집게 해설을 해줘."
)


def _build_prompt(item: dict[str, Any]) -> str:
    choices = item.get("choices", [])
    choices_text = "\n".join(
        f"- {choice.get('no')}: {choice.get('text', '')}" for choice in choices
    )
    payload = {
        "question_text": item.get("question_text"),
        "question_image_url": item.get("question_image_url"),
        "choices": choices,
        "correct_answer": item.get("correct_answer"),
    }
    return (
        "아래 문제 정보를 참고해 해설을 작성해줘.\n"
        "반드시 한국어로 답변하고 아래 JSON 형태만 반환해.\n\n"
        "{\n"
        '  "correctExplanation": "핵심 개념과 정답 근거 2~4문장",\n'
        '  "wrongAnswerNotes": ["1번 오답 이유", "2번 오답 이유", "..."],\n'
        '  "examTip": "문제 키워드로 정답 찾는 한 줄 요령"\n'
        "}\n\n"
        "문제 메타(JSON):\n"
        f"{json.dumps(payload, ensure_ascii=False, indent=2)}\n\n"
        "보기(가독성):\n"
        f"{choices_text}"
    )


def _build_cache(client: genai.Client) -> str:
    """시스템 지시/출력 규칙을 캐싱해 요청 비용을 절감한다."""
    cache_seed_text = (
        SYSTEM_INSTRUCTION
        + "\n출력은 반드시 JSON으로만 반환.\n"
        + "correctExplanation/wrongAnswerNotes/examTip 3개 키를 유지.\n"
        + "wrongAnswerNotes는 반드시 오답 보기 번호 기준으로 작성."
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


def generate_ai_explanations(input_path: Path) -> None:
    client = genai.Client()
    cache_name: str | None = None
    try:
        cache_name = _build_cache(client)
        print(f"컨텍스트 캐시 사용: {cache_name}")
    except Exception as e:
        print(f"캐시 미사용(일반 호출로 진행): {e}")

    target_paths = _target_paths(input_path)
    if not target_paths:
        raise FileNotFoundError(f"처리할 JSON 파일이 없습니다: {input_path}")

    for file_index, target_path in enumerate(target_paths, start=1):
        data = json.loads(target_path.read_text(encoding="utf-8"))
        if not isinstance(data, list):
            raise ValueError(f"입력 JSON은 문제 객체 배열이어야 합니다: {target_path}")

        print(f"\n[{file_index}/{len(target_paths)}] 파일 처리: {target_path}")
        for idx, item in enumerate(data, start=1):
            prompt = _build_prompt(item)
            config = types.GenerateContentConfig(
                response_mime_type="application/json",
                temperature=0.3,
            )
            if cache_name:
                config.cached_content = cache_name

            resp = client.models.generate_content(
                model=MODEL_NAME,
                contents=prompt,
                config=config,
            )
            if not resp.text:
                raise RuntimeError(f"{item.get('id')} 응답이 비어 있습니다.")

            explanation = _parse_response_json(resp.text)
            item["aiExplanation"] = explanation
            print(f"  - [{idx}/{len(data)}] 완료: {item.get('id')}")

        target_path.write_text(
            json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
        )
        print(f"저장 완료: {target_path}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--input",
        default="assets/json/exams",
        help="해설을 추가할 JSON 파일 또는 폴더 경로(폴더면 *.json 전체 처리)",
    )
    args = parser.parse_args()
    generate_ai_explanations(Path(args.input))


if __name__ == "__main__":
    main()
"""Gemini로 문제 해설(ai해설) 생성 후 JSON에 저장.

사용 예시:
  python scripts/generate_ai_explanations.py --input assets/json/exams/test.json
  python scripts/generate_ai_explanations.py --input assets/json/exams
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any

from google import genai
from google.genai import types

MODEL_NAME = "gemini-flash-lite-latest"
CACHE_MIN_TOKEN_COUNT = 1024
SYSTEM_INSTRUCTION = (
    "당신은 제빵사입니다. 정답과 다른 보기에 대한 해설을 합니다. "
    "핵심과 오답노트를 알려줍니다. 문제에 무슨 단어가 있다면 정답은 무엇입니다. "
    "라는 식의 쪽집게 해설을 해줘."
)


def _build_prompt(item: dict[str, Any]) -> str:
    choices = item.get("choices", [])
    choices_text = "\n".join(
        f"- {choice.get('no')}: {choice.get('text', '')}" for choice in choices
    )
    payload = {
        "question_text": item.get("question_text"),
        "question_image_url": item.get("question_image_url"),
        "choices": choices,
        "correct_answer": item.get("correct_answer"),
    }
    return (
        "아래 문제 정보를 참고해 해설을 작성해줘.\n"
        "반드시 한국어로 답변하고 아래 JSON 형태만 반환해.\n\n"
        "{\n"
        '  "correctExplanation": "핵심 개념과 정답 근거 2~4문장",\n'
        '  "wrongAnswerNotes": ["1번 오답 이유", "2번 오답 이유", "..."],\n'
        '  "examTip": "문제 키워드로 정답 찾는 한 줄 요령"\n'
        "}\n\n"
        "문제 메타(JSON):\n"
        f"{json.dumps(payload, ensure_ascii=False, indent=2)}\n\n"
        "보기(가독성):\n"
        f"{choices_text}"
    )


def _build_cache(client: genai.Client) -> str:
    """시스템 지시/출력 규칙을 캐싱해 요청 비용을 절감한다."""
    cache_seed_text = (
        SYSTEM_INSTRUCTION
        + "\n출력은 반드시 JSON으로만 반환.\n"
        + "correctExplanation/wrongAnswerNotes/examTip 3개 키를 유지.\n"
        + "wrongAnswerNotes는 반드시 오답 보기 번호 기준으로 작성."
    )
    # 캐시 API는 최소 토큰 수(현재 1024) 미만이면 INVALID_ARGUMENT를 반환한다.
    # 대략 1토큰≈4자 가정으로 사전 체크하여 불필요한 에러 로그를 줄인다.
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
                    parts=[
                        types.Part.from_text(
                            text=cache_seed_text
                        )
                    ],
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


def generate_ai_explanations(input_path: Path) -> None:
    # 사용자 예시와 동일하게 기본 Client() 경로 사용
    # (환경변수 GOOGLE_API_KEY/GEMINI_API_KEY 또는 ADC 인증을 자동 사용)
    client = genai.Client()
    cache_name: str | None = None
    try:
        cache_name = _build_cache(client)
        print(f"컨텍스트 캐시 사용: {cache_name}")
    except Exception as e:  # API 키 정책/최소 토큰 조건으로 캐시가 불가할 수 있음
        print(f"캐시 미사용(일반 호출로 진행): {e}")

    if input_path.is_dir():
        target_paths = sorted(input_path.glob("*.json"))
    else:
        target_paths = [input_path]

    if not target_paths:
        raise FileNotFoundError(f"처리할 JSON 파일이 없습니다: {input_path}")

    for file_index, target_path in enumerate(target_paths, start=1):
        data = json.loads(target_path.read_text(encoding="utf-8"))
        if not isinstance(data, list):
            raise ValueError(f"입력 JSON은 문제 객체 배열이어야 합니다: {target_path}")

        print(f"\n[{file_index}/{len(target_paths)}] 파일 처리: {target_path}")
        for idx, item in enumerate(data, start=1):
            prompt = _build_prompt(item)
            config = types.GenerateContentConfig(
                response_mime_type="application/json",
                temperature=0.3,
            )
            if cache_name:
                config.cached_content = cache_name

            resp = client.models.generate_content(
                model=MODEL_NAME,
                contents=prompt,
                config=config,
            )

            if not resp.text:
                raise RuntimeError(f"{item.get('id')} 응답이 비어 있습니다.")

            explanation = _parse_response_json(resp.text)
            # 요구사항: aiExplanation 항목 추가
            item["aiExplanation"] = explanation
            print(f"  - [{idx}/{len(data)}] 완료: {item.get('id')}")

        target_path.write_text(
            json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
        )
        print(f"저장 완료: {target_path}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--input",
        default="assets/json/exams",
        help="해설을 추가할 JSON 파일 또는 폴더 경로(폴더면 *.json 전체 처리)",
    )
    args = parser.parse_args()
    generate_ai_explanations(Path(args.input))


if __name__ == "__main__":
    main()
