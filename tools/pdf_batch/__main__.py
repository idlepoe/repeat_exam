from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

from .compare import compare_question_sets
from .extract import extract_full_text
from .filename_rules import output_json_basename, parse_pdf_filename
from .parse_exam import parse_questions_from_text, validate_questions


def _collect_pdfs(input_dir: Path, only: str | None) -> list[Path]:
    if only:
        p = Path(only)
        if not p.is_absolute():
            p = input_dir / p
        if p.is_file():
            return [p]
        # glob under input_dir
        return sorted(input_dir.glob(only))
    return sorted(input_dir.glob("*.pdf"))


def main(argv: list[str] | None = None) -> int:
    repo = Path(__file__).resolve().parents[2]
    default_in = repo / "assets" / "pdf"
    default_out = repo / "assets" / "json" / "exams"

    p = argparse.ArgumentParser(
        description="교사용 PDF 일괄 추출 → 문항 JSON (앱 스키마와 동일 형식)",
    )
    p.add_argument(
        "--input",
        type=Path,
        default=default_in,
        help=f"PDF 폴더 (기본: {default_in})",
    )
    p.add_argument(
        "--out",
        type=Path,
        default=default_out,
        help=f"JSON 출력 폴더 (기본: {default_out})",
    )
    p.add_argument(
        "--only",
        metavar="GLOB_OR_FILE",
        help="특정 파일만 (상대 경로 또는 glob, 예: 제빵기능사20020127*.pdf)",
    )
    p.add_argument(
        "--dump-text",
        type=Path,
        metavar="PATH",
        help="첫 처리 PDF의 추출 원문을 이 경로에 저장 (디버그)",
    )
    p.add_argument(
        "--expected-count",
        type=int,
        metavar="N",
        help="검증 시 기대 문항 수 (예: 60)",
    )
    p.add_argument(
        "--compare",
        type=Path,
        metavar="GOLD_JSON",
        help="지정한 단일 JSON과 문항 번호 집합 비교",
    )
    p.add_argument(
        "--reference-dir",
        type=Path,
        metavar="DIR",
        help="이 폴더에서 출력과 동일 파일명이 있으면 문항 번호 집합 비교",
    )
    p.add_argument(
        "--dry-run",
        action="store_true",
        help="JSON 파일을 쓰지 않고 콘솔만 출력",
    )

    args = p.parse_args(argv)
    input_dir = args.input.resolve()
    out_dir = args.out.resolve()

    if not input_dir.is_dir():
        print(f"입력 폴더가 없습니다: {input_dir}", file=sys.stderr)
        return 2

    pdfs = _collect_pdfs(input_dir, args.only)
    if not pdfs:
        print(f"PDF가 없습니다: {input_dir}", file=sys.stderr)
        return 1

    out_dir.mkdir(parents=True, exist_ok=True)
    dump_done = False

    for pdf_path in pdfs:
        meta = parse_pdf_filename(pdf_path.name)
        if meta is None:
            print(f"[skip] 파일명 패턴 불일치: {pdf_path.name}", file=sys.stderr)
            continue

        print(f"=== {pdf_path.name} → {output_json_basename(meta)}")

        try:
            full_text = extract_full_text(pdf_path)
        except Exception as e:
            print(f"[error] PDF 읽기 실패: {e}", file=sys.stderr)
            continue

        if args.dump_text and not dump_done:
            args.dump_text.parent.mkdir(parents=True, exist_ok=True)
            args.dump_text.write_text(full_text, encoding="utf-8")
            print(f"  (원문 덤프: {args.dump_text})")
            dump_done = True

        questions, warns = parse_questions_from_text(full_text, meta)
        for w in warns[:30]:
            print(f"  [warn] {w}")
        if len(warns) > 30:
            print(f"  ... 경고 {len(warns) - 30}건 더")

        vissues = validate_questions(questions, args.expected_count)
        for v in vissues:
            print(f"  [validate] {v}")

        out_name = output_json_basename(meta)

        if args.compare:
            cm = compare_question_sets(questions, args.compare.resolve())
            for c in cm:
                print(f"  [compare] {c}")

        if args.reference_dir:
            ref_path = args.reference_dir.resolve() / out_name
            if ref_path.is_file():
                for c in compare_question_sets(questions, ref_path):
                    print(f"  [reference] {c}")

        out_path = out_dir / out_name

        if args.dry_run:
            print(f"  [dry-run] {len(questions)}문항, 출력 생략: {out_path}")
            continue

        with out_path.open("w", encoding="utf-8") as f:
            json.dump(questions, f, ensure_ascii=False, indent=2)
            f.write("\n")
        print(f"  저장: {out_path}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
