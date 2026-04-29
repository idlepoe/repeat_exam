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
    padding: `${preset.verticalPadding}px 8px`,
    fontSize: preset.fontSize,
    border: 'none',
    borderRadius: 0,
    cursor: 'pointer',
    ...extra,
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

        return (
          <button
            key={kind}
            type="button"
            onClick={onClick}
            disabled={isPrev && prevDisabled}
            style={style}
          >
            {label}
          </button>
        )
      })}
    </nav>
  )
}
