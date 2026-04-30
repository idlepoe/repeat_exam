class QuestionFontPreset {
  const QuestionFontPreset({
    required this.step,
    required this.label,
    required this.base,
    required this.title,
    required this.verticalPadding,
    required this.fontSize,
  });

  final int step;
  final String label;
  final double base;
  final double title;
  final int verticalPadding;
  final int fontSize;
}

const List<QuestionFontPreset> kQuestionFontPresets = [
  QuestionFontPreset(
    step: 0,
    label: '작게',
    base: 16,
    title: 15,
    verticalPadding: 8,
    fontSize: 14,
  ),
  QuestionFontPreset(
    step: 1,
    label: '보통',
    base: 18,
    title: 16,
    verticalPadding: 9,
    fontSize: 14,
  ),
  QuestionFontPreset(
    step: 2,
    label: '크게',
    base: 20,
    title: 17,
    verticalPadding: 10,
    fontSize: 15,
  ),
  QuestionFontPreset(
    step: 3,
    label: '아주 크게',
    base: 22,
    title: 18,
    verticalPadding: 11,
    fontSize: 15,
  ),
  QuestionFontPreset(
    step: 4,
    label: '최대',
    base: 24,
    title: 20,
    verticalPadding: 12,
    fontSize: 16,
  ),
];

const int kQuestionFontMaxStep = 4;

int clampQuestionFontStep(int step) {
  return step.clamp(0, kQuestionFontMaxStep).toInt();
}

QuestionFontPreset questionFontPresetForStep(int step) {
  return kQuestionFontPresets[clampQuestionFontStep(step)];
}
