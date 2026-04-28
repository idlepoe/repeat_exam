import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../data/models/exam_meta_model.dart';
import '../../../data/services/exam_meta_service.dart';
import '../../../routes/app_pages.dart';

class ExamTypeListController extends GetxController {
  final data = Rxn<ExamTypeListModel>();
  final error = RxnString();
  final loading = true.obs;

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
    } catch (e, st) {
      error.value = e.toString();
      debugPrint('[ExamTypeListController] load failed: $e');
      debugPrint(st.toString());
    } finally {
      loading.value = false;
    }
  }

  void goSessions(String examType) {
    Get.toNamed(Routes.EXAM_SESSION_LIST, arguments: {'examType': examType});
  }

  void goOptions() {
    Get.toNamed(Routes.OPTIONS);
  }
}
