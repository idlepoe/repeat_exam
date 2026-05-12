#!/usr/bin/env python3
"""
assets/pdf 안의 교사용 PDF 이름을
  제빵기능사YYYYMMDD(...).pdf -> bread_YYYYMMDD.pdf
  제과기능사YYYYMMDD(...).pdf -> pastry_YYYYMMDD.pdf
로 바꾼다. (시험 JSON 파일명 접두와 동일)

  python scripts/rename_exam_pdfs.py              # 미리보기만
  python scripts/rename_exam_pdfs.py --apply       # 실제 이름 변경
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

# 예: 제빵기능사20020127(교사용).pdf
_PATTERN = re.compile(
    r"^(?P<kind>제빵기능사|제과기능사)(?P<ymd>\d{8})\([^)]*\)\.pdf$"
)


def target_name(old: str) -> str | None:
    m = _PATTERN.match(old)
    if not m:
        return None
    prefix = "bread" if m.group("kind") == "제빵기능사" else "pastry"
    return f"{prefix}_{m.group('ymd')}.pdf"


def main() -> None:
    root = Path(__file__).resolve().parents[1]
    parser = argparse.ArgumentParser(description="assets/pdf 교사용 PDF 파일명 정규화")
    parser.add_argument(
        "--pdf-dir",
        type=Path,
        default=root / "assets" / "pdf",
        help="PDF 폴더 (기본: assets/pdf)",
    )
    parser.add_argument(
        "--apply",
        action="store_true",
        help="지정 시에만 실제로 rename 수행 (미지정 시 dry-run)",
    )
    args = parser.parse_args()

    d: Path = args.pdf_dir
    if not d.is_dir():
        print(f"폴더 없음: {d}", file=sys.stderr)
        sys.exit(1)

    renames: list[tuple[Path, Path]] = []
    skipped: list[str] = []
    for p in sorted(d.iterdir()):
        if not p.is_file() or p.suffix.lower() != ".pdf":
            continue
        new = target_name(p.name)
        if new is None:
            if re.match(r"^(bread|pastry)_\d{8}\.pdf$", p.name):
                skipped.append(f"(이미 형식) {p.name}")
            else:
                skipped.append(f"(규칙 불일치) {p.name}")
            continue
        dest = p.with_name(new)
        if dest == p:
            continue
        if dest.exists() and dest.resolve() != p.resolve():
            print(f"건너뜀 (대상 이미 존재): {p.name} -> {new}", file=sys.stderr)
            continue
        renames.append((p, dest))

    for src, dst in renames:
        print(f"{src.name} -> {dst.name}")

    if skipped:
        print("\n[스킵]")
        for s in skipped:
            print(s)

    print(f"\n총 {len(renames)}개 rename" + (" 실행" if args.apply else " (dry-run, --apply 로 실행)"))

    if not args.apply:
        return

    for src, dst in renames:
        src.rename(dst)
    print("완료.")


if __name__ == "__main__":
    main()
