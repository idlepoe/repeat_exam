#!/usr/bin/env python3
"""
assets/json/exams 아래 시험 JSON에서 각 문항의 4번 보기(no==4) text만 한 줄씩 txt로 보낸다.

사용 예:
  # 한 파일
  python scripts/extract_choice4_text.py
  python scripts/extract_choice4_text.py --json assets/json/exams/bread_20020127.json

  # 폴더 안 모든 *.json (각각 {파일명_stem}_choice4.txt 생성)
  python scripts/extract_choice4_text.py --exams-dir assets/json/exams

  # 폴더 전체를 하나의 txt로 (회차마다 === 파일명 === 구획)
  python scripts/extract_choice4_text.py --exams-dir assets/json/exams --combine out/all_choice4.txt

  # 출력만 다른 폴더에
  python scripts/extract_choice4_text.py --exams-dir assets/json/exams --output-dir out/choice4

  python scripts/extract_choice4_text.py --question 57   # 단일 파일 모드에서 문항 번호만
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path


def extract_lines(
    data: object,
    question_filter: int | None,
) -> list[str]:
    if not isinstance(data, list):
        raise ValueError("JSON 최상위는 배열이어야 합니다.")
    lines: list[str] = []
    for item in data:
        if not isinstance(item, dict):
            continue
        qn = item.get("question_number")
        if question_filter is not None and qn != question_filter:
            continue
        choices = item.get("choices")
        if not isinstance(choices, list):
            continue
        text = None
        for c in choices:
            if isinstance(c, dict) and c.get("no") == 4:
                t = c.get("text")
                if isinstance(t, str):
                    text = t
                break
        if text is None:
            continue
        lines.append(text)
    return lines


def load_choice4_lines(path: Path, question_filter: int | None) -> list[str]:
    raw = path.read_text(encoding="utf-8")
    data = json.loads(raw)
    return extract_lines(data, question_filter)


def process_one_json(
    path: Path,
    question_filter: int | None,
    output_path: Path,
) -> int:
    lines = load_choice4_lines(path, question_filter)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text("\n".join(lines) + ("\n" if lines else ""), encoding="utf-8")
    return len(lines)


def main() -> None:
    root = Path(__file__).resolve().parents[1]
    default_json = root / "assets" / "json" / "exams" / "bread_20020127.json"
    parser = argparse.ArgumentParser(description="시험 JSON에서 4번 보기 text만 txt로 추출")
    g = parser.add_mutually_exclusive_group(required=False)
    g.add_argument(
        "--json",
        type=Path,
        default=None,
        help="시험 JSON 파일 하나",
    )
    g.add_argument(
        "--exams-dir",
        type=Path,
        metavar="DIR",
        help="이 폴더의 모든 *.json 에 대해 각각 txt 생성",
    )
    parser.add_argument(
        "-o",
        "--output",
        type=Path,
        default=None,
        help="단일 파일 모드: 출력 txt 경로 (기본: 입력 옆에 {stem}_choice4.txt)",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=None,
        help="폴더 모드: txt를 이 디렉터리에 저장 (기본: 각 json과 같은 폴더). --combine 과 함께 쓸 수 없음",
    )
    parser.add_argument(
        "--combine",
        type=Path,
        default=None,
        metavar="OUT_TXT",
        help="폴더 모드: 모든 회차 4번 보기를 한 파일에 합침 (구획: === 파일명.json ===). --output-dir 과 배타",
    )
    parser.add_argument(
        "--question",
        type=int,
        default=None,
        help="특정 question_number만 추출 (미지정 시 전체 문항)",
    )
    args = parser.parse_args()

    if args.exams_dir is not None:
        exams_dir: Path = args.exams_dir
        if not exams_dir.is_dir():
            print(f"폴더 없음: {exams_dir}", file=sys.stderr)
            sys.exit(1)
        if args.combine is not None and args.output_dir is not None:
            print("--combine 과 --output-dir 은 함께 쓸 수 없습니다.", file=sys.stderr)
            sys.exit(1)
        files = sorted(exams_dir.glob("*.json"))
        if not files:
            print(f"JSON 없음: {exams_dir}", file=sys.stderr)
            sys.exit(1)

        if args.combine is not None:
            sections: list[str] = []
            total = 0
            for path in files:
                lines = load_choice4_lines(path, args.question)
                sections.append(f"=== {path.name} ===\n" + "\n".join(lines))
                total += len(lines)
                print(f"{path.name}: {len(lines)} line(s)")
            out_path = args.combine
            out_path.parent.mkdir(parents=True, exist_ok=True)
            out_path.write_text("\n\n".join(sections) + "\n", encoding="utf-8")
            print(f"Wrote 1 file -> {out_path} ({len(files)} 회차, {total} line(s) total)")
            return

        out_base = args.output_dir or exams_dir
        total = 0
        for path in files:
            out_name = f"{path.stem}_choice4.txt"
            out_path = out_base / out_name
            n = process_one_json(path, args.question, out_path)
            print(f"{path.name} -> {out_path} ({n} lines)")
            total += n
        print(f"Done: {len(files)} file(s), {total} line(s) total.")
        return

    path = args.json if args.json is not None else default_json
    if not path.is_file():
        print(f"파일 없음: {path}", file=sys.stderr)
        sys.exit(1)
    out: Path = args.output or path.with_name(f"{path.stem}_choice4.txt")
    if args.output_dir is not None or args.combine is not None:
        print("--output-dir / --combine 은 --exams-dir 과 함께만 사용할 수 있습니다.", file=sys.stderr)
        sys.exit(1)
    n = process_one_json(path, args.question, out)
    print(f"Wrote {n} line(s) -> {out}")


if __name__ == "__main__":
    main()
