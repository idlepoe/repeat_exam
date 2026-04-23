import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../data/models/question_model.dart';
import '../../../data/services/exam_files_service.dart';
import '../../../data/services/exam_meta_service.dart';
import '../../../data/services/storage_service.dart';
import '../../../routes/app_pages.dart';

class QuestionController extends GetxController {
  final examType = ''.obs;
  final examSession = ''.obs;

  final questions = <QuestionModel>[].obs;
  final index = 0.obs;
  final loading = true.obs;
  final error = RxnString();
  final navReversed = false.obs;
  final fontStep = 0.obs;
  final answerHighlight = const AnswerHighlight(bg: '#c00', fg: '#fff').obs;

  static const fontSteps = <Map<String, double>>[
    {'base': 16, 'title': 15},
    {'base': 18, 'title': 16},
    {'base': 20, 'title': 17},
    {'base': 22, 'title': 18},
    {'base': 24, 'title': 20},
  ];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      if (args['examType'] is String) {
        examType.value = args['examType'] as String;
      }
      if (args['examSession'] is String) {
        examSession.value = args['examSession'] as String;
      }
    }
    _load();
  }

  QuestionModel? get currentQuestion {
    if (questions.isEmpty) return null;
    if (index.value < 0 || index.value >= questions.length) return null;
    return questions[index.value];
  }

  bool get isFirst => index.value <= 0;

  bool get isLast =>
      questions.isNotEmpty && index.value >= questions.length - 1;

  double get baseFont =>
      fontSteps[fontStep.value.clamp(0, fontSteps.length - 1)]['base']!;

  double get titleFont =>
      fontSteps[fontStep.value.clamp(0, fontSteps.length - 1)]['title']!;

  Future<void> _load() async {
    loading.value = true;
    error.value = null;
    String? sourcePath;
    try {
      navReversed.value = await StorageService.loadNavReversed();
      fontStep.value = (await StorageService.loadQuestionFontStep()).clamp(
        0,
        fontSteps.length - 1,
      );
      answerHighlight.value = await StorageService.loadAnswerHighlight();

      final sources = ExamFilesService.examJsonSources(
        examType.value,
        examSession.value,
      );
      final loadedSource = await _loadExamJsonFromSources(sources);
      sourcePath = loadedSource.source;
      final raw = loadedSource.raw;
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        throw Exception('문제 데이터 형식이 올바르지 않습니다.');
      }
      final loaded =
          decoded
              .map(
                (e) =>
                    QuestionModel.fromJson(Map<String, dynamic>.from(e as Map)),
              )
              .toList()
            ..sort((a, b) => a.question_number.compareTo(b.question_number));
      if (loaded.isEmpty) {
        throw Exception('문제 데이터가 비어 있습니다.');
      }
      questions.assignAll(loaded);

      final saved = await StorageService.loadProgress(
        examType.value,
        examSession.value,
      );
      var start = 0;
      if (saved != null &&
          saved.examType == examType.value &&
          saved.examSession == examSession.value) {
        final found = loaded.indexWhere(
          (q) => q.question_number == saved.questionNumber,
        );
        if (found >= 0) start = found;
      }
      index.value = start;
      await _saveCurrentProgress();
    } catch (e, st) {
      error.value = e.toString();
      debugPrint(
        '[QuestionController] load failed '
        '(examType=${examType.value}, examSession=${examSession.value}, '
        'source=${sourcePath ?? 'unknown'}): $e',
      );
      debugPrint(st.toString());
      questions.clear();
    } finally {
      loading.value = false;
    }
  }

  Future<({String source, String raw})> _loadExamJsonFromSources(
    List<String> sources,
  ) async {
    Object? lastError;
    for (final source in sources) {
      try {
        final res = await http.get(Uri.parse(source));
        if (res.statusCode != 200) {
          throw Exception('HTTP ${res.statusCode}');
        }
        if (res.body.trim().isEmpty) {
          throw Exception('응답 본문이 비어 있습니다.');
        }
        return (source: source, raw: res.body);
      } catch (e) {
        lastError = e;
      }
    }
    throw Exception('문제 파일 로드 실패: $lastError');
  }

  Future<void> _saveCurrentProgress() async {
    final q = currentQuestion;
    if (q == null) return;
    await StorageService.saveProgress(
      ProgressData(
        examType: examType.value,
        examSession: examSession.value,
        questionNumber: q.question_number,
      ),
      examType.value,
      examSession.value,
    );
  }

  Future<void> goPrev() async {
    if (isFirst) return;
    index.value -= 1;
    await _saveCurrentProgress();
  }

  Future<bool> goNextOrAsk() async {
    if (questions.isEmpty) return false;
    if (!isLast) {
      index.value += 1;
      await _saveCurrentProgress();
      return false;
    }
    return true;
  }

  Future<void> cycleFontStep() async {
    fontStep.value = (fontStep.value + 1) % fontSteps.length;
    await StorageService.saveQuestionFontStep(fontStep.value);
  }

  Future<void> toggleNavReversed() async {
    navReversed.value = !navReversed.value;
    await StorageService.saveNavReversed(navReversed.value);
  }

  Future<void> moveToListAfterCountIncrement() async {
    await StorageService.incrementSessionCountAndClearProgress(
      examType.value,
      examSession.value,
    );
    Get.offNamed(
      Routes.EXAM_SESSION_LIST,
      arguments: {'examType': examType.value},
    );
  }

  Future<void> moveToNextSessionAfterCountIncrement() async {
    await StorageService.incrementSessionCountAndClearProgress(
      examType.value,
      examSession.value,
    );
    final meta = await ExamMetaService.fetchExamSessionList();
    final next = ExamMetaService.nextSession(
      meta,
      examType.value,
      examSession.value,
    );
    if (next == null) {
      Get.snackbar('안내', '이어질 다음 회차가 없습니다.');
      return;
    }
    Get.offNamed(
      Routes.QUESTION,
      arguments: {'examType': examType.value, 'examSession': next},
    );
  }
}
