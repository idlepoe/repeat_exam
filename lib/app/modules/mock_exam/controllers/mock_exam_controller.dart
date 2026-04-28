import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../data/models/question_model.dart';
import '../../../data/services/exam_meta_service.dart';
import '../../../data/services/storage_service.dart';
import '../../../routes/app_pages.dart';

class MockExamController extends GetxController {
  static const int mockTotal = 60;
  static const int examMs = 60 * 60 * 1000;
  static const Map<String, int> subjectQuota = {
    '제조이론': 30,
    '재료과학': 15,
    '식품위생학': 10,
    '영양학': 5,
  };

  final examKind = ''.obs;
  final loading = true.obs;
  final error = RxnString();
  final questions = <QuestionModel>[].obs;
  final index = 0.obs;
  final answers = <String, int>{}.obs;
  final startedAt = 0.obs;
  final remainMs = examMs.obs;
  final navReversed = false.obs;
  final answerHighlight = const AnswerHighlight(bg: '#c00', fg: '#fff').obs;

  final showTimeUpDialog = false.obs;
  final showEndConfirm = false.obs;
  final showAnswerSheet = false.obs;
  final showIncompleteDialog = false.obs;
  final showResultDialog = false.obs;
  final resultPassed = false.obs;
  final resultCorrect = 0.obs;
  final resultScore = 0.obs;

  Timer? _timer;
  bool _persistEnabled = true;
  Map<String, int>? _incompleteSnapshot;

  QuestionModel? get currentQuestion {
    if (questions.isEmpty) return null;
    final i = index.value;
    if (i < 0 || i >= questions.length) return null;
    return questions[i];
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['examKind'] is String) {
      examKind.value = args['examKind'] as String;
    }
    _load();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  bool get isFirst => index.value <= 0;
  bool get isLast => questions.isNotEmpty && index.value >= questions.length - 1;

  String get timeLabel {
    final ms = remainMs.value;
    final neg = ms < 0;
    final abs = ms.abs();
    final totalSec = abs ~/ 1000;
    final m = totalSec ~/ 60;
    final s = totalSec % 60;
    final ss = s.toString().padLeft(2, '0');
    return neg ? '-$m:$ss / 60:00' : '$m:$ss / 60:00';
  }

  Future<void> _load() async {
    loading.value = true;
    error.value = null;
    _persistEnabled = true;
    try {
      navReversed.value = await StorageService.loadNavReversed();
      answerHighlight.value = await StorageService.loadAnswerHighlight();
      final stored = await StorageService.loadMockSession();
      if (stored != null &&
          stored.examKind == examKind.value &&
          stored.questions.length == mockTotal) {
        questions.assignAll(stored.questions);
        answers.assignAll(stored.answers);
        index.value = stored.currentIndex.clamp(0, stored.questions.length - 1);
        startedAt.value = stored.startedAt;
      } else {
        await StorageService.clearMockSession();
        final built = await _buildMockQuestions(examKind.value);
        questions.assignAll(built);
        answers.clear();
        index.value = 0;
        startedAt.value = DateTime.now().millisecondsSinceEpoch;
        await _persistSession();
      }
      _startTimer();
    } catch (e, st) {
      error.value = e.toString();
      debugPrint('[MockExamController] load failed: $e');
      debugPrint(st.toString());
    } finally {
      loading.value = false;
    }
  }

  Future<List<QuestionModel>> _buildMockQuestions(String kind) async {
    final meta = await ExamMetaService.fetchExamSessionList();
    final row = meta.exam_session_list.where((e) => e.exam_type == kind).toList();
    if (row.isEmpty || row.first.sessions.isEmpty) {
      throw Exception('$kind 회차 정보가 없습니다.');
    }
    final sessions = [...row.first.sessions]..shuffle(Random());
    final pools = <String, List<QuestionModel>>{
      '제조이론': [],
      '재료과학': [],
      '식품위생학': [],
      '영양학': [],
    };
    for (final session in sessions) {
      try {
        final ymd = session.replaceAll('-', '');
        final prefix = kind == '제빵기능사' ? 'bread' : 'pastry';
        final raw = await rootBundle.loadString('assets/json/exams/${prefix}_$ymd.json');
        final decoded = jsonDecode(raw);
        if (decoded is! List) continue;
        for (final e in decoded) {
          if (e is! Map) continue;
          final q = QuestionModel.fromJson(Map<String, dynamic>.from(e));
          if (pools.containsKey(q.subject)) {
            pools[q.subject]!.add(q);
          }
        }
      } catch (_) {
        // ignore broken session
      }
      final enough = subjectQuota.entries.every(
        (entry) => (pools[entry.key]?.length ?? 0) >= entry.value,
      );
      if (enough) break;
    }

    final selected = <QuestionModel>[];
    for (final entry in subjectQuota.entries) {
      final pool = [...(pools[entry.key] ?? <QuestionModel>[])]..shuffle(Random());
      if (pool.length < entry.value) {
        throw Exception('${entry.key} 문제가 부족합니다.');
      }
      selected.addAll(pool.take(entry.value));
    }
    if (selected.length != mockTotal) {
      throw Exception('출제 문항 수가 60이 아닙니다.');
    }
    selected.shuffle(Random());
    return selected;
  }

