import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/exam_meta_model.dart';

class ExamMetaService {
  const ExamMetaService._();

  static Future<ExamTypeListModel> fetchExamTypeList() async {
    final raw = await rootBundle.loadString('assets/json/exam_type_list.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return ExamTypeListModel.fromJson(json);
  }

  static Future<ExamSessionListModel> fetchExamSessionList() async {
    final raw = await rootBundle.loadString(
      'assets/json/exam_session_list.json',
    );
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return ExamSessionListModel.fromJson(json);
  }

  static List<String> sessionsForExamType(
    ExamSessionListModel data,
    String examType,
  ) {
    final row = data.exam_session_list.where((e) => e.exam_type == examType);
    if (row.isEmpty) return [];
    final out = [...row.first.sessions];
    out.sort();
    return out;
  }

  static String? nextSession(
    ExamSessionListModel data,
    String examType,
    String currentSession,
  ) {
    final sessions = sessionsForExamType(data, examType);
    final i = sessions.indexOf(currentSession);
    if (i < 0 || i >= sessions.length - 1) return null;
    return sessions[i + 1];
  }
}
