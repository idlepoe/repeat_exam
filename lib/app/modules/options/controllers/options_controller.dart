import 'package:flutter/material.dart';
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
  final themeMode = ThemeMode.system.obs;
  final navReversed = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadHighlight();
    _loadBottomNavHeight();
    _loadQuestionFontStep();
    _loadThemeMode();
    _loadNavReversed();
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

  Future<void> _loadThemeMode() async {
    themeMode.value = await StorageService.loadThemeMode();
  }

  Future<void> _loadNavReversed() async {
    navReversed.value = await StorageService.loadNavReversed();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await StorageService.saveThemeMode(mode);
    themeMode.value = mode;
    Get.changeThemeMode(mode);
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

  Future<void> setNavReversed(bool value) async {
    await StorageService.saveNavReversed(value);
    navReversed.value = await StorageService.loadNavReversed();
    _syncNavReversedToOpenScreens(navReversed.value);
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

  void _syncNavReversedToOpenScreens(bool value) {
    if (Get.isRegistered<QuestionController>()) {
      Get.find<QuestionController>().navReversed.value = value;
    }
    if (Get.isRegistered<MockExamController>()) {
      Get.find<MockExamController>().navReversed.value = value;
    }
    if (Get.isRegistered<MockExamHistoryDetailController>()) {
      Get.find<MockExamHistoryDetailController>().navReversed.value = value;
    }
  }

  Future<void> clearAllProgress() async {
    await StorageService.clearProgress();
    await StorageService.clearSessionCount();
  }
}
