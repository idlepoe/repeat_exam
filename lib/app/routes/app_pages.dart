import 'package:get/get.dart';

import '../modules/exam_session_list/bindings/exam_session_list_binding.dart';
import '../modules/exam_session_list/views/exam_session_list_view.dart';
import '../modules/exam_type_list/bindings/exam_type_list_binding.dart';
import '../modules/exam_type_list/views/exam_type_list_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/mock_exam/bindings/mock_exam_binding.dart';
import '../modules/mock_exam/views/mock_exam_view.dart';
import '../modules/mock_exam_history_detail/bindings/mock_exam_history_detail_binding.dart';
import '../modules/mock_exam_history_detail/views/mock_exam_history_detail_view.dart';
import '../modules/options/bindings/options_binding.dart';
import '../modules/options/views/options_view.dart';
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
    GetPage(
      name: _Paths.OPTIONS,
      page: () => const OptionsView(),
      binding: OptionsBinding(),
    ),
    GetPage(
      name: _Paths.MOCK_EXAM,
      page: () => const MockExamView(),
      binding: MockExamBinding(),
    ),
    GetPage(
      name: _Paths.MOCK_EXAM_HISTORY_DETAIL,
      page: () => const MockExamHistoryDetailView(),
      binding: MockExamHistoryDetailBinding(),
    ),
  ];
}
