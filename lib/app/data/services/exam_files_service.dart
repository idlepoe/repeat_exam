class ExamFilesService {
  const ExamFilesService._();

  static List<String> examJsonSources(String examType, String examSession) {
    final ymd = examSession.replaceAll('-', '');
    const remoteBaseUrl =
        'https://raw.githubusercontent.com/idlepoe/repeat_exam/main/assets/json/exams';
    if (examType == '제과기능사') {
      return ['$remoteBaseUrl/pastry_$ymd.json'];
    }
    if (examType == '제빵기능사') {
      return ['$remoteBaseUrl/bread_$ymd.json'];
    }
    throw Exception('알 수 없는 시험 종류: $examType');
  }
}
