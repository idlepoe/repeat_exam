export const BOTTOM_NAV_HEIGHT_PRESETS = [
  { step: 0, label: '보통', verticalPadding: 14, fontSize: 16 },
  { step: 1, label: '크게', verticalPadding: 18, fontSize: 17 },
  { step: 2, label: '더 크게', verticalPadding: 22, fontSize: 18 },
] as const

export const BOTTOM_NAV_HEIGHT_MAX_STEP = BOTTOM_NAV_HEIGHT_PRESETS.length - 1
