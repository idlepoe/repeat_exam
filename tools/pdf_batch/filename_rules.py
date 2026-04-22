from __future__ import annotations

import re
from dataclasses import dataclass

# 파일명 예: 제빵기능사20020127(교사용).pdf
RE_PDF_NAME = re.compile(
    r"^(?P<exam>제빵기능사|제과기능사)(?P<ymd>\d{8})",
)


@dataclass(frozen=True)
class PdfMeta:
    """PDF 파일명에서 유도한 시험 메타데이터."""

    exam_type: str  # 제빵기능사 | 제과기능사
    exam_session: str  # YYYY-MM-DD
    slug: str  # bread | pastry
    ymd: str  # YYYYMMDD


def ymd_to_session(ymd: str) -> str:
    if len(ymd) != 8 or not ymd.isdigit():
        raise ValueError(f"YYYYMMDD 형식이 아닙니다: {ymd!r}")
    return f"{ymd[:4]}-{ymd[4:6]}-{ymd[6:8]}"


def parse_pdf_filename(filename: str) -> PdfMeta | None:
    """
    경로 또는 파일명에서 시험 종류·날짜를 파싱합니다.
    매칭 실패 시 None.
    """
    base = filename.replace("\\", "/").split("/")[-1]
    m = RE_PDF_NAME.match(base)
    if not m:
        return None
    exam = m.group("exam")
    ymd = m.group("ymd")
    slug = "pastry" if exam == "제과기능사" else "bread"
    return PdfMeta(
        exam_type=exam,
        exam_session=ymd_to_session(ymd),
        slug=slug,
        ymd=ymd,
    )


def output_json_basename(meta: PdfMeta) -> str:
    """assets/json/exams/{slug}_{ymd}.json"""
    return f"{meta.slug}_{meta.ymd}.json"
