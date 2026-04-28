import 'package:get/get.dart';

import '../controllers/mock_exam_controller.dart';

class MockExamBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MockExamController>(
      () => MockExamController(),
    );
  }
}
