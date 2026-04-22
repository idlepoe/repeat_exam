from __future__ import annotations

from pathlib import Path


def extract_pages_text(pdf_path: str | Path) -> list[str]:
    """페이지별 순서대로 일반 텍스트를 추출합니다."""
    import fitz  # pymupdf

    path = Path(pdf_path)
    doc = fitz.open(path)
    try:
        return [doc[i].get_text() for i in range(len(doc))]
    finally:
        doc.close()


def extract_full_text(pdf_path: str | Path) -> str:
    """전체 PDF를 하나의 문자열로 이어 붙입니다 (페이지 구분은 \\n\\n)."""
    pages = extract_pages_text(pdf_path)
    return "\n\n".join(pages)


def extract_blocks_debug(pdf_path: str | Path) -> list[list[tuple]]:
    """
    디버그용: 페이지별 텍스트 블록 (bbox, text, ...).
    """
    import fitz

    path = Path(pdf_path)
    doc = fitz.open(path)
    try:
        out: list[list[tuple]] = []
        for i in range(len(doc)):
            out.append(doc[i].get_text("blocks"))
        return out
    finally:
        doc.close()
