import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'package:get/get.dart';

import '../../../data/bottom_nav_height.dart';
import '../../../data/services/storage_service.dart';
import '../controllers/options_controller.dart';

class OptionsView extends GetView<OptionsController> {
  const OptionsView({super.key});

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
          tooltip: '뒤로가기',
        ),
        title: const Text('옵션'),
        centerTitle: true,
      ),
      body: Obx(() {
        final highlight = controller.answerHighlight.value;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              '옵션',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF555555),
              ),
            ),
            const Divider(color: Color(0xFFDDDDDD)),
            const SizedBox(height: 12),
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
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '하단 버튼 높이',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF555555),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final opt in kBottomNavHeightPresets)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Obx(() {
                        final selected =
                            controller.bottomNavHeightStep.value == opt.step;
                        return OutlinedButton(
                          onPressed: () =>
                              controller.setBottomNavHeightStep(opt.step),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF111111),
                            padding: EdgeInsets.symmetric(
                              vertical: opt.verticalPadding.toDouble(),
                              horizontal: 8,
                            ),
                            side: BorderSide(
                              color: selected
                                  ? const Color(0xFF222222)
                                  : const Color(0xFFBBBBBB),
                              width: selected ? 2 : 1,
                            ),
                            backgroundColor: selected
                                ? const Color(0xFFF4F4F4)
                                : Colors.white,
                          ),
                          child: Text(
                            opt.label,
                            style: TextStyle(
                              fontSize: opt.fontSize.toDouble(),
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFE5E4E7)),
            const SizedBox(height: 16),
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
        );
      }),
    );
  }
}
