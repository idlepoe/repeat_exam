export const QUESTION_FONT_PRESETS = [
  { step: 0, label: '작게', base: 16, title: 15, verticalPadding: 8, fontSize: 14 },
  { step: 1, label: '보통', base: 18, title: 16, verticalPadding: 9, fontSize: 14 },
  { step: 2, label: '크게', base: 20, title: 17, verticalPadding: 10, fontSize: 15 },
  { step: 3, label: '아주 크게', base: 22, title: 18, verticalPadding: 11, fontSize: 15 },
  { step: 4, label: '최대', base: 24, title: 20, verticalPadding: 12, fontSize: 16 },
] as const

export const QUESTION_FONT_MAX_STEP = QUESTION_FONT_PRESETS.length - 1

export function clampQuestionFontStep(step: number): number {
  return Math.max(0, Math.min(step, QUESTION_FONT_MAX_STEP))
}

export function questionFontByStep(step: number) {
  return QUESTION_FONT_PRESETS[clampQuestionFontStep(step)]
}
