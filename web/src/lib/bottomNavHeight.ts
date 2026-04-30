export const BOTTOM_NAV_HEIGHT_PRESETS = [
  { step: 0, label: '보통', verticalPadding: 16, fontSize: 18 },
  { step: 1, label: '크게', verticalPadding: 20, fontSize: 19 },
  { step: 2, label: '더 크게', verticalPadding: 24, fontSize: 20 },
] as const

export const BOTTOM_NAV_HEIGHT_MAX_STEP = BOTTOM_NAV_HEIGHT_PRESETS.length - 1
