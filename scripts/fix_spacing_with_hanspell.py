# -*- coding: utf-8 -*-
"""hanspell로 exams JSON 문자열의 띄어쓰기를 교정한다.

사용 예시:
  python scripts/fix_spacing_with_hanspell.py --input assets/json/exams
  python scripts/fix_spacing_with_hanspell.py --input assets/json/exams --dry-run

사전 준비:
  pip install git+https://github.com/Seokhyeon-Park/hanspell.git
"""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Any

try:
    from hanspell import spell_checker
except ModuleNotFoundError as e:
    if e.name == "hanspell":
        raise SystemExit(
            "hanspell 모듈이 없습니다.\n"
            "다음 명령으로 설치 후 다시 실행하세요:\n"
            "  python -m pip install git+https://github.com/Seokhyeon-Park/hanspell.git"
        ) from e
    raise

ROOT = Path(__file__).resolve().parent.parent
DEFAULT_INPUT = ROOT / "assets" / "json" / "exams"
KOREAN_RE = re.compile(r"[가-힣]")
MULTISPACE_RE = re.compile(r"\s+")
_JOSA_SET = {
    "은",
    "는",
    "이",
    "가",
    "을",
    "를",
    "의",
    "에",
    "에서",
    "에게",
    "께",
    "께서",
    "한테",
    "로",
    "으로",
    "와",
    "과",
    "도",
    "만",
    "부터",
    "까지",
    "보다",
    "처럼",
    "마저",
    "조차",
}

# 도메인 용어: 보정 후에도 단어 내부가 분리되지 않도록 강제 결합
_PROTECTED_TERMS = (
    "쇼트닝",
    "크림법",
    "유지층",
    "배합율",
)

# 실데이터에서 반복되는 고정 띄어쓰기 패턴 보정
_PHRASE_FIXES = (
    ("중찜류", "중 찜류"),
    ("중제품의", "중 제품의"),
    ("토양미생 물의", "토양미생물의"),
    ("안 정제", "안정제"),
    ("진행 되는", "진행되는"),
    ("함유 하고", "함유하고"),
    ("등 의 방법", "등의 방법"),
)

# 용언 활용형 결합(빈출 패턴)
_EOMI_SUFFIXES = (
    "게",
    "고",
    "며",
    "면",
    "서",
    "나",
    "지",
    "는",
    "은",
    "ㄴ",
    "한",
    "할",
    "하도록",
)


def target_paths(input_path: Path) -> list[Path]:
    if input_path.is_file():
        return [input_path]
    if input_path.is_dir():
        return sorted(input_path.glob("*.json"))
    return []


def collect_strings(obj: Any, out: list[str]) -> None:
    if isinstance(obj, dict):
        for k, v in obj.items():
            if k == "question_text" and isinstance(v, str) and KOREAN_RE.search(v):
                out.append(v)
            else:
                collect_strings(v, out)
        return
    if isinstance(obj, list):
        for v in obj:
            collect_strings(v, out)
        return


def normalize_spaces(text: str) -> str:
    return MULTISPACE_RE.sub(" ", text).strip()


def protect_domain_terms(text: str) -> str:
    fixed = text
    for term in _PROTECTED_TERMS:
        # 예: "쇼 트 닝", "쇼 트닝", "쇼트 닝" 모두 "쇼트닝"으로 결합
        pattern = r"\s*".join(map(re.escape, list(term)))
        fixed = re.sub(pattern, term, fixed)
    return fixed


def fix_punctuation_spacing(text: str) -> str:
    fixed = text
    # 쉼표/마침표/물음표/느낌표/콜론/세미콜론 앞 공백 제거
    fixed = re.sub(r"\s+([,.;:?!])", r"\1", fixed)
    # 여는 괄호 뒤 공백 제거, 닫는 괄호 앞 공백 제거
    fixed = re.sub(r"\(\s+", "(", fixed)
    fixed = re.sub(r"\s+\)", ")", fixed)
    # 괄호 앞뒤 기본 공백 정리
    fixed = re.sub(r"\)\s*([가-힣A-Za-z0-9])", r") \1", fixed)
    return normalize_spaces(fixed)


def apply_phrase_fixes(text: str) -> str:
    fixed = text
    for old, new in _PHRASE_FIXES:
        fixed = fixed.replace(old, new)
    return fixed


