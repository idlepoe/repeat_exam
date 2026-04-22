"""휴리스틱 파서 최소 샘플: python -m unittest tools.pdf_batch.test_parse"""

from __future__ import annotations

import unittest

from .filename_rules import parse_pdf_filename
from .parse_exam import parse_questions_from_text


class TestParseMinimal(unittest.TestCase):
    def test_two_questions(self) -> None:
        meta = parse_pdf_filename("제빵기능사20020127(교사용).pdf")
        self.assertIsNotNone(meta)
        assert meta is not None

        text = """
제조이론
1. 첫 번째 질문 본문입니다.
1. 선지A
2. 선지B
3. 선지C
4. 선지D
정답: 3

2. 두 번째 질문?
1. 가
2. 나
3. 다
4. 라
답: 1
"""
        qs, warns = parse_questions_from_text(text, meta)
        self.assertEqual(len(qs), 2)
        self.assertEqual(qs[0]["question_number"], 1)
        self.assertEqual(qs[0]["correct_answer"], 3)
        self.assertEqual(len(qs[0]["choices"]), 4)
        self.assertEqual(qs[1]["correct_answer"], 1)
        self.assertEqual(qs[0]["subject"], "제조이론")


if __name__ == "__main__":
    unittest.main()
