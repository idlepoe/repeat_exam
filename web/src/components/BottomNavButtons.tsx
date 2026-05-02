import { useEffect, useState, type CSSProperties } from 'react'
import {
  BOTTOM_NAV_HEIGHT_MAX_STEP,
  BOTTOM_NAV_HEIGHT_PRESETS,
} from '../lib/bottomNavHeight'
import { loadBottomNavHeightStep } from '../lib/storage'

type BottomNavButtonsProps = {
  navReversed: boolean
  prevDisabled: boolean
  onPrev: () => void
  onNext: () => void
  onToggleOrder: () => void
  ariaLabel?: string
}

type NavButtonKind = 'prev' | 'toggle' | 'next'

const navContainerStyle: CSSProperties = {
  flexShrink: 0,
  width: '100%',
  display: 'flex',
  flexDirection: 'row',
  alignItems: 'stretch',
  borderTop: '1px solid #e5e4e7',
  background: '#fff',
  paddingBottom: 'env(safe-area-inset-bottom, 0px)',
}

function loadHeightStepSafe(): number {
  const step = loadBottomNavHeightStep()
  return Math.max(0, Math.min(step, BOTTOM_NAV_HEIGHT_MAX_STEP))
}

function btnThird(
  weight: number,
  heightStep: number,
  extra: CSSProperties
): CSSProperties {
  const preset = BOTTOM_NAV_HEIGHT_PRESETS[heightStep]
  return {
    flex: `${weight} 1 0`,
    minWidth: 0,
    boxSizing: 'border-box',
    padding: `${Math.max(10, preset.verticalPadding - 4)}px 6px`,
    border: 'none',
    borderRadius: 0,
    cursor: 'pointer',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 4,
    lineHeight: 1.15,
    ...extra,
  }
}

const kbdHintStyle = (fontSize: number): CSSProperties => ({
  fontSize,
  fontWeight: 500,
  color: '#5a5a5a',
  letterSpacing: 0.02,
  fontFamily: 'system-ui, sans-serif',
})

function keyHintsFor(
  kind: NavButtonKind,
  navReversed: boolean
): { primary: string; secondary?: string } {
  if (kind === 'toggle') {
    return { primary: '—' }
  }
  if (kind === 'prev') {
    return { primary: navReversed ? '→' : '←' }
  }
  return {
    primary: navReversed ? '←' : '→',
    secondary: 'Space',
  }
}

function styleByKind(kind: NavButtonKind, prevDisabled: boolean): CSSProperties {
  if (kind === 'toggle') {
    return {
      background: '#f5f5f5',
      color: '#111',
    }
  }

  if (kind === 'prev' && prevDisabled) {
    return {
      background: '#eee',
      color: '#111',
      cursor: 'not-allowed',
    }
  }

  return {
    background: '#fff',
    color: '#111',
  }
}

export function BottomNavButtons({
  navReversed,
  prevDisabled,
  onPrev,
  onNext,
  onToggleOrder,
  ariaLabel = '문제 이동',
}: BottomNavButtonsProps) {
  const [heightStep, setHeightStep] = useState(() => loadHeightStepSafe())

  useEffect(() => {
    const sync = () => setHeightStep(loadHeightStepSafe())
    window.addEventListener('repeat_exam:bottom_nav_height_changed', sync)
    return () => window.removeEventListener('repeat_exam:bottom_nav_height_changed', sync)
  }, [])

  useEffect(() => {
    const ignoreWhenTyping = (t: HTMLElement | null) => {
      if (!t) return false
      const tag = t.tagName
      if (tag === 'INPUT' || tag === 'TEXTAREA' || tag === 'SELECT') return true
      if (t.isContentEditable) return true
      return false
    }

    const onKeyDown = (e: KeyboardEvent) => {
      const t = e.target as HTMLElement | null
      if (ignoreWhenTyping(t)) return

      if (e.key === ' ' || e.code === 'Space') {
        e.preventDefault()
        onNext()
        return
      }

      if (e.key !== 'ArrowLeft' && e.key !== 'ArrowRight') return

      if (e.key === 'ArrowLeft') {
        if (navReversed) {
          e.preventDefault()
          onNext()
        } else {
          if (prevDisabled) return
          e.preventDefault()
          onPrev()
        }
      } else {
        if (navReversed) {
          if (prevDisabled) return
          e.preventDefault()
          onPrev()
        } else {
          e.preventDefault()
          onNext()
        }
      }
    }

    window.addEventListener('keydown', onKeyDown)
    return () => window.removeEventListener('keydown', onKeyDown)
  }, [navReversed, prevDisabled, onPrev, onNext])

  const order: NavButtonKind[] = navReversed
    ? ['next', 'toggle', 'prev']
    : ['prev', 'toggle', 'next']

  return (
    <nav style={navContainerStyle} aria-label={ariaLabel}>
      {order.map((kind, idx) => {
        const isPrev = kind === 'prev'
        const isToggle = kind === 'toggle'
        const weight = isToggle ? 2 : 4
        const base = styleByKind(kind, prevDisabled)
        const style = btnThird(
          weight,
          heightStep,
          idx < 2 ? { borderRight: '1px solid #e5e4e7', ...base } : base
        )
        const onClick = isPrev ? onPrev : isToggle ? onToggleOrder : onNext
        const label = isPrev ? '이전' : isToggle ? '변경' : '다음'
        const preset = BOTTOM_NAV_HEIGHT_PRESETS[heightStep]
        const hintFont = Math.max(10, preset.fontSize - 6)
        const hints = keyHintsFor(kind, navReversed)

        return (
          <button
            key={kind}
            type="button"
            onClick={onClick}
            disabled={isPrev && prevDisabled}
            style={style}
          >
            <span style={{ fontSize: preset.fontSize, fontWeight: 600 }}>
              {label}
            </span>
            <span
              style={{
                ...kbdHintStyle(hintFont),
                display: 'flex',
                flexDirection: 'row',
                alignItems: 'center',
                justifyContent: 'center',
                gap: hints.secondary ? 6 : 0,
                flexWrap: 'wrap',
              }}
            >
              <span aria-hidden>{hints.primary}</span>
              {hints.secondary ? (
                <span aria-hidden>{hints.secondary}</span>
              ) : null}
            </span>
          </button>
        )
      })}
    </nav>
  )
}
