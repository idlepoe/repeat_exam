class ExamFilesService {
  const ExamFilesService._();

  static String examJsonAssetPath(String examType, String examSession) {
    final ymd = examSession.replaceAll('-', '');
    if (examType == '제과기능사') {
      return 'assets/json/exams/pastry_$ymd.json';
    }
    if (examType == '제빵기능사') {
      return 'assets/json/exams/bread_$ymd.json';
    }
    throw Exception('알 수 없는 시험 종류: $examType');
  }
}
