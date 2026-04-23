import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../data/models/exam_meta_model.dart';
import '../../../data/services/exam_meta_service.dart';
import '../../../data/services/storage_service.dart';
import '../../../routes/app_pages.dart';

class ExamTypeListController extends GetxController {
  final data = Rxn<ExamTypeListModel>();
  final error = RxnString();
  final loading = true.obs;

  final optionsFolded = true.obs;
  final answerHighlight = const AnswerHighlight(bg: '#c00', fg: '#fff').obs;

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
      final highlight = await StorageService.loadAnswerHighlight();
      data.value = result;
      answerHighlight.value = highlight;
    } catch (e, st) {
      error.value = e.toString();
      debugPrint('[ExamTypeListController] load failed: $e');
      debugPrint(st.toString());
    } finally {
      loading.value = false;
    }
  }

  Future<void> saveAnswerHighlight(AnswerHighlight value) async {
    await StorageService.saveAnswerHighlight(value);
    answerHighlight.value = value;
  }

  Future<void> clearAllProgress() async {
    await StorageService.clearProgress();
    await StorageService.clearSessionCount();
  }

  void goSessions(String examType) {
    Get.toNamed(Routes.EXAM_SESSION_LIST, arguments: {'examType': examType});
  }
}
