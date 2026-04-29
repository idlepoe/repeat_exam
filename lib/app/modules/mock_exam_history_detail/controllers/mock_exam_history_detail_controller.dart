import 'package:get/get.dart';
import '../../../data/bottom_nav_height.dart';
import '../../../data/models/question_model.dart';
import '../../../data/services/storage_service.dart';

class MockExamHistoryDetailController extends GetxController {
  final historyId = ''.obs;
  final loading = true.obs;
  final error = RxnString();
  final navReversed = false.obs;
  final bottomNavHeightStep = 0.obs;
  final history = Rxn<MockHistoryData>();
  final index = 0.obs;
  final showAnswerSheet = false.obs;
  final showMoveListConfirm = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['historyId'] is String) {
      historyId.value = args['historyId'] as String;
    }
    _load();
  }

  Future<void> _load() async {
    loading.value = true;
    error.value = null;
    try {
      navReversed.value = await StorageService.loadNavReversed();
      bottomNavHeightStep.value =
          (await StorageService.loadBottomNavHeightStep()).clamp(
        0,
        kBottomNavHeightMaxStep,
      );
      final list = await StorageService.loadMockHistory();
      final found = list.where((e) => e.id == historyId.value).toList();
      if (found.isEmpty) {
        error.value = '상세 데이터를 찾을 수 없습니다.';
      } else if (!hasMockHistoryDetailPayload(found.first)) {
        error.value = '상세 데이터를 찾을 수 없습니다.';
      } else {
        history.value = found.first;
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }

  List<QuestionModel> get questions => history.value?.questions ?? <QuestionModel>[];
  Map<String, int> get answers => history.value?.answers ?? <String, int>{};
  QuestionModel? get currentQuestion {
    if (questions.isEmpty) return null;
    final i = index.value;
    if (i < 0 || i >= questions.length) return null;
    return questions[i];
  }

  bool get isFirst => index.value <= 0;
  bool get isLast => questions.isNotEmpty && index.value >= questions.length - 1;

  Future<void> toggleNavReversed() async {
    navReversed.value = !navReversed.value;
    await StorageService.saveNavReversed(navReversed.value);
  }

  void goPrev() {
    if (isFirst) return;
    index.value -= 1;
  }

  void goNext() {
    if (!isLast) {
      index.value += 1;
      return;
    }
    showMoveListConfirm.value = true;
  }

  void openAnswerSheet() => showAnswerSheet.value = true;
  void closeAnswerSheet() => showAnswerSheet.value = false;

  void jumpToQuestion(int i) {
    if (i < 0 || i >= questions.length) return;
    index.value = i;
    showAnswerSheet.value = false;
  }

  void confirmMoveList() {
    showMoveListConfirm.value = false;
    Get.offAllNamed('/exam-type-list');
  }

  void cancelMoveList() => showMoveListConfirm.value = false;

  String formatStartedAt() {
    final ts = history.value?.startedAt;
    if (ts == null) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(ts);
    String two(int v) => v.toString().padLeft(2, '0');
    return '${dt.year}.${two(dt.month)}.${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
  }
}
