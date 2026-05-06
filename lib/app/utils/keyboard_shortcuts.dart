import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Windows 데스크톱에서만 PC 단축키를 활성화한다.
bool get isDesktopShortcutsPlatform =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

/// 모의고사 보기 1~4 단축키 힌트용 아이콘.
IconData choiceDigitShortcutIcon(int choiceNo) {
  switch (choiceNo) {
    case 1:
      return Icons.looks_one;
    case 2:
      return Icons.looks_two;
    case 3:
      return Icons.looks_3;
    case 4:
      return Icons.looks_4;
    default:
      return Icons.circle_outlined;
  }
}

/// 회독 화면: ← / → / Space (Windows 전용).
class QuestionShortcuts extends StatelessWidget {
  const QuestionShortcuts({
    super.key,
    required this.onLeft,
    required this.onRight,
    required this.onSpace,
    required this.child,
  });

  final VoidCallback onLeft;
  final VoidCallback onRight;
  final VoidCallback onSpace;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!isDesktopShortcutsPlatform) return child;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowLeft): onLeft,
        const SingleActivator(LogicalKeyboardKey.arrowRight): onRight,
        const SingleActivator(LogicalKeyboardKey.space): onSpace,
      },
      child: Focus(
        autofocus: true,
        skipTraversal: true,
        child: child,
      ),
    );
  }
}

/// 모의고사: 1~4 및 숫자패드 (Windows 전용). [isBlocked]이 true면 무시.
class MockExamShortcuts extends StatelessWidget {
  const MockExamShortcuts({
    super.key,
    required this.isBlocked,
    required this.onDigit,
    required this.child,
  });

  final bool isBlocked;
  final void Function(int choiceNo) onDigit;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!isDesktopShortcutsPlatform) return child;

    void guarded(int n) {
      if (isBlocked) return;
      onDigit(n);
    }

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.digit1): () => guarded(1),
        const SingleActivator(LogicalKeyboardKey.digit2): () => guarded(2),
        const SingleActivator(LogicalKeyboardKey.digit3): () => guarded(3),
        const SingleActivator(LogicalKeyboardKey.digit4): () => guarded(4),
        const SingleActivator(LogicalKeyboardKey.numpad1): () => guarded(1),
        const SingleActivator(LogicalKeyboardKey.numpad2): () => guarded(2),
        const SingleActivator(LogicalKeyboardKey.numpad3): () => guarded(3),
        const SingleActivator(LogicalKeyboardKey.numpad4): () => guarded(4),
      },
      child: Focus(
        autofocus: true,
        skipTraversal: true,
        child: child,
      ),
    );
  }
}
