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
  });

  final bool navReversed;
  final bool prevDisabled;
  final FutureOr<void> Function() onPrev;
  final FutureOr<void> Function() onNext;
  final FutureOr<void> Function() onToggleOrder;
  final double verticalPadding;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final order = navReversed
        ? const ['next', 'toggle', 'prev']
        : const ['prev', 'toggle', 'next'];

    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE5E4E7))),
        color: Colors.white,
      ),
      child: Row(
        children: List.generate(order.length, (idx) {
          final kind = order[idx];
          final isPrev = kind == 'prev';
          final isToggle = kind == 'toggle';
          final weight = isToggle ? 2 : 4;

          final bgColor = isToggle
              ? const Color(0xFFF5F5F5)
              : (isPrev && prevDisabled
                    ? const Color(0xFFEEEEEE)
                    : Colors.white);
          final onTap = isPrev
              ? (prevDisabled ? null : onPrev)
              : (isToggle ? onToggleOrder : onNext);
          final label = isPrev ? '이전' : (isToggle ? '변경' : '다음');

          return Expanded(
            flex: weight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: bgColor,
                border: Border(
                  right: idx < order.length - 1
                      ? const BorderSide(color: Color(0xFFE5E4E7))
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
                  foregroundColor: const Color(0xFF111111),
                ),
                onPressed: onTap == null ? null : () => onTap.call(),
                child: Text(label, style: TextStyle(fontSize: fontSize)),
              ),
            ),
          );
        }),
      ),
    );
  }
}