  void _startTimer() {
    _timer?.cancel();
    _tickTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tickTime());
  }

  void _tickTime() {
    final left = startedAt.value + examMs - DateTime.now().millisecondsSinceEpoch;
    remainMs.value = left;
    if (left <= 0 && !showTimeUpDialog.value) {
      showTimeUpDialog.value = true;
    }
  }

  Future<void> _persistSession() async {
    if (!_persistEnabled) return;
    if (questions.length != mockTotal) return;
    await StorageService.saveMockSession(
      MockSessionData(
        examKind: examKind.value,
        questions: questions.toList(),
        answers: answers,
        currentIndex: index.value,
        startedAt: startedAt.value,
      ),
    );
  }

  Future<void> toggleNavReversed() async {
    navReversed.value = !navReversed.value;
    await StorageService.saveNavReversed(navReversed.value);
  }

  Future<void> goPrev() async {
    if (isFirst) return;
    index.value -= 1;
    await _persistSession();
  }

  Future<void> goNext() async {
    if (!isLast) {
      index.value += 1;
      await _persistSession();
      return;
    }
    _handleLastQuestionNav(answers);
  }

  Future<void> pickChoice(int choiceNo) async {
    final q = currentQuestion;
    if (q == null) return;
    final next = <String, int>{...answers, q.id: choiceNo};
    answers.assignAll(next);
    if (!isLast) {
      index.value += 1;
      await _persistSession();
      return;
    }
    _handleLastQuestionNav(next);
  }

  void _handleLastQuestionNav(Map<String, int> currentAnswers) {
    final unanswered = questions.indexWhere((q) => currentAnswers[q.id] == null);
    if (unanswered >= 0) {
      _incompleteSnapshot = currentAnswers;
      showIncompleteDialog.value = true;
      return;
    }
    finishExam(currentAnswers);
  }

  void moveToUnanswered() {
    final map = _incompleteSnapshot ?? answers;
    final ui = questions.indexWhere((q) => map[q.id] == null);
    if (ui >= 0) index.value = ui;
    showIncompleteDialog.value = false;
    _incompleteSnapshot = null;
  }

  void closeIncompleteDialog() {
    showIncompleteDialog.value = false;
    _incompleteSnapshot = null;
  }

  int _countCorrect(Map<String, int> map) {
    var n = 0;
    for (final q in questions) {
      final picked = map[q.id];
      if (picked != null && picked == q.correct_answer) n += 1;
    }
    return n;
  }

  int _scoreFloored(int correct) => (correct * 1.67).floor();

  bool _isPassed(int score) => score >= 60;

  Future<void> finishExam(Map<String, int> finalAnswers) async {
    final endedAt = DateTime.now().millisecondsSinceEpoch;
    final correct = _countCorrect(finalAnswers);
    final score = _scoreFloored(correct);
    final passed = _isPassed(score);
    _persistEnabled = false;
    await StorageService.appendMockHistory(
      MockHistoryData(
        id: '',
        examKind: examKind.value,
        startedAt: startedAt.value,
        endedAt: endedAt,
        correctCount: correct,
        totalQuestions: mockTotal,
        scoreFloored: score,
        passed: passed,
        questions: questions.toList(),
        answers: Map<String, int>.from(finalAnswers),
      ),
    );
    await StorageService.clearMockSession();
    resultPassed.value = passed;
    resultCorrect.value = correct;
    resultScore.value = score;
    showResultDialog.value = true;
  }

  Future<void> confirmEndExam() async {
    _persistEnabled = false;
    await StorageService.clearMockSession();
    showEndConfirm.value = false;
    Get.back();
  }

  void openEndConfirm() => showEndConfirm.value = true;
  void closeEndConfirm() => showEndConfirm.value = false;
  void openAnswerSheet() => showAnswerSheet.value = true;
  void closeAnswerSheet() => showAnswerSheet.value = false;
  void closeTimeUpDialog() => showTimeUpDialog.value = false;

  Future<void> jumpToQuestion(int i) async {
    if (i < 0 || i >= questions.length) return;
    index.value = i;
    showAnswerSheet.value = false;
    await _persistSession();
  }

  void closeResultAndMoveList() {
    showResultDialog.value = false;
    Get.offAllNamed(Routes.EXAM_TYPE_LIST);
  }
}