def merge_eomi_like(tokens: list[str]) -> list[str]:
    """동사/형용사 활용형이 과도 분리된 경우를 보수적으로 결합."""
    if not tokens:
        return tokens
    out = [tokens[0]]
    for tok in tokens[1:]:
        prev = out[-1] if out else ""
        if (
            tok in _EOMI_SUFFIXES
            and prev
            and re.search(r"[가-힣]$", prev)
        ):
            out[-1] = f"{prev}{tok}"
        elif tok == "시킬" and prev and re.search(r"[가-힣]$", prev):
            # 증가 시킬 -> 증가시킬
            out[-1] = f"{prev}{tok}"
        else:
            out.append(tok)
    return out


def merge_josa(tokens: list[str]) -> list[str]:
    """명사/체언 + 조사 분리 케이스를 다시 결합."""
    if not tokens:
        return tokens
    out = [tokens[0]]
    for tok in tokens[1:]:
        if tok in _JOSA_SET and out:
            out[-1] = f"{out[-1]}{tok}"
        else:
            out.append(tok)
    return out


def maybe_fix_text(text: str, *, cache: dict[str, str], stats: dict[str, int]) -> str:
    if text in cache:
        return cache[text]
    if not KOREAN_RE.search(text):
        cache[text] = text
        return text
    normalized = normalize_spaces(text)
    if not normalized:
        cache[text] = text
        return text
    try:
        checked = spell_checker.check(normalized)
        # hanspell 포크별 반환형 차이를 흡수
        candidate = getattr(checked, "checked", None)
        if not isinstance(candidate, str):
            as_dict = checked.as_dict() if hasattr(checked, "as_dict") else {}
            candidate = as_dict.get("checked") if isinstance(as_dict, dict) else None
        base = candidate if isinstance(candidate, str) and candidate.strip() else normalized
    except Exception:
        stats["errors"] += 1
        base = normalized

    tokens = normalize_spaces(base).split(" ")
    tokens = merge_josa(tokens)
    tokens = merge_eomi_like(tokens)
    fixed = normalize_spaces(" ".join(tokens)) if tokens else normalized
    fixed = apply_phrase_fixes(fixed)
    fixed = protect_domain_terms(fixed)
    fixed = fix_punctuation_spacing(fixed)
    cache[text] = fixed
    return fixed


def walk(obj: Any, *, cache: dict[str, str], stats: dict[str, int]) -> Any:
    if isinstance(obj, dict):
        out: dict[str, Any] = {}
        for k, v in obj.items():
            if k == "question_text" and isinstance(v, str):
                fixed = maybe_fix_text(v, cache=cache, stats=stats)
                if fixed != v:
                    stats["changed_strings"] += 1
                out[k] = fixed
            else:
                out[k] = walk(v, cache=cache, stats=stats)
        return out
    if isinstance(obj, list):
        return [walk(v, cache=cache, stats=stats) for v in obj]
    return obj


def process_file(
    path: Path,
    *,
    dry_run: bool,
    cache: dict[str, str],
    total: dict[str, int],
) -> bool:
    raw = json.loads(path.read_text(encoding="utf-8"))
    stats = {"changed_strings": 0, "errors": 0}
    fixed = walk(raw, cache=cache, stats=stats)
    changed = fixed != raw

    total["files"] += 1
    total["changed_strings"] += stats["changed_strings"]
    total["errors"] += stats["errors"]
    if changed:
        total["changed_files"] += 1

    if changed and not dry_run:
        path.write_text(json.dumps(fixed, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    print(
        f"[{path.name}] changed={changed} "
        f"strings={stats['changed_strings']} errors={stats['errors']}"
    )
    return changed


def main() -> None:
    parser = argparse.ArgumentParser(description="hanspell로 JSON 문자열 띄어쓰기 교정")
    parser.add_argument(
        "--input",
        default=str(DEFAULT_INPUT),
        help="JSON 파일 또는 폴더(폴더면 *.json 전부)",
    )
    parser.add_argument(
        "--dry-run", action="store_true", help="저장하지 않고 변경 예상만 출력"
    )
    args = parser.parse_args()

    input_path = Path(args.input)
    paths = target_paths(input_path)
    if not paths:
        raise FileNotFoundError(f"JSON 파일을 찾지 못했습니다: {input_path}")

    cache: dict[str, str] = {}
    total = {"files": 0, "changed_files": 0, "changed_strings": 0, "errors": 0}
    for path in paths:
        process_file(path, dry_run=args.dry_run, cache=cache, total=total)

    print("\n=== Summary ===")
    print(f"files: {total['files']}")
    print(f"changed_files: {total['changed_files']}")
    print(f"changed_strings: {total['changed_strings']}")
    print(f"errors: {total['errors']}")
    print(f"cache_size: {len(cache)}")


if __name__ == "__main__":
    main()

