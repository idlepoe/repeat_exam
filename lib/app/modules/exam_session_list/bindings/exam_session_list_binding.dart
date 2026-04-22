import 'package:get/get.dart';

import '../controllers/exam_session_list_controller.dart';

class ExamSessionListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExamSessionListController>(() => ExamSessionListController());
  }
}
