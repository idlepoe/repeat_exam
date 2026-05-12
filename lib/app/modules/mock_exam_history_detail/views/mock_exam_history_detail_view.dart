import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/bottom_nav_height.dart';
import '../../../data/question_image_url.dart';
import '../../../routes/app_pages.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/bottom_nav_buttons.dart';
import '../controllers/mock_exam_history_detail_controller.dart';

class MockExamHistoryDetailView
    extends GetView<MockExamHistoryDetailController> {
  const MockExamHistoryDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final app = context.appColors;

    return Obx(() {
      if (controller.loading.value) {
        return Scaffold(
          body: SafeArea(
            child: const Center(child: CircularProgressIndicator()),
          ),
        );
      }
      final err = controller.error.value;
      if (err != null) {
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(err, style: TextStyle(color: cs.error)),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => Get.offAllNamed('/exam-type-list'),
                      child: const Text('목록으로'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
      final q = controller.currentQuestion;
      if (q == null) {
        return Scaffold(
          body: SafeArea(child: const Center(child: Text('데이터가 없습니다.'))),
        );
      }
      final ai = q.aiExplanation;
      final correctExplanation =
          (ai?['correctExplanation'] as String?)?.trim() ?? '';
      final wrongAnswerNotesRaw = ai?['wrongAnswerNotes'];
      final wrongAnswerNotes = wrongAnswerNotesRaw is List
          ? wrongAnswerNotesRaw
                .map((e) => e.toString())
                .where((e) => e.trim().isNotEmpty)
                .toList()
          : <String>[];
      final examTip = (ai?['examTip'] as String?)?.trim() ?? '';
      final hasAiExplanation =
          correctExplanation.isNotEmpty ||
          wrongAnswerNotes.isNotEmpty ||
          examTip.isNotEmpty;
      final bottomPreset = bottomNavHeightPresetForStep(
        controller.bottomNavHeightStep.value,
      );
      final questionImageSrc = resolveQuestionImageSrc(q);

      return Scaffold(
        bottomNavigationBar: BottomNavButtons(
          navReversed: controller.navReversed.value,
          prevDisabled: controller.isFirst,
          onPrev: controller.goPrev,
          onNext: controller.goNext,
          verticalPadding: bottomPreset.verticalPadding.toDouble(),
          fontSize: bottomPreset.fontSize.toDouble(),
        ),
        body: SafeArea(
          bottom: false,
          child: Stack(
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
                              '모의고사 (${controller.formatStartedAt()})',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
                          '[${q.subject}] ${controller.index.value + 1}/${controller.questions.length}',
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
                              color: cs.onSurface,
                              fontSize: controller.baseFont,
                              height: 1.5,
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
                          final isCorrect = c.no == q.correct_answer;
                          final isPicked = picked == c.no;
                          final isWrongPick = isPicked && !isCorrect;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isCorrect
                                    ? app.successMuted
                                    : isWrongPick
                                    ? app.errorMuted
                                    : cs.outlineVariant,
                              ),
                              borderRadius: BorderRadius.circular(6),
                              color: isCorrect
                                  ? app.successContainer
                                  : isWrongPick
                                  ? cs.errorContainer
                                  : cs.surface,
                            ),
                            child: Text(
                              '${c.no}. ${c.text}${isPicked ? ' (선택)' : ''}',
                              style: TextStyle(
                                fontSize: controller.baseFont,
                                color: isCorrect
                                    ? app.onSuccessContainer
                                    : isWrongPick
                                    ? cs.onErrorContainer
                                    : cs.onSurface,
                              ),
                            ),
                          );
                        }),
                        if (hasAiExplanation) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: cs.outlineVariant,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              color: cs.surface,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'AI 해설',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                if (correctExplanation.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  const Text(
                                    '정답 해설',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(correctExplanation),
                                ],
                                if (wrongAnswerNotes.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  const Text(
                                    '오답 노트',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  ...wrongAnswerNotes.map(
                                    (note) => Padding(
                                      padding: const EdgeInsets.only(bottom: 3),
                                      child: Text('• $note'),
                                    ),
                                  ),
                                ],
                                if (examTip.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  const Text(
                                    '쪽집게',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(examTip),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (controller.showAnswerSheet.value)
                _AnswerSheetOverlay(controller: controller),
              if (controller.showMoveListConfirm.value)
                Positioned.fill(
                  child: ColoredBox(
                    color: app.scrim,
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(20),
                        constraints: const BoxConstraints(maxWidth: 400),
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              '안내',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text('목록으로 이동하시겠습니까?'),
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed: controller.confirmMoveList,
                              child: const Text('확인'),
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton(
                              onPressed: controller.cancelMoveList,
                              child: const Text('취소'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}

class _AnswerSheetOverlay extends StatelessWidget {
  const _AnswerSheetOverlay({required this.controller});

  final MockExamHistoryDetailController controller;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final app = context.appColors;

    return Positioned.fill(
      child: ColoredBox(
        color: app.scrim,
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
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
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
                      final isCorrect = ans != null && ans == qq.correct_answer;
                      final status = ans == null
                          ? '미응답'
                          : isCorrect
                          ? '정답'
                          : '오답';
                      final statusColor = ans == null
                          ? cs.onSurfaceVariant
                          : isCorrect
                          ? app.onSuccessContainer
                          : cs.error;
                      return TextButton(
                        style: TextButton.styleFrom(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 10,
                          ),
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
                            Text(
                              '선택: ${ans == null ? '—' : '$ans번'} / 정답: ${qq.correct_answer}번',
                            ),
                            const SizedBox(height: 2),
                            Text(
                              status,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
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
