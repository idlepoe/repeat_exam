import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/question_controller.dart';

class QuestionView extends GetView<QuestionController> {
  const QuestionView({super.key});

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

  Future<void> _showNextSessionDialog(BuildContext context) async {
    await Get.dialog<void>(
      AlertDialog(
        title: const Text('다음 회차로 이동할까요?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('취소')),
          TextButton(
            onPressed: () async {
              Get.back();
              await controller.moveToListAfterCountIncrement();
            },
            child: const Text('목록'),
          ),
          FilledButton(
            onPressed: () async {
              Get.back();
              await controller.moveToNextSessionAfterCountIncrement();
            },
            child: const Text('다음 회차'),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.examType.value)),
        actions: [
          TextButton(
            onPressed: controller.cycleFontStep,
            child: Text('aA', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: Obx(() {
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
        if (q == null) {
          return const Center(child: Text('불러오는 중…'));
        }
        final ai = q.aiExplanation;
        final correctExplanation =
            (ai?['correctExplanation'] as String?)?.trim() ?? '';
        final wrongAnswerNotesRaw = ai?['wrongAnswerNotes'];
        final wrongAnswerNotes = wrongAnswerNotesRaw is List
            ? wrongAnswerNotesRaw
                  .whereType<dynamic>()
                  .map((e) => e.toString())
                  .where((e) => e.trim().isNotEmpty)
                  .toList()
            : <String>[];
        final examTip = (ai?['examTip'] as String?)?.trim() ?? '';
        final hasAiExplanation =
            correctExplanation.isNotEmpty ||
            wrongAnswerNotes.isNotEmpty ||
            examTip.isNotEmpty;
        final highlight = controller.answerHighlight.value;
        final answerBg = _hexToColor(highlight.bg);
        final answerFg = _hexToColor(highlight.fg);

        return Column(
          children: [
            Expanded(
              child: ListView(
                key: ValueKey(q.question_number),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                children: [
                  Text(
                    '[${q.subject}]',
                    style: TextStyle(
                      fontSize: controller.titleFont,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: controller.baseFont,
                        height: 1.5,
                        color: const Color(0xFF111111),
                      ),
                      children: [
                        TextSpan(
                          text: '${q.question_number}. ',
                          style: const TextStyle(fontWeight: FontWeight.w600),
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
                    final isAnswer = c.no == q.correct_answer;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFDDDDDD)),
                        borderRadius: BorderRadius.circular(6),
                        color: isAnswer ? answerBg : const Color(0xFFFAFAFA),
                      ),
                      child: Text(
                        '${c.no}. ${c.text}',
                        style: TextStyle(
                          color: isAnswer ? answerFg : const Color(0xFF111111),
                          fontSize: controller.baseFont,
                        ),
                      ),
                    );
                  }),
                  if (hasAiExplanation) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE5E4E7)),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI 해설',
                            style: TextStyle(
                              fontSize: controller.baseFont,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (correctExplanation.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              '정답 해설',
                              style: TextStyle(
                                fontSize: controller.baseFont,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              correctExplanation,
                              style: TextStyle(fontSize: controller.baseFont),
                            ),
                          ],
                          if (wrongAnswerNotes.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(
                              '오답 노트',
                              style: TextStyle(
                                fontSize: controller.baseFont,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            ...wrongAnswerNotes.map(
                              (note) => Padding(
                                padding: const EdgeInsets.only(bottom: 3),
                                child: Text(
                                  '• $note',
                                  style: TextStyle(
                                    fontSize: controller.baseFont,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          if (examTip.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(
                              '쪽집게',
                              style: TextStyle(
                                fontSize: controller.baseFont,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              examTip,
                              style: TextStyle(fontSize: controller.baseFont),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Obx(
              () => SafeArea(
                top: false,
                child: Row(
                  children: controller.navReversed.value
                      ? [
                          Expanded(
                            child: _navButton(
                              label: '다음',
                              onTap: () async {
                                final ask = await controller.goNextOrAsk();
                                if (ask && context.mounted) {
                                  await _showNextSessionDialog(context);
                                }
                              },
                            ),
                          ),
                          Expanded(
                            child: _navButton(
                              label: '변경',
                              bgColor: const Color(0xFFF5F5F5),
                              borderLeft: true,
                              onTap: controller.toggleNavReversed,
                            ),
                          ),
                          Expanded(
                            child: _navButton(
                              label: '이전',
                              enabled: !controller.isFirst,
                              bgColor: controller.isFirst
                                  ? const Color(0xFFEEEEEE)
                                  : Colors.white,
                              borderLeft: true,
                              onTap: controller.goPrev,
                            ),
                          ),
                        ]
                      : [
                          Expanded(
                            child: _navButton(
                              label: '이전',
                              enabled: !controller.isFirst,
                              bgColor: controller.isFirst
                                  ? const Color(0xFFEEEEEE)
                                  : Colors.white,
                              onTap: controller.goPrev,
                            ),
                          ),
                          Expanded(
                            child: _navButton(
                              label: '변경',
                              bgColor: const Color(0xFFF5F5F5),
                              borderLeft: true,
                              onTap: controller.toggleNavReversed,
                            ),
                          ),
                          Expanded(
                            child: _navButton(
                              label: '다음',
                              borderLeft: true,
                              onTap: () async {
                                final ask = await controller.goNextOrAsk();
                                if (ask && context.mounted) {
                                  await _showNextSessionDialog(context);
                                }
                              },
                            ),
                          ),
                        ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _navButton({
    required String label,
    required VoidCallback onTap,
    bool enabled = true,
    bool borderLeft = false,
    Color bgColor = Colors.white,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(
            top: const BorderSide(color: Color(0xFFE5E4E7)),
            left: borderLeft
                ? const BorderSide(color: Color(0xFFE5E4E7))
                : BorderSide.none,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, color: Color(0xFF111111)),
          ),
        ),
      ),
    );
  }
}
