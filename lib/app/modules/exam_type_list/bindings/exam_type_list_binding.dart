import 'package:get/get.dart';

import '../controllers/exam_type_list_controller.dart';

class ExamTypeListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExamTypeListController>(() => ExamTypeListController());
  }
}
