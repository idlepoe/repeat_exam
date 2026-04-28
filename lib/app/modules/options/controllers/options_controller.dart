import 'package:get/get.dart';

import '../../../data/services/storage_service.dart';

class OptionsController extends GetxController {
  final answerHighlight = const AnswerHighlight(bg: '#c00', fg: '#fff').obs;

  @override
  void onInit() {
    super.onInit();
    _loadHighlight();
  }

  Future<void> _loadHighlight() async {
    answerHighlight.value = await StorageService.loadAnswerHighlight();
  }

  Future<void> saveAnswerHighlight(AnswerHighlight value) async {
    await StorageService.saveAnswerHighlight(value);
    answerHighlight.value = value;
  }

  Future<void> clearAllProgress() async {
    await StorageService.clearProgress();
    await StorageService.clearSessionCount();
  }
}
