import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../data/models/exam_meta_model.dart';
import '../../../data/services/exam_meta_service.dart';
import '../../../data/services/storage_service.dart';
import '../../../routes/app_pages.dart';

class ExamTypeListController extends GetxController {
  static const int mockTotal = 60;
  static const int examMs = 60 * 60 * 1000;

  final data = Rxn<ExamTypeListModel>();
  final error = RxnString();
  final loading = true.obs;
  final ongoingMock = Rxn<MockSessionData>();
  final mockHistory = <MockHistoryData>[].obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    loading.value = true;
    error.value = null;
    try {
      final result = await ExamMetaService.fetchExamTypeList();
      data.value = result;
      await refreshMockData();
    } catch (e, st) {
      error.value = e.toString();
      debugPrint('[ExamTypeListController] load failed: $e');
      debugPrint(st.toString());
    } finally {
      loading.value = false;
    }
  }

  Future<void> refreshMockData() async {
    final s = await StorageService.loadMockSession();
    if (s != null && s.questions.length == mockTotal) {
      ongoingMock.value = s;
    } else {
      ongoingMock.value = null;
    }
    final list = await StorageService.loadMockHistory();
    mockHistory.assignAll(list.where(hasMockHistoryDetailPayload));
  }

  void goSessions(String examType) {
    Get.toNamed(Routes.EXAM_SESSION_LIST, arguments: {'examType': examType});
  }

  void goOptions() {
    Get.toNamed(Routes.OPTIONS);
  }

  Future<void> goMockExam(String examKind) async {
    await Get.toNamed(Routes.MOCK_EXAM, arguments: {'examKind': examKind});
    await refreshMockData();
  }

  Future<void> continueMockExam() async {
    final s = ongoingMock.value;
    if (s == null) return;
    await goMockExam(s.examKind);
  }

  Future<void> endOngoingMock() async {
    await StorageService.clearMockSession();
    ongoingMock.value = null;
  }

  Future<void> clearMockHistory() async {
    await StorageService.clearMockHistory();
    mockHistory.clear();
  }

  Future<void> goMockHistoryDetail(String historyId) async {
    await Get.toNamed(
      Routes.MOCK_EXAM_HISTORY_DETAIL,
      arguments: {'historyId': historyId},
    );
    await refreshMockData();
  }

  String formatRemainMs() {
    final s = ongoingMock.value;
    if (s == null) return '0:00';
    final left = s.startedAt + examMs - DateTime.now().millisecondsSinceEpoch;
    final neg = left < 0;
    final abs = left.abs();
    final totalSec = abs ~/ 1000;
    final m = totalSec ~/ 60;
    final sec = (totalSec % 60).toString().padLeft(2, '0');
    return neg ? '-$m:$sec' : '$m:$sec';
  }

  String formatStartedAt(int ts) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ts);
    String two(int v) => v.toString().padLeft(2, '0');
    return '${dt.year}.${two(dt.month)}.${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
  }

  String formatElapsed(int startedAt, int endedAt) {
    final totalSec = ((endedAt - startedAt) ~/ 1000).clamp(0, 1 << 30);
    final h = totalSec ~/ 3600;
    final m = (totalSec % 3600) ~/ 60;
    final s = totalSec % 60;
    if (h > 0) return '$h시간 $m분 $s초';
    return '$m분 $s초';
  }
}
