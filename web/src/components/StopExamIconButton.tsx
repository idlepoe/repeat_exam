import type { CSSProperties, MouseEventHandler } from 'react'

const baseStyle: CSSProperties = {
  display: 'inline-flex',
  alignItems: 'center',
  justifyContent: 'center',
  width: 40,
  height: 40,
  padding: 0,
  flexShrink: 0,
  border: '1px solid var(--border-mock-warning)',
  borderRadius: 6,
  background: 'var(--bg-danger)',
  color: 'var(--color-danger)',
  cursor: 'pointer',
}

function StopCircleIcon() {
  return (
    <svg
      width="22"
      height="22"
      viewBox="0 0 24 24"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      aria-hidden
    >
      <circle
        cx="12"
        cy="12"
        r="9"
        stroke="currentColor"
        strokeWidth="2"
      />
      <rect
        x="9"
        y="9"
        width="6"
        height="6"
        rx="1"
        fill="currentColor"
      />
    </svg>
  )
}

type Props = {
  onClick?: MouseEventHandler<HTMLButtonElement>
  style?: CSSProperties
  'aria-label'?: string
  title?: string
}

export function StopExamIconButton({
  onClick,
  style,
  'aria-label': ariaLabel = '시험종료',
  title = '시험종료',
}: Props) {
  return (
    <button
      type="button"
      onClick={onClick}
      aria-label={ariaLabel}
      title={title}
      style={{ ...baseStyle, ...style }}
    >
      <StopCircleIcon />
    </button>
  )
}
