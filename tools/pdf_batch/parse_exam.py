from __future__ import annotations

import re
from typing import Any

from .filename_rules import PdfMeta

# 과목 구간 헤더 (PDF에 따라 추가 가능)
DEFAULT_SUBJECT_MARKERS = frozenset(
    {
        "제조이론",
        "재료과학",
        "영양학",
        "식품위생학",
        "식품위생",
        "제과이론",
        "위생학",
    }
)


def _subject_by_question_number(qnum: int) -> str | None:
    """문항 번호 기반 과목 고정 매핑."""
    if 1 <= qnum <= 20:
        return "제조이론"
    if 21 <= qnum <= 30:
        return "재료과학"
    if 31 <= qnum <= 50:
        return "영양학"
    if 51 <= qnum <= 60:
        return "식품위생학"
    return None


RE_QUESTION_HEAD = re.compile(r"^(\d{1,2})\.\s*(.*)$")
RE_CHOICE = re.compile(r"^([1-4])[\.\)]\s*(.*)$")
RE_CHOICE_CIRCLED = re.compile(r"^([①②③④❶❷❸❹])\s*(.*)$")
RE_ANSWER = re.compile(
    r"(?:정답|답|answer)\s*[:：．.]?\s*([1-4①②③④])",
    re.IGNORECASE,
)

CIRCLED_TO_NUM = {
    "①": 1,
    "②": 2,
    "③": 3,
    "④": 4,
    "❶": 1,
    "❷": 2,
    "❸": 3,
    "❹": 4,
}

RE_HEADER_NOISE_IN_QUESTION = re.compile(
    r"\s(?:\d+과목\s*:|제과기능사\s+◐|제빵기능사\s+◐|전자문제집 CBT\s*:|최강 자격증 기출문제 전자문제집 CBT\s*:).*$"
)

SAFE_JOIN_REPLACEMENTS = (
    ("아 닌", "아닌"),
    ("가 장", "가장"),
    ("알 맞", "알맞"),
    ("온 도", "온도"),
    ("습 도", "습도"),
    ("발 효", "발효"),
    ("완 료", "완료"),
    ("재 료", "재료"),
    ("반 죽", "반죽"),
    ("제 품", "제품"),
    ("원 인", "원인"),
    ("관 계", "관계"),
    ("옳 은", "옳은"),
    ("틀 린", "틀린"),
    ("적 당", "적당"),
    ("유 지", "유지"),
    ("사 용", "사용"),
    ("비 율", "비율"),
    ("부 피", "부피"),
    ("현 상", "현상"),
    ("기 준", "기준"),
    ("중 간", "중간"),
    ("수 분", "수분"),
    ("영 향", "영향"),
    ("일 반적으로", "일반적으로"),
)


def _clean_question_text(text: str) -> str:
    s = text.strip()
    s = RE_HEADER_NOISE_IN_QUESTION.sub("", s).strip()
    for old, new in SAFE_JOIN_REPLACEMENTS:
        s = s.replace(old, new)
    s = re.sub(r"\s+", " ", s).strip()
    return s


def _split_inline_choice_segments(line: str) -> list[str]:
    """
    한 줄에 여러 선지(예: "① ... ② ...", "❶ ... ❷ ...")가 붙은 경우 분해.
    """
    s = line.strip()
    marker_pat = re.compile(r"[①②③④❶❷❸❹]")
    hits = list(marker_pat.finditer(s))
    if len(hits) < 2:
        return [s]

    # 첫 마커가 줄 앞쪽에 있는 경우만 선지 줄로 간주 (문항 본문 오탐 방지)
    if hits[0].start() > 6:
        return [s]

    parts: list[str] = []
    for idx, m in enumerate(hits):
        start = m.start()
        end = hits[idx + 1].start() if idx + 1 < len(hits) else len(s)
        part = s[start:end].strip()
        if part:
            parts.append(part)
    return parts or [s]


