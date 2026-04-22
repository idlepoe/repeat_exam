import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'package:get/get.dart';

import '../../../data/services/storage_service.dart';
import '../controllers/exam_type_list_controller.dart';

class ExamTypeListView extends GetView<ExamTypeListController> {
  const ExamTypeListView({super.key});

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

  String _colorToHex(Color color) {
    final argb = color.toARGB32();
    final rgb = argb.toRadixString(16).padLeft(8, '0').substring(2);
    return '#${rgb.toUpperCase()}';
  }

  Future<void> _showHighlightDialog(BuildContext context) async {
    final current = controller.answerHighlight.value;
    Color bg = _hexToColor(current.bg);
    Color fg = _hexToColor(current.fg);

    await Get.dialog<void>(
      AlertDialog(
        title: const Text('정답 하이라이트 색상'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('배경 색상'),
                  const SizedBox(height: 8),
                  ColorPicker(
                    pickerColor: bg,
                    onColorChanged: (value) => setState(() => bg = value),
                    enableAlpha: false,
                    labelTypes: const [],
                    portraitOnly: true,
                  ),
                  const SizedBox(height: 12),
                  const Text('글자 색상'),
                  const SizedBox(height: 8),
                  ColorPicker(
                    pickerColor: fg,
                    onColorChanged: (value) => setState(() => fg = value),
                    enableAlpha: false,
                    labelTypes: const [],
                    portraitOnly: true,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFDDDDDD)),
                    ),
                    child: Text(
                      '미리보기: 정답 보기',
                      style: TextStyle(color: fg, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('취소')),
          FilledButton(
            onPressed: () async {
              await controller.saveAnswerHighlight(
                AnswerHighlight(bg: _colorToHex(bg), fg: _colorToHex(fg)),
              );
              Get.back();
            },
            child: const Text('저장'),
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
        title: Obx(() => Text(controller.data.value?.title ?? '시험 리스트')),
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

        final highlight = controller.answerHighlight.value;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(bottom: 8),
              shape: const Border(),
              collapsedShape: const Border(),
              title: const Text(
                '옵션',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF555555),
                ),
              ),
              subtitle: Text(
                controller.optionsFolded.value ? '펼치기' : '접기',
                style: const TextStyle(fontSize: 12, color: Color(0xFF777777)),
              ),
              initiallyExpanded: !controller.optionsFolded.value,
              onExpansionChanged: (expanded) {
                controller.optionsFolded.value = !expanded;
              },
              children: [
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => _showHighlightDialog(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: _hexToColor(highlight.bg),
                      foregroundColor: _hexToColor(highlight.fg),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('정답 하이라이트 색상 변경'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      await controller.clearAllProgress();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('진행상황이 초기화되었습니다.')),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFB00000),
                      side: const BorderSide(color: Color(0xFFDD4444)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('진행상황 초기화하기'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
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
