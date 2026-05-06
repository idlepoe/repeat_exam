import 'dart:async';

import 'package:flutter/material.dart';

class BottomNavButtons extends StatelessWidget {
  const BottomNavButtons({
    super.key,
    required this.navReversed,
    required this.prevDisabled,
    required this.onPrev,
    required this.onNext,
    required this.onToggleOrder,
    required this.verticalPadding,
    required this.fontSize,
    this.showKeyboardShortcutHints = false,
  });

  final bool navReversed;
  final bool prevDisabled;
  final FutureOr<void> Function() onPrev;
  final FutureOr<void> Function() onNext;
  final FutureOr<void> Function() onToggleOrder;
  final double verticalPadding;
  final double fontSize;

  /// Windows 회독 등 ← / → / Space 단축키 사용 시 버튼에 힌트 아이콘 표시.
  final bool showKeyboardShortcutHints;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final order = navReversed
        ? const ['next', 'toggle', 'prev']
        : const ['prev', 'toggle', 'next'];

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: cs.outlineVariant)),
        color: cs.surface,
      ),
      child: Row(
        children: List.generate(order.length, (idx) {
          final kind = order[idx];
          final isPrev = kind == 'prev';
          final isToggle = kind == 'toggle';
          final weight = isToggle ? 2 : 4;

          final bgColor = isToggle
              ? cs.surfaceContainerHigh
              : (isPrev && prevDisabled
                    ? cs.surfaceContainerHighest
                    : cs.surface);
          final onTap = isPrev
              ? (prevDisabled ? null : onPrev)
              : (isToggle ? onToggleOrder : onNext);
          final label = isPrev ? '이전' : (isToggle ? '변경' : '다음');
          final hintColor = cs.onSurface.withValues(alpha: 0.55);
          final hintSize = (fontSize * 0.72).clamp(14.0, 20.0);

          Widget labelChild = Text(label, style: TextStyle(fontSize: fontSize));
          if (showKeyboardShortcutHints) {
            final parts = <Widget>[];
            if (idx == 0) {
              parts.add(
                Icon(
                  Icons.keyboard_arrow_left,
                  size: hintSize,
                  color: hintColor,
                ),
              );
            }
            parts.add(Text(label, style: TextStyle(fontSize: fontSize)));
            if (kind == 'next') {
              parts.add(
                Icon(Icons.space_bar, size: hintSize, color: hintColor),
              );
            }
            if (idx == 2) {
              parts.add(
                Icon(
                  Icons.keyboard_arrow_right,
                  size: hintSize,
                  color: hintColor,
                ),
              );
            }
            labelChild = Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < parts.length; i++) ...[
                  if (i > 0) SizedBox(width: fontSize * 0.35),
                  parts[i],
                ],
              ],
            );
          }

          return Expanded(
            flex: weight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: bgColor,
                border: Border(
                  right: idx < order.length - 1
                      ? BorderSide(color: cs.outlineVariant)
                      : BorderSide.none,
                ),
              ),
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: verticalPadding,
                    horizontal: 8,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: cs.onSurface,
                ),
                onPressed: onTap == null ? null : () => onTap.call(),
                child: labelChild,
              ),
            ),
          );
        }),
      ),
    );
  }
}
