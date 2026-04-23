# -*- coding: utf-8 -*-
"""시험 JSON : 숫자-단위 사이 공백 제거 및 grepText 기준 띄어쓰기 교정."""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
EXAMS = ROOT / "assets" / "json" / "exams"


def fix_text(s: str) -> str:
    if not isinstance(s, str):
        return s

    # 오타: 소수점 (유럽식 콤마를 소수점으로)
    s = s.replace("3,75", "3.75")

    # 한국어 띄어쓰기·복합어·분리 오기 (grepText.txt·시험지 문항 교차 확인)
    # 긴 구문을 앞에 두어 부분 치환 충돌 방지
    _KO_FIXES = (
        ("반죽분 할", "반죽 분할"),
        ("부적합 할 때", "부적합할 때"),
        ("현상 이다", "현상이다"),
        ("증가 할수록", "증가할수록"),
        ("부 피는", "부피는"),
        ("부 피가", "부피가"),
        ("부피 는", "부피는"),
        ("렛 다운", "렛다운"),
        (" 않 도록", " 않도록"),
        ("하기위해", "하기 위해"),
        ("것이 다.", "것이다."),
        ("환 산한", "환산한"),
        ("적은것 보", "적은 것보다"),
    )
    for old, new in _KO_FIXES:
        s = s.replace(old, new)

    # 영문 괄호 닫힘 직후 복합명사: )단계 → ) 단계
    s = re.sub(r"\)(?=단계)", ") ", s)

    # 숫자가 '및'(데이터에 쓰인 음절 U+BC0F)에 붙은 경우: …및2차 → …및 2차
    s = re.sub(r"\uBC0F(\d)(차)", r"\uBC0F \1\2", s)

    # 온도 기호 통일
    s = s.replace("\u02daC", "℃")  # ˚C
    s = s.replace("°C", "℃")

    # 숫자 범위 내 공백 축약 (∼, ~)
    for _ in range(12):
        n = re.sub(
            r"(-?\d+(?:\.\d+)?)\s*∼\s*(-?\d+(?:\.\d+)?)", r"\1∼\2", s
        )
        if n == s:
            break
        s = n
    for _ in range(12):
        n = re.sub(r"(-?\d+(?:\.\d+)?)\s*~\s*(-?\d+(?:\.\d+)?)", r"\1~\2", s)
        if n == s:
            break
        s = n

    # "~ 뒤 숫자" 잔여 공백 (예: 22~ 24℃)
    s = re.sub(r"~\s+(\d)", r"~\1", s)

    # 약 N - M g
    s = re.sub(r"약\s+(\d+)\s*-\s*(\d+)\s*g\b", r"약 \1-\2g", s)

    # 숫자 + 단위 (긴 단위 우선). g/mg 뒤에 한글 조사가 오면 \b가 실패하므로 g/mg는 \b 생략.
    subs = [
        (r"(\d+(?:\.\d+)?)\s+mesh\b", r"\1mesh"),
        (r"(\d+(?:\.\d+)?)\s+ppm", r"\1ppm"),
        (r"(\d+(?:\.\d+)?)\s+kg\b", r"\1kg"),
        (r"(\d+(?:\.\d+)?)\s+mg", r"\1mg"),
        (r"(\d+(?:\.\d+)?)\s+(Lux|lux|lx)\b", r"\1\2"),
        (r"(\d+(?:\.\d+)?)\s+(㎏|㎝|㎜|㎎)", r"\1\2"),
        (r"(\d+(?:\.\d+)?)\s+(cc)\b", r"\1\2"),
        (r"(\d+(?:\.\d+)?)\s+g", r"\1g"),
        (r"(\d+(?:\.\d+)?)\s+시간\b", r"\1시간"),
        (r"(\d+(?:\.\d+)?)\s+%", r"\1%"),
        (r"(\d+(?:\.\d+)?)\s+℃", r"\1℃"),
        (r"(\d+(?:\.\d+)?)\s+cm³", r"\1cm³"),
    ]
    for pat, repl in subs:
        s = re.sub(pat, repl, s)

    # 범위 뒤 단위 앞 공백 (33~36 ℃ 등)
    s = re.sub(r"\s+℃", "℃", s)

    return s


def walk(o):
    if isinstance(o, dict):
        return {k: walk(v) for k, v in o.items()}
    if isinstance(o, list):
        return [walk(x) for x in o]
    if isinstance(o, str):
        return fix_text(o)
    return o


def main():
    changed_files = []
    for path in sorted(EXAMS.glob("*.json")):
        with open(path, encoding="utf-8") as f:
            data = json.load(f)
        new_data = walk(data)
        if new_data != data:
            with open(path, "w", encoding="utf-8", newline="\n") as f:
                json.dump(new_data, f, ensure_ascii=False, indent=2)
            changed_files.append(path.name)
    print("Updated:", len(changed_files), "files")
    for n in changed_files:
        print(" ", n)


if __name__ == "__main__":
    main()
