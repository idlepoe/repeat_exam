/// Web `bottomNavHeight.ts`와 동일한 프리셋.
class BottomNavHeightPreset {
  const BottomNavHeightPreset({
    required this.step,
    required this.label,
    required this.verticalPadding,
    required this.fontSize,
  });

  final int step;
  final String label;
  final int verticalPadding;
  final int fontSize;
}

const List<BottomNavHeightPreset> kBottomNavHeightPresets = [
  BottomNavHeightPreset(
    step: 0,
    label: '보통',
    verticalPadding: 14,
    fontSize: 16,
  ),
  BottomNavHeightPreset(
    step: 1,
    label: '크게',
    verticalPadding: 18,
    fontSize: 17,
  ),
  BottomNavHeightPreset(
    step: 2,
    label: '더 크게',
    verticalPadding: 22,
    fontSize: 18,
  ),
];

/// [kBottomNavHeightPresets] 항목 수가 바뀌면 같이 맞출 것.
const int kBottomNavHeightMaxStep = 2;

BottomNavHeightPreset bottomNavHeightPresetForStep(int step) {
  final i = step.clamp(0, kBottomNavHeightMaxStep);
  return kBottomNavHeightPresets[i];
}

/// 스크롤 여백용 추정 높이 (패딩·글자 크기와 대략 일치).
double bottomNavBarEstimatedOuterHeight(BottomNavHeightPreset p) {
  return 2 * p.verticalPadding + p.fontSize * 1.35;
}
