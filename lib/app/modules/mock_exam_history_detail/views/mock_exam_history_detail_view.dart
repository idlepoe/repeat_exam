import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/bottom_nav_height.dart';
import '../../../widgets/bottom_nav_buttons.dart';
import '../controllers/mock_exam_history_detail_controller.dart';

class MockExamHistoryDetailView
    extends GetView<MockExamHistoryDetailController> {
  const MockExamHistoryDetailView({super.key});

  @override
  Widget build(BuildContext context) {
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
                    Text(err),
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

      return Scaffold(
        bottomNavigationBar: BottomNavButtons(
          navReversed: controller.navReversed.value,
          prevDisabled: controller.isFirst,
          onPrev: controller.goPrev,
          onNext: controller.goNext,
          onToggleOrder: controller.toggleNavReversed,
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
                              '모의고사 (${controller.formatStartedAt()})',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
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
                          '[${q.subject}] ${controller.index.value + 1}/${controller.questions.length}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              color: Color(0xFF111111),
                              fontSize: 16,
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
                        if (q.question_image_url != null &&
                            q.question_image_url!.trim().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Image.network(q.question_image_url!),
                          ),
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
                                    ? const Color(0xFF7CB67C)
                                    : isWrongPick
                                    ? const Color(0xFFE28E8E)
                                    : const Color(0xFFDDDDDD),
                              ),
                              borderRadius: BorderRadius.circular(6),
                              color: isCorrect
                                  ? const Color(0xFFEAF6EA)
                                  : isWrongPick
                                  ? const Color(0xFFFDEAEA)
                                  : const Color(0xFFFAFAFA),
                            ),
                            child: Text(
                              '${c.no}. ${c.text}${isPicked ? ' (선택)' : ''}',
                              style: TextStyle(
                                color: isCorrect
                                    ? const Color(0xFF1B5E20)
                                    : isWrongPick
                                    ? const Color(0xFFB71C1C)
                                    : const Color(0xFF111111),
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
                                color: const Color(0xFFE5E4E7),
                              ),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
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
                          ? const Color(0xFF777777)
                          : isCorrect
                          ? const Color(0xFF1B5E20)
                          : const Color(0xFFB71C1C);
                      return TextButton(
                        style: TextButton.styleFrom(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 10,
                          ),
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