def _normalize_lines(text: str) -> list[str]:
    text = text.replace("\r\n", "\n").replace("\r", "\n")
    lines = [ln.strip() for ln in text.split("\n")]
    out: list[str] = []
    for ln in lines:
        if not ln:
            continue
        out.extend(_split_inline_choice_segments(ln))
    return out


def _is_subject_line(line: str) -> bool | str:
    s = line.strip()
    if s in DEFAULT_SUBJECT_MARKERS:
        return s
    # 【제조이론】 등
    m = re.match(r"^[【\[]\s*(.+?)\s*[】\]]$", s)
    if m and m.group(1) in DEFAULT_SUBJECT_MARKERS:
        return m.group(1)
    #
    m2 = re.match(r"^\d+과목\s*:\s*(.+)$", s)
    if m2:
        sub = m2.group(1).strip()
        if sub in DEFAULT_SUBJECT_MARKERS:
            return sub
    return False


def _choice_line_match(line: str) -> tuple[int, str, bool] | None:
    """선지 한 줄 → (1~4, 본문, 정답표시여부) 또는 None."""
    s = line.strip()
    m = RE_CHOICE.match(s)
    if m:
        return int(m.group(1)), m.group(2).strip(), False
    m2 = RE_CHOICE_CIRCLED.match(s)
    if m2:
        ch = m2.group(1)
        idx = CIRCLED_TO_NUM[ch]
        # 검정 원문자(❶❷❸❹)는 CBT 덤프에서 정답 표시로 사용됨
        marked = ch in "❶❷❸❹"
        return idx, m2.group(2).strip(), marked
    return None


def _is_noise_line(line: str) -> bool:
    """문항/선지 파싱 시 건너뛸 헤더/푸터 라인."""
    s = line.strip()
    if not s:
        return True
    if "전자문제집 CBT" in s:
        return True
    if "기출문제" in s:
        return True
    if "◐" in s and "◑" in s:
        return True
    if s in {"[다운로드]", "PC 버전 및 모바일 버전 완벽 연동"}:
        return True
    if s.startswith(("제과기능사", "제빵기능사")):
        return True
    return False


def _extract_choice_block(
    lines: list[str], start: int, max_scan: int = 80
) -> tuple[int, int, list[dict[str, Any]], int | None] | None:
    """
    start 이후에서 1~4 선지를 추출한다.
    페이지 헤더/푸터가 중간에 끼어도 무시하며, 선지 줄바꿈도 이어붙인다.

    returns: (start_index, end_index_exclusive, choices, marked_answer)
    """
    scan_limit = min(len(lines), start + max_scan)
    i = start
    while i < scan_limit:
        first = _choice_line_match(lines[i])
        if not first or first[0] != 1:
            i += 1
            continue

        choice_start = i
        expected = 1
        j = i
        choices: list[dict[str, Any]] = []
        marked_answer: int | None = None

        while j < scan_limit and expected <= 4:
            line = lines[j]
            cm = _choice_line_match(line)
            if cm is not None:
                idx, text, marked = cm
                if idx == expected:
                    choices.append({"no": idx, "text": text})
                    if marked:
                        marked_answer = idx
                    expected += 1
                    j += 1
                    continue
                # 다른 번호가 갑자기 나오면 실패
                break

            # 선지 줄바꿈(다음 번호가 나오기 전 보조 줄)은 직전 선지에 붙인다.
            if choices and not _is_noise_line(line) and not RE_QUESTION_HEAD.match(line):
                choices[-1]["text"] = f"{choices[-1]['text']} {line.strip()}".strip()
                j += 1
                continue

            # 페이지 헤더/푸터, 과목 라인 등은 건너뛴다.
            if _is_noise_line(line) or _is_subject_line(line):
                j += 1
                continue

            # 정답표(숫자만 또는 원문자만) 구간 시작이면 중단
            if re.fullmatch(r"[1-9]\d*", line) or re.fullmatch(r"[①②③④❶❷❸❹]", line):
                break

            # 설명 불가한 라인이면 실패
            break

        if expected == 5 and len(choices) == 4:
            return choice_start, j, choices, marked_answer

        i = choice_start + 1

    return None


