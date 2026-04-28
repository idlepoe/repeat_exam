import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/exam_type_list_controller.dart';

class ExamTypeListView extends GetView<ExamTypeListController> {
  const ExamTypeListView({super.key});

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
            const Text(
              '시험 타입',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF555555),
              ),
            ),
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
          ],
        );
      }),
    );
  }
}
