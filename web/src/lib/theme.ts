import type { ThemePreference } from './storage'

/** {@link KEY_THEME} 와 FOUC 인라인 스크립트와 동기화 */
export function resolveEffectiveTheme(pref: ThemePreference): 'light' | 'dark' {
  if (pref === 'system') {
    return window.matchMedia('(prefers-color-scheme: dark)').matches
      ? 'dark'
      : 'light'
  }
  return pref
}

export function applyThemeToDocument(effective: 'light' | 'dark'): void {
  document.documentElement.setAttribute('data-theme', effective)
  const meta = document.querySelector('meta[name="theme-color"]')
  if (meta) {
    meta.setAttribute(
      'content',
      effective === 'dark' ? '#121212' : '#ececec'
    )
  }
}

export function subscribeSystemTheme(onChange: () => void): () => void {
  const mq = window.matchMedia('(prefers-color-scheme: dark)')
  mq.addEventListener('change', onChange)
  return () => mq.removeEventListener('change', onChange)
}
