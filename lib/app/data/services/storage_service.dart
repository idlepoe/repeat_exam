import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ProgressData {
  const ProgressData({
    required this.examType,
    required this.examSession,
    required this.questionNumber,
  });

  final String examType;
  final String examSession;
  final int questionNumber;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'exam_type': examType,
    'exam_session': examSession,
    'question_number': questionNumber,
  };

  static ProgressData? fromJson(Map<String, dynamic> json) {
    final examType = json['exam_type'];
    final examSession = json['exam_session'];
    final questionNumber = json['question_number'];
    if (examType is! String ||
        examSession is! String ||
        questionNumber is! int) {
      return null;
    }
    return ProgressData(
      examType: examType,
      examSession: examSession,
      questionNumber: questionNumber,
    );
  }
}

class AnswerHighlight {
  const AnswerHighlight({required this.bg, required this.fg});

  final String bg;
  final String fg;

  Map<String, dynamic> toJson() => <String, dynamic>{'bg': bg, 'fg': fg};

  static AnswerHighlight fromJson(Map<String, dynamic> json) {
    final bg = json['bg'];
    final fg = json['fg'];
    return AnswerHighlight(
      bg: bg is String ? bg : '#c00',
      fg: fg is String ? fg : '#fff',
    );
  }
}

class StorageService {
  static const String _keyProgress = 'repeat_exam:progress';
  static const String _keySessionCount = 'repeat_exam:session_count';
  static const String _keyNavReversed = 'repeat_exam:nav_reversed';
  static const String _keyAnswerHighlight = 'repeat_exam:answer_highlight';

  const StorageService._();

  static String _sessionKey(String examType, String examSession) {
    return '$examType::$examSession';
  }

  static String _progressKey(String examType, String examSession) {
    return '$_keyProgress:${_sessionKey(examType, examSession)}';
  }

  static int getSessionCount(
    Map<String, int> map,
    String examType,
    String examSession,
  ) {
    return map[_sessionKey(examType, examSession)] ?? 0;
  }

  static Future<void> saveProgress(
    ProgressData p,
    String examType,
    String examSession,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _progressKey(examType, examSession),
      jsonEncode(p.toJson()),
    );
  }

  static Future<ProgressData?> loadProgress(
    String examType,
    String examSession,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _progressKey(examType, examSession);

    final raw = prefs.getString(key);
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          return ProgressData.fromJson(decoded);
        }
        if (decoded is Map) {
          return ProgressData.fromJson(Map<String, dynamic>.from(decoded));
        }
      } catch (_) {
        // ignore
      }
    }

    // legacy migration
    final legacy = prefs.getString(_keyProgress);
    if (legacy == null) return null;
    try {
      final decoded = jsonDecode(legacy);
      Map<String, dynamic>? map;
      if (decoded is Map<String, dynamic>) {
        map = decoded;
      } else if (decoded is Map) {
        map = Map<String, dynamic>.from(decoded);
      }
      if (map == null) return null;
      final migrated = ProgressData.fromJson(map);
      if (migrated == null) return null;
      if (migrated.examType == examType &&
          migrated.examSession == examSession) {
        await prefs.setString(key, jsonEncode(migrated.toJson()));
        await prefs.remove(_keyProgress);
        return migrated;
      }
    } catch (_) {
      // ignore
    }
    return null;
  }

  static Future<void> clearProgress({
    String? examType,
    String? examSession,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (examType != null && examSession != null) {
      await prefs.remove(_progressKey(examType, examSession));
      return;
    }
    await prefs.remove(_keyProgress);
    final keys = prefs
        .getKeys()
        .where((k) => k.startsWith('$_keyProgress:'))
        .toList();
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  static Future<void> clearSessionCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySessionCount);
  }

  static Future<Map<String, int>> loadSessionCountMap() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keySessionCount);
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return {};
      final out = <String, int>{};
      for (final entry in decoded.entries) {
        final key = entry.key;
        final value = entry.value;
        if (key is String && value is int) {
          out[key] = value;
        }
      }
      return out;
    } catch (_) {
      return {};
    }
  }

  static Future<void> incrementSessionCountAndClearProgress(
    String examType,
    String examSession,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final map = await loadSessionCountMap();
    final key = _sessionKey(examType, examSession);
    map[key] = (map[key] ?? 0) + 1;
    await prefs.setString(_keySessionCount, jsonEncode(map));
    await clearProgress(examType: examType, examSession: examSession);
  }

  static Future<bool> loadNavReversed() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyNavReversed);
    if (raw == '1') return true;
    if (raw == '0') return false;
    return false;
  }

  static Future<void> saveNavReversed(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyNavReversed, value ? '1' : '0');
  }

  static Future<AnswerHighlight> loadAnswerHighlight() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyAnswerHighlight);
    if (raw == null) return const AnswerHighlight(bg: '#c00', fg: '#fff');
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return AnswerHighlight.fromJson(decoded);
      }
      if (decoded is Map) {
        return AnswerHighlight.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {
      // ignore
    }
    return const AnswerHighlight(bg: '#c00', fg: '#fff');
  }

  static Future<void> saveAnswerHighlight(AnswerHighlight value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAnswerHighlight, jsonEncode(value.toJson()));
  }
}
