import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bottom_nav_height.dart';
import '../models/question_model.dart';

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

typedef MockAnswers = Map<String, int>;

class MockSessionData {
  const MockSessionData({
    required this.examKind,
    required this.questions,
    required this.answers,
    required this.currentIndex,
    required this.startedAt,
  });

  final String examKind;
  final List<QuestionModel> questions;
  final MockAnswers answers;
  final int currentIndex;
  final int startedAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'examKind': examKind,
    'questions': questions.map((e) => e.toJson()).toList(),
    'answers': answers,
    'currentIndex': currentIndex,
    'startedAt': startedAt,
  };

  static MockSessionData? fromJson(Map<String, dynamic> json) {
    final examKind = json['examKind'];
    final questionsRaw = json['questions'];
    final answersRaw = json['answers'];
    final currentIndex = json['currentIndex'];
    final startedAt = json['startedAt'];
    if (examKind is! String ||
        questionsRaw is! List ||
        answersRaw is! Map ||
        currentIndex is! int ||
        startedAt is! int) {
      return null;
    }
    final questions = <QuestionModel>[];
    for (final e in questionsRaw) {
      if (e is! Map) continue;
      try {
        questions.add(QuestionModel.fromJson(Map<String, dynamic>.from(e)));
      } catch (_) {
        // ignore bad item
      }
    }
    final answers = _toIntMap(answersRaw);
    return MockSessionData(
      examKind: examKind,
      questions: questions,
      answers: answers,
      currentIndex: currentIndex,
      startedAt: startedAt,
    );
  }
}

class MockHistoryData {
  const MockHistoryData({
    required this.id,
    required this.examKind,
    required this.startedAt,
    required this.endedAt,
    required this.correctCount,
    required this.totalQuestions,
    required this.scoreFloored,
    required this.passed,
    this.questions,
    this.answers,
  });

  final String id;
  final String examKind;
  final int startedAt;
  final int endedAt;
  final int correctCount;
  final int totalQuestions;
  final int scoreFloored;
  final bool passed;
  final List<QuestionModel>? questions;
  final MockAnswers? answers;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'examKind': examKind,
    'startedAt': startedAt,
    'endedAt': endedAt,
    'correctCount': correctCount,
    'totalQuestions': totalQuestions,
    'scoreFloored': scoreFloored,
    'passed': passed,
    if (questions != null) 'questions': questions!.map((e) => e.toJson()).toList(),
    if (answers != null) 'answers': answers,
  };

  static MockHistoryData? fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final examKind = json['examKind'];
    final startedAt = json['startedAt'];
    final endedAt = json['endedAt'];
    final correctCount = json['correctCount'];
    final totalQuestions = json['totalQuestions'];
    final scoreFloored = json['scoreFloored'];
    final passed = json['passed'];
    if (id is! String ||
        examKind is! String ||
        startedAt is! int ||
        endedAt is! int ||
        correctCount is! int ||
        totalQuestions is! int ||
        scoreFloored is! int ||
        passed is! bool) {
      return null;
    }
    final questionsRaw = json['questions'];
    List<QuestionModel>? questions;
    if (questionsRaw is List) {
      questions = <QuestionModel>[];
      for (final e in questionsRaw) {
        if (e is! Map) continue;
        try {
          questions.add(QuestionModel.fromJson(Map<String, dynamic>.from(e)));
        } catch (_) {
          // ignore bad item
        }
      }
    }
    final answersRaw = json['answers'];
    final answers = answersRaw is Map ? _toIntMap(answersRaw) : null;
    return MockHistoryData(
      id: id,
      examKind: examKind,
      startedAt: startedAt,
      endedAt: endedAt,
      correctCount: correctCount,
      totalQuestions: totalQuestions,
      scoreFloored: scoreFloored,
      passed: passed,
      questions: questions,
      answers: answers,
    );
  }
}

bool hasMockHistoryDetailPayload(MockHistoryData row) {
  return row.questions != null &&
      row.questions!.isNotEmpty &&
      row.answers != null &&
      row.answers!.isNotEmpty;
}

class StorageService {
  static const String _keyProgress = 'repeat_exam:progress';
  static const String _keySessionCount = 'repeat_exam:session_count';
  static const String _keyNavReversed = 'repeat_exam:nav_reversed';
  static const String _keyAnswerHighlight = 'repeat_exam:answer_highlight';
  static const String _keyQuestionFontStep = 'repeat_exam:question_font_step';
  static const String _keyBottomNavHeightStep =
      'repeat_exam:bottom_nav_height_step';
  static const String _keyMockSession = 'repeat_exam:mock_session';
  static const String _keyMockHistory = 'repeat_exam:mock_history';

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

  static Future<int> loadQuestionFontStep() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyQuestionFontStep) ?? 0;
  }

  static Future<void> saveQuestionFontStep(int step) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyQuestionFontStep, step);
  }

  static Future<int> loadBottomNavHeightStep() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getInt(_keyBottomNavHeightStep);
    if (raw != null &&
        raw >= 0 &&
        raw <= kBottomNavHeightMaxStep) {
      return raw;
    }
    return 0;
  }

  static Future<void> saveBottomNavHeightStep(int step) async {
    final prefs = await SharedPreferences.getInstance();
    final safe = step.clamp(0, kBottomNavHeightMaxStep);
    await prefs.setInt(_keyBottomNavHeightStep, safe);
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

  static Future<void> saveMockSession(MockSessionData state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMockSession, jsonEncode(state.toJson()));
    if (kDebugMode) {
      final aiCount = state.questions.where((q) => q.aiExplanation != null).length;
      debugPrint(
        '[MockExam] saveMockSession '
        '(kind=${state.examKind}, questions=${state.questions.length}, ai=$aiCount)',
      );
    }
  }

  static Future<MockSessionData?> loadMockSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyMockSession);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return MockSessionData.fromJson(decoded);
      }
      if (decoded is Map) {
        return MockSessionData.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {
      // ignore
    }
    return null;
  }

  static Future<void> clearMockSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyMockSession);
  }

  static Future<void> appendMockHistory(MockHistoryData entry) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await loadMockHistory();
    final id =
        '${entry.endedAt}_${DateTime.now().microsecondsSinceEpoch.toString().substring(8)}';
    final withId = MockHistoryData(
      id: id,
      examKind: entry.examKind,
      startedAt: entry.startedAt,
      endedAt: entry.endedAt,
      correctCount: entry.correctCount,
      totalQuestions: entry.totalQuestions,
      scoreFloored: entry.scoreFloored,
      passed: entry.passed,
      questions: entry.questions,
      answers: entry.answers,
    );
    final next = [withId, ...list].take(50).toList();
    await prefs.setString(
      _keyMockHistory,
      jsonEncode(next.map((e) => e.toJson()).toList()),
    );
  }

  static Future<List<MockHistoryData>> loadMockHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyMockHistory);
    if (raw == null) return <MockHistoryData>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <MockHistoryData>[];
      final out = <MockHistoryData>[];
      for (final e in decoded) {
        if (e is! Map) continue;
        final parsed = MockHistoryData.fromJson(Map<String, dynamic>.from(e));
        if (parsed != null) out.add(parsed);
      }
      return out;
    } catch (_) {
      return <MockHistoryData>[];
    }
  }

  static Future<void> clearMockHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyMockHistory);
  }
}

Map<String, int> _toIntMap(Map raw) {
  final out = <String, int>{};
  for (final entry in raw.entries) {
    final key = entry.key;
    final value = entry.value;
    if (key is String && value is int) {
      out[key] = value;
    }
  }
  return out;
}
