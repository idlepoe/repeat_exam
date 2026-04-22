import 'package:get/get.dart';

import '../../../data/models/exam_meta_model.dart';
import '../../../data/services/exam_meta_service.dart';
import '../../../data/services/storage_service.dart';
import '../../../routes/app_pages.dart';

class ExamSessionListController extends GetxController {
  static const int totalQuestionsPerSession = 60;

  final examType = ''.obs;
  final data = Rxn<ExamSessionListModel>();
  final loading = true.obs;
  final error = RxnString();
  final sessionCountMap = <String, int>{}.obs;
  final sessionProgressMap = <String, int>{}.obs;
  final answerHighlight = const AnswerHighlight(bg: '#c00', fg: '#fff').obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['examType'] is String) {
      examType.value = args['examType'] as String;
    }
    _load();
  }

  List<String> get sessions {
    final meta = data.value;
    if (meta == null) return [];
    return ExamMetaService.sessionsForExamType(meta, examType.value);
  }

  Future<void> _load() async {
    loading.value = true;
    error.value = null;
    try {
      final meta = await ExamMetaService.fetchExamSessionList();
      final map = await StorageService.loadSessionCountMap();
      final highlight = await StorageService.loadAnswerHighlight();

      data.value = meta;
      sessionCountMap.assignAll(map);
      answerHighlight.value = highlight;

      final progressEntries = <String, int>{};
      for (final session in ExamMetaService.sessionsForExamType(
        meta,
        examType.value,
      )) {
        final saved = await StorageService.loadProgress(
          examType.value,
          session,
        );
        if (saved == null) {
          progressEntries[session] = 0;
          continue;
        }
        final solved = saved.questionNumber.clamp(0, totalQuestionsPerSession);
        final pct = ((solved / totalQuestionsPerSession) * 100).round().clamp(
          0,
          100,
        );
        progressEntries[session] = pct;
      }
      sessionProgressMap.assignAll(progressEntries);
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }

  int getSessionCount(String session) {
    return StorageService.getSessionCount(
      sessionCountMap,
      examType.value,
      session,
    );
  }

  int getSessionProgress(String session) {
    return sessionProgressMap[session] ?? 0;
  }

  Future<void> goQuestion(String session) async {
    await Get.toNamed(
      Routes.QUESTION,
      arguments: {'examType': examType.value, 'examSession': session},
    );
    await _refreshSessionMetrics(session);
  }

  Future<void> _refreshSessionMetrics(String session) async {
    final updatedMap = await StorageService.loadSessionCountMap();
    final sessionKey = '${examType.value}::$session';
    sessionCountMap[sessionKey] = updatedMap[sessionKey] ?? 0;
    sessionCountMap.refresh();

    final saved = await StorageService.loadProgress(examType.value, session);
    final solved = saved?.questionNumber.clamp(0, totalQuestionsPerSession) ?? 0;
    final pct = ((solved / totalQuestionsPerSession) * 100).round().clamp(0, 100);
    sessionProgressMap[session] = pct;
    sessionProgressMap.refresh();
  }
}
