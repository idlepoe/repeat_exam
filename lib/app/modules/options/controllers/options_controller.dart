import 'package:get/get.dart';

import '../../../data/question_font.dart';
import '../../../data/services/storage_service.dart';
import '../../mock_exam/controllers/mock_exam_controller.dart';
import '../../mock_exam_history_detail/controllers/mock_exam_history_detail_controller.dart';
import '../../question/controllers/question_controller.dart';

class OptionsController extends GetxController {
  final answerHighlight = const AnswerHighlight(bg: '#c00', fg: '#fff').obs;
  final bottomNavHeightStep = 0.obs;
  final questionFontStep = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadHighlight();
    _loadBottomNavHeight();
    _loadQuestionFontStep();
  }

  Future<void> _loadHighlight() async {
    answerHighlight.value = await StorageService.loadAnswerHighlight();
  }

  Future<void> _loadBottomNavHeight() async {
    bottomNavHeightStep.value =
        await StorageService.loadBottomNavHeightStep();
  }

  Future<void> _loadQuestionFontStep() async {
    questionFontStep.value = clampQuestionFontStep(
      await StorageService.loadQuestionFontStep(),
    );
  }

  Future<void> saveAnswerHighlight(AnswerHighlight value) async {
    await StorageService.saveAnswerHighlight(value);
    answerHighlight.value = value;
  }

  Future<void> setBottomNavHeightStep(int step) async {
    await StorageService.saveBottomNavHeightStep(step);
    bottomNavHeightStep.value =
        await StorageService.loadBottomNavHeightStep();
    _syncBottomNavHeightToOpenScreens(bottomNavHeightStep.value);
  }

  Future<void> setQuestionFontStep(int step) async {
    await StorageService.saveQuestionFontStep(step);
    questionFontStep.value = clampQuestionFontStep(
      await StorageService.loadQuestionFontStep(),
    );
    _syncQuestionFontStepToOpenScreens(questionFontStep.value);
  }

  void _syncBottomNavHeightToOpenScreens(int step) {
    if (Get.isRegistered<QuestionController>()) {
      Get.find<QuestionController>().bottomNavHeightStep.value = step;
    }
    if (Get.isRegistered<MockExamController>()) {
      Get.find<MockExamController>().bottomNavHeightStep.value = step;
    }
    if (Get.isRegistered<MockExamHistoryDetailController>()) {
      Get.find<MockExamHistoryDetailController>()
          .bottomNavHeightStep
          .value = step;
    }
  }

  void _syncQuestionFontStepToOpenScreens(int step) {
    if (Get.isRegistered<QuestionController>()) {
      Get.find<QuestionController>().fontStep.value = step;
    }
    if (Get.isRegistered<MockExamController>()) {
      Get.find<MockExamController>().fontStep.value = step;
    }
    if (Get.isRegistered<MockExamHistoryDetailController>()) {
      Get.find<MockExamHistoryDetailController>().fontStep.value = step;
    }
  }

  Future<void> clearAllProgress() async {
    await StorageService.clearProgress();
    await StorageService.clearSessionCount();
  }
}
