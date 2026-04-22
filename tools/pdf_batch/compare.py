from __future__ import annotations

import json
from pathlib import Path
from typing import Any


def compare_question_sets(
    parsed: list[dict[str, Any]],
    gold_path: str | Path,
) -> list[str]:
    """
    기존 JSON과 문항 수·question_number 집합을 비교합니다.
    """
    path = Path(gold_path)
    if not path.is_file():
        return [f"비교 파일이 없습니다: {path}"]

    with path.open(encoding="utf-8") as f:
        gold = json.load(f)
    if not isinstance(gold, list):
        return ["기존 JSON이 배열이 아닙니다."]

    gn = {int(q["question_number"]) for q in gold}
    pn = {int(q["question_number"]) for q in parsed}
    msgs: list[str] = []
    if len(gold) != len(parsed):
        msgs.append(
            f"문항 수: 추출 {len(parsed)}개 vs 기존 {len(gold)}개"
        )
    only_p = sorted(pn - gn)
    only_g = sorted(gn - pn)
    if only_p:
        msgs.append(f"추출에만 있는 번호: {only_p[:20]}{'...' if len(only_p) > 20 else ''}")
    if only_g:
        msgs.append(f"기존에만 있는 번호: {only_g[:20]}{'...' if len(only_g) > 20 else ''}")
    return msgs
