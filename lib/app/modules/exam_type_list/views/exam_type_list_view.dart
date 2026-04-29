import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/exam_type_list_controller.dart';

class ExamTypeListView extends GetView<ExamTypeListController> {
  const ExamTypeListView({super.key});

  Widget _sectionTitle(String text, {Widget? trailing}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF555555),
            ),
          ),
        ),
        trailing ?? const SizedBox.shrink(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.data.value?.title ?? '시험 리스트')),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: '옵션',
            onPressed: controller.goOptions,
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

        final data = controller.data.value;
        if (data == null) {
          return const Center(child: Text('데이터가 없습니다.'));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionTitle('기출문제 (정답&해설 표시)'),
            const Divider(color: Color(0xFFDDDDDD)),
            const SizedBox(height: 4),
            ...data.exam_type_list.map(
              (name) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: OutlinedButton(
                  onPressed: () => controller.goSessions(name),
                  style: OutlinedButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    side: const BorderSide(color: Color(0xFFCCCCCC)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(name, style: const TextStyle(fontSize: 18)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _sectionTitle('모의고사'),
            const Divider(color: Color(0xFFDDDDDD)),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OutlinedButton(
                onPressed: () => controller.goMockExam('제빵기능사'),
                style: OutlinedButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  side: const BorderSide(color: Color(0xFFCCCCCC)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('제빵기능사', style: TextStyle(fontSize: 18)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OutlinedButton(
                onPressed: () => controller.goMockExam('제과기능사'),
                style: OutlinedButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  side: const BorderSide(color: Color(0xFFCCCCCC)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('제과기능사', style: TextStyle(fontSize: 18)),
              ),
            ),
            Obx(() {
              final ongoing = controller.ongoingMock.value;
              if (ongoing == null) return const SizedBox.shrink();
              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF1976D2)),
                  color: const Color(0xFFF5F9FF),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '모의고사 진행 중',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(ongoing.examKind),
                    const SizedBox(height: 4),
                    Text(
                      '현재 문제: ${ongoing.currentIndex + 1} / ${ExamTypeListController.mockTotal}',
                    ),
                    const SizedBox(height: 4),
                    Text('남은 시간: ${controller.formatRemainMs()} / 60:00'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: controller.continueMockExam,
                      child: const Text('모의고사 이어서 풀기'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () async {
                        final ok = await Get.dialog<bool>(
                          AlertDialog(
                            content: const Text('모의고사를 종료하시겠습니까?'),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(result: false),
                                child: const Text('취소'),
                              ),
                              FilledButton(
                                onPressed: () => Get.back(result: true),
                                child: const Text('확인'),
                              ),
                            ],
                          ),
                        );
                        if (ok == true) {
                          await controller.endOngoingMock();
                        }
                      },
                      child: const Text('모의고사 종료'),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 4),
            _sectionTitle(
              '모의고사 이력',
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: '이력 전체 삭제',
                onPressed: () async {
                  final ok = await Get.dialog<bool>(
                    AlertDialog(
                      content: const Text('이력을 삭제하시겠습니까?'),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(result: false),
                          child: const Text('취소'),
                        ),
                        FilledButton(
                          onPressed: () => Get.back(result: true),
                          child: const Text('확인'),
                        ),
                      ],
                    ),
                  );
                  if (ok == true) await controller.clearMockHistory();
                },
              ),
            ),
            const Divider(color: Color(0xFFDDDDDD)),
            const SizedBox(height: 4),
            Obx(() {
              final rows = controller.mockHistory;
              if (rows.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    '아직 기록된 이력이 없습니다.',
                    style: TextStyle(color: Color(0xFF888888)),
                  ),
                );
              }
              return Column(
                children: rows
                    .map(
                      (row) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: OutlinedButton(
                          onPressed: () =>
                              controller.goMockHistoryDetail(row.id),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(12),
                            side: const BorderSide(color: Color(0xFFE0E0E0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.centerLeft,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      row.examKind,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF333333),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    row.passed ? '합격' : '불합격',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: row.passed
                                          ? const Color(0xFF1565C0)
                                          : const Color(0xFFC62828),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '시작: ${controller.formatStartedAt(row.startedAt)}',
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '경과: ${controller.formatElapsed(row.startedAt, row.endedAt)}',
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '문항 ${row.totalQuestions} · 정답 ${row.correctCount}',
                                    ),
                                  ),
                                  Text(
                                    '${row.scoreFloored}점',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            }),
          ],
        );
      }),
    );
  }
}
