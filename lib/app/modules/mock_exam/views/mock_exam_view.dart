import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/bottom_nav_height.dart';
import '../../../widgets/bottom_nav_buttons.dart';
import '../controllers/mock_exam_controller.dart';

class MockExamView extends GetView<MockExamController> {
  const MockExamView({super.key});

  Color _hexToColor(String hex) {
    final normalized = hex.replaceFirst('#', '');
    if (normalized.length == 3) {
      final expanded = normalized
          .split('')
          .map((e) => '$e$e')
          .join()
          .toUpperCase();
      return Color(int.parse('FF$expanded', radix: 16));
    }
    if (normalized.length == 6) {
      return Color(int.parse('FF$normalized', radix: 16));
    }
    return const Color(0xFFCC0000);
  }

  Future<void> _showEndConfirm() async {
    await Get.dialog<void>(
      AlertDialog(
        title: const Text('모의고사 종료'),
        content: const Text('모의고사를 종료하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: controller.closeEndConfirm,
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: controller.confirmEndExam,
            child: const Text('확인'),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Obx(() {
        final q = controller.currentQuestion;
        if (controller.loading.value ||
            controller.error.value != null ||
            q == null) {
          return const SizedBox.shrink();
        }
        final bottomPreset = bottomNavHeightPresetForStep(
          controller.bottomNavHeightStep.value,
        );
        return BottomNavButtons(
          navReversed: controller.navReversed.value,
          prevDisabled: controller.isFirst,
          onPrev: controller.goPrev,
          onNext: controller.goNext,
          onToggleOrder: controller.toggleNavReversed,
          verticalPadding: bottomPreset.verticalPadding.toDouble(),
          fontSize: bottomPreset.fontSize.toDouble(),
        );
      }),
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          if (controller.loading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          final err = controller.error.value;
          if (err != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(err, style: const TextStyle(color: Colors.red)),
              ),
            );
          }
          final q = controller.currentQuestion;
          if (q == null) return const Center(child: Text('모의고사 준비 중…'));
          final highlight = controller.answerHighlight.value;
          final answerBg = _hexToColor(highlight.bg);
          final answerFg = _hexToColor(highlight.fg);

          return Stack(
            children: [
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFE5E4E7)),
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Row(
                        children: [
                          OutlinedButton(
                            onPressed: () => Get.back(),
                            child: const Text('뒤로가기'),
                          ),
                          Expanded(
                            child: Text(
                              controller.timeLabel,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          OutlinedButton(
                            onPressed: _showEndConfirm,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFB00020),
                            ),
                            child: const Text('시험종료'),
                          ),
                          const SizedBox(width: 6),
                          OutlinedButton(
                            onPressed: controller.openAnswerSheet,
                            child: const Text('답안확인'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      key: ValueKey('${q.id}_${controller.index.value}'),
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                      children: [
                        Text(
                          '[${q.subject}] ${controller.index.value + 1}/${MockExamController.mockTotal}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: Color(0xFF111111),
                            ),
                            children: [
                              TextSpan(
                                text: '${controller.index.value + 1}. ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(text: q.question_text),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (q.question_image_url != null &&
                            q.question_image_url!.trim().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Image.network(q.question_image_url!),
                          ),
                        ...q.choices.map((c) {
                          final picked = controller.answers[q.id];
                          final isSel = picked == c.no;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: FilledButton.tonal(
                              onPressed: () => controller.pickChoice(c.no),
                              style: FilledButton.styleFrom(
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                backgroundColor: isSel
                                    ? answerBg
                                    : const Color(0xFFFAFAFA),
                                foregroundColor: isSel
                                    ? answerFg
                                    : const Color(0xFF111111),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: Text(
                                '${c.no}. ${c.text}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
              if (controller.showTimeUpDialog.value)
                _simpleDialog(
                  title: '안내',
                  message: '시험 시간(60분)이 지났습니다.',
                  onConfirm: controller.closeTimeUpDialog,
                ),
              if (controller.showIncompleteDialog.value)
                _dualDialog(
                  title: '안내',
                  message: '풀지 않은 문제가 있습니다. 이동하시겠습니까?',
                  primaryLabel: '해당 문제로 이동',
                  onPrimary: controller.moveToUnanswered,
                  secondaryLabel: '닫기',
                  onSecondary: controller.closeIncompleteDialog,
                ),
              if (controller.showResultDialog.value)
                _simpleDialog(
                  title: '결과',
                  message:
                      '${controller.resultPassed.value ? '합격' : '불합격'}하셨습니다.\n${controller.resultCorrect.value}/${MockExamController.mockTotal}\n점수 ${controller.resultScore.value}',
                  onConfirm: controller.closeResultAndMoveList,
                ),
              if (controller.showAnswerSheet.value)
                _AnswerSheetOverlay(controller: controller),
            ],
          );
        }),
      ),
    );
  }

  Widget _simpleDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    return _dialogShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
          ),
          const SizedBox(height: 12),
          Text(message),
          const SizedBox(height: 16),
          FilledButton(onPressed: onConfirm, child: const Text('확인')),
        ],
      ),
    );
  }

  Widget _dualDialog({
    required String title,
    required String message,
    required String primaryLabel,
    required VoidCallback onPrimary,
    required String secondaryLabel,
    required VoidCallback onSecondary,
  }) {
    return _dialogShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
          ),
          const SizedBox(height: 12),
          Text(message),
          const SizedBox(height: 16),
          FilledButton(onPressed: onPrimary, child: Text(primaryLabel)),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: onSecondary, child: Text(secondaryLabel)),
        ],
      ),
    );
  }

  Widget _dialogShell({required Widget child}) {
    return Positioned.fill(
      child: ColoredBox(
        color: const Color(0x73000000),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _AnswerSheetOverlay extends StatelessWidget {
  const _AnswerSheetOverlay({required this.controller});

  final MockExamController controller;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: const Color(0x73000000),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 420),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '답안 확인',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: controller.questions.length,
                    itemBuilder: (context, i) {
                      final qq = controller.questions[i];
                      final ans = controller.answers[qq.id];
                      return TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 10,
                          ),
                          alignment: Alignment.centerLeft,
                          backgroundColor: i == controller.index.value
                              ? const Color(0xFFF0F7FF)
                              : Colors.white,
                        ),
                        onPressed: () => controller.jumpToQuestion(i),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${i + 1}. ${qq.question_text}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('답안: ${ans == null ? '—' : '$ans번'}'),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: controller.closeAnswerSheet,
                  child: const Text('닫기'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
