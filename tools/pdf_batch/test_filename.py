"""파일명 파서 단위 테스트: python -m unittest tools.pdf_batch.test_filename"""

from __future__ import annotations

import unittest

from .filename_rules import (
    output_json_basename,
    parse_pdf_filename,
    ymd_to_session,
)


class TestYmd(unittest.TestCase):
    def test_session(self) -> None:
        self.assertEqual(ymd_to_session("20020127"), "2002-01-27")


class TestParsePdfFilename(unittest.TestCase):
    def test_bread(self) -> None:
        m = parse_pdf_filename("제빵기능사20020127(교사용).pdf")
        self.assertIsNotNone(m)
        assert m is not None
        self.assertEqual(m.exam_type, "제빵기능사")
        self.assertEqual(m.exam_session, "2002-01-27")
        self.assertEqual(m.slug, "bread")
        self.assertEqual(m.ymd, "20020127")
        self.assertEqual(output_json_basename(m), "bread_20020127.json")

    def test_pastry(self) -> None:
        m = parse_pdf_filename(r"C:\data\제과기능사20020407(교사용).pdf")
        self.assertIsNotNone(m)
        assert m is not None
        self.assertEqual(m.slug, "pastry")
        self.assertEqual(m.exam_session, "2002-04-07")

    def test_invalid(self) -> None:
        self.assertIsNone(parse_pdf_filename("other.pdf"))


if __name__ == "__main__":
    unittest.main()