def _parse_answer_from_chunk(chunk: str) -> int | None:
    m = RE_ANSWER.search(chunk)
    if not m:
        return None
    g = m.group(1)
    if g in CIRCLED_TO_NUM:
        return CIRCLED_TO_NUM[g]
    try:
        v = int(g)
    except ValueError:
        return None
    if 1 <= v <= 4:
        return v
    return None


def parse_questions_from_text(
    full_text: str,
    meta: PdfMeta,
) -> tuple[list[dict[str, Any]], list[str]]:
    """
    추출 텍스트에서 Question 스키마 dict 목록과 경고 문자열을 반환합니다.
    """
    warnings: list[str] = []
    lines = _normalize_lines(full_text)

    current_subject = "기타"
    i = 0
    questions: list[dict[str, Any]] = []

    while i < len(lines):
        sub = _is_subject_line(lines[i])
        if sub:
            current_subject = sub
            i += 1
            continue

        m = RE_QUESTION_HEAD.match(lines[i])
        if not m:
            i += 1
            continue

        qnum = int(m.group(1))
        first_rest = m.group(2).strip()
        q_start = i
        body_parts: list[str] = []
        if first_rest:
            body_parts.append(first_rest)
        i += 1

        choice_block = _extract_choice_block(lines, i)
        if choice_block is None:
            warnings.append(
                f"문항 {qnum}: 선지 블록(1~4)을 찾지 못했습니다. (시작 줄 {q_start + 1})"
            )
            i += 1
            continue
        j_choice, j_after_choice, choices, marked_answer = choice_block

        for k in range(i, j_choice):
            body_parts.append(lines[k])

        question_text = " ".join(p for p in body_parts if p).strip()
        question_text = _clean_question_text(question_text)
        if not question_text:
            warnings.append(f"문항 {qnum}: 본문이 비어 있습니다.")

        if len(choices) != 4:
            i = j_choice + 1
            continue

        # 1순위: 선지의 검정 원문자(❶❷❸❹), 2순위: 정답/답 텍스트 표기
        correct = marked_answer
        if correct is None:
            chunk_end = min(len(lines), j_after_choice + 8)
            chunk = "\n".join(lines[q_start:chunk_end])
            correct = _parse_answer_from_chunk(chunk)
        if correct is None:
            warnings.append(
                f"문항 {qnum}: 정답 표기를 찾지 못했습니다. (기본값 1로 둠)"
            )
            correct = 1

        subject = _subject_by_question_number(qnum) or current_subject
        qid = f"{meta.slug}_{meta.ymd}_{qnum}"
        questions.append(
            {
                "id": qid,
                "exam_type": meta.exam_type,
                "exam_session": meta.exam_session,
                "subject": subject,
                "question_number": qnum,
                "question_text": question_text,
                "question_image_url": None,
                "choices": choices,
                "correct_answer": correct,
                "keywords": [subject],
            }
        )

        i = j_after_choice

    questions.sort(key=lambda q: int(q["question_number"]))
    return questions, warnings


def validate_questions(
    questions: list[dict[str, Any]],
    expected_count: int | None = None,
) -> list[str]:
    """번호 중복, 선지 개수, 정답 범위 검사."""
    issues: list[str] = []
    nums = [q["question_number"] for q in questions]
    if len(nums) != len(set(nums)):
        issues.append("question_number 가 중복되었습니다.")
    if expected_count is not None and len(questions) != expected_count:
        issues.append(
            f"문항 수가 {len(questions)}개입니다. (기대 {expected_count}개)"
        )
    for q in questions:
        if len(q.get("choices", [])) != 4:
            issues.append(f"id {q.get('id')}: 선지가 4개가 아닙니다.")
        ca = q.get("correct_answer")
        if ca not in (1, 2, 3, 4):
            issues.append(f"id {q.get('id')}: correct_answer 범위 오류: {ca!r}")
    return issues
