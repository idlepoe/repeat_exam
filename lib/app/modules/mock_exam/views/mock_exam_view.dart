import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/bottom_nav_height.dart';
import '../../../data/question_image_url.dart';
import '../../../theme/app_colors.dart';
import '../../../routes/app_pages.dart';
import '../../../utils/keyboard_shortcuts.dart';
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
    final cs = Theme.of(context).colorScheme;

    return Obx(() {
      final blocked =
          controller.showTimeUpDialog.value ||
          controller.showIncompleteDialog.value ||
          controller.showResultDialog.value ||
          controller.showAnswerSheet.value ||
          (Get.isDialogOpen == true);

      return MockExamShortcuts(
        isBlocked: blocked,
        onDigit: controller.pickChoice,
        child: Scaffold(
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
                child: Text(err, style: TextStyle(color: cs.error)),
              ),
            );
          }
          final q = controller.currentQuestion;
          if (q == null) return const Center(child: Text('모의고사 준비 중…'));
          final highlight = controller.answerHighlight.value;
          final answerBg = _hexToColor(highlight.bg);
          final answerFg = _hexToColor(highlight.fg);
          final questionImageSrc = resolveQuestionImageSrc(q);

          return Stack(
            children: [
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: cs.outlineVariant),
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            tooltip: '뒤로가기',
                            onPressed: () => Get.back(),
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
                          IconButton(
                            icon: const Icon(Icons.stop_circle_outlined),
                            tooltip: '시험종료',
                            style: IconButton.styleFrom(
                              foregroundColor: cs.error,
                            ),
                            onPressed: _showEndConfirm,
                          ),
                          IconButton(
                            icon: const Icon(Icons.fact_check_outlined),
                            tooltip: '답안확인',
                            onPressed: controller.openAnswerSheet,
                          ),
                          IconButton(
                            icon: const Icon(Icons.settings_outlined),
                            tooltip: '옵션',
                            onPressed: () => Get.toNamed(Routes.OPTIONS),
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
                          style: TextStyle(
                            fontSize: controller.titleFont,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: controller.baseFont,
                              height: 1.5,
                              color: cs.onSurface,
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
                        if (questionImageSrc != null)
                          QuestionNetworkImage(url: questionImageSrc),
                        ...q.choices.map((c) {
                          final picked = controller.answers[q.id];
                          final isSel = picked == c.no;
                          final digitHints =
                              isDesktopShortcutsPlatform &&
                              !(controller.showTimeUpDialog.value ||
                                  controller.showIncompleteDialog.value ||
                                  controller.showResultDialog.value ||
                                  controller.showAnswerSheet.value ||
                                  (Get.isDialogOpen == true));
                          final hintColor =
                              cs.onSurface.withValues(alpha: 0.5);
                          final hintSize =
                              (controller.baseFont * 0.85).clamp(14.0, 22.0);
                          return GestureDetector(
                            onTap: () => controller.pickChoice(c.no),
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: cs.outlineVariant),
                                borderRadius: BorderRadius.circular(6),
                                color: isSel ? answerBg : cs.surface,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${c.no}. ${c.text}',
                                      style: TextStyle(
                                        color:
                                            isSel ? answerFg : cs.onSurface,
                                        fontSize: controller.baseFont,
                                      ),
                                    ),
                                  ),
                                  if (digitHints &&
                                      c.no >= 1 &&
                                      c.no <= 4) ...[
                                    SizedBox(width: controller.baseFont * 0.35),
                                    Icon(
                                      choiceDigitShortcutIcon(c.no),
                                      size: hintSize,
                                      color: hintColor,
                                    ),
                                  ],
                                ],
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
                  context: context,
                  title: '안내',
                  message: '시험 시간(60분)이 지났습니다.',
                  onConfirm: controller.closeTimeUpDialog,
                ),
              if (controller.showIncompleteDialog.value)
                _dualDialog(
                  context: context,
                  title: '안내',
                  message: '풀지 않은 문제가 있습니다. 이동하시겠습니까?',
                  primaryLabel: '해당 문제로 이동',
                  onPrimary: controller.moveToUnanswered,
                  secondaryLabel: '닫기',
                  onSecondary: controller.closeIncompleteDialog,
                ),
              if (controller.showResultDialog.value)
                _simpleDialog(
                  context: context,
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
    ),
    );
    });
  }

  Widget _simpleDialog({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    return _dialogShell(
      context: context,
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
    required BuildContext context,
    required String title,
    required String message,
    required String primaryLabel,
    required VoidCallback onPrimary,
    required String secondaryLabel,
    required VoidCallback onSecondary,
  }) {
    return _dialogShell(
      context: context,
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

  Widget _dialogShell({required BuildContext context, required Widget child}) {
    final cs = Theme.of(context).colorScheme;
    final scrim = context.appColors.scrim;
    return Positioned.fill(
      child: ColoredBox(
        color: scrim,
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: cs.surface,
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
    final cs = Theme.of(context).colorScheme;
    final scrim = context.appColors.scrim;

    return Positioned.fill(
      child: ColoredBox(
        color: scrim,
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 420),
            decoration: BoxDecoration(
              color: cs.surface,
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
                              ? cs.primaryContainer
                              : cs.surface,
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
