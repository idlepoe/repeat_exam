import 'package:get/get.dart';

import '../controllers/mock_exam_history_detail_controller.dart';

class MockExamHistoryDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MockExamHistoryDetailController>(
      () => MockExamHistoryDetailController(),
    );
  }
}
