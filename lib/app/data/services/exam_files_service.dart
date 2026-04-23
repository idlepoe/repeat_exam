class ExamFilesService {
  const ExamFilesService._();

  static String examJsonAssetPath(String examType, String examSession) {
    final ymd = examSession.replaceAll('-', '');
    const rawBaseUrl =
        'https://raw.githubusercontent.com/idlepoe/repeat_exam/main/assets/json/exams';
    if (examType == '제과기능사') {
      return '$rawBaseUrl/pastry_$ymd.json';
    }
    if (examType == '제빵기능사') {
      return '$rawBaseUrl/bread_$ymd.json';
    }
    throw Exception('알 수 없는 시험 종류: $examType');
  }
}
