import 'package:get/get.dart';

import '../modules/exam_session_list/bindings/exam_session_list_binding.dart';
import '../modules/exam_session_list/views/exam_session_list_view.dart';
import '../modules/exam_type_list/bindings/exam_type_list_binding.dart';
import '../modules/exam_type_list/views/exam_type_list_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/question/bindings/question_binding.dart';
import '../modules/question/views/question_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.EXAM_TYPE_LIST;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.EXAM_SESSION_LIST,
      page: () => const ExamSessionListView(),
      binding: ExamSessionListBinding(),
    ),
    GetPage(
      name: _Paths.EXAM_TYPE_LIST,
      page: () => const ExamTypeListView(),
      binding: ExamTypeListBinding(),
    ),
    GetPage(
      name: _Paths.QUESTION,
      page: () => const QuestionView(),
      binding: QuestionBinding(),
    ),
  ];
}
