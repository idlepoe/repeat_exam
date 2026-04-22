import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/exam_session_list_controller.dart';

class ExamSessionListView extends GetView<ExamSessionListController> {
  const ExamSessionListView({super.key});
  @override
  Widget build(BuildContext context) {
    Color parseHex(String hex) {
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

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.data.value?.title ?? '출시회차')),
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
        final sessions = controller.sessions;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              controller.examType.value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ...sessions.map((session) {
              final count = controller.getSessionCount(session);
              final pct = controller.getSessionProgress(session);
              final highlightColor = parseHex(
                controller.answerHighlight.value.bg,
              );

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () async {
                    await controller.goQuestion(session);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFCCCCCC)),
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xFFFAFAFA),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: pct / 100,
                              child: Container(
                                height: 5,
                                color: highlightColor,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                session,
                                style: const TextStyle(
                                  color: Color(0xFF111111),
                                  fontSize: 17,
                                ),
                              ),
                              Text(
                                '$pct% · 회독 $count',
                                style: const TextStyle(
                                  color: Color(0xFF666666),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      }),
    );
  }
}
