import type { CSSProperties, MouseEventHandler } from 'react'

const baseStyle: CSSProperties = {
  display: 'inline-flex',
  alignItems: 'center',
  justifyContent: 'center',
  width: 40,
  height: 40,
  padding: 0,
  flexShrink: 0,
  border: '1px solid var(--border-subtle)',
  borderRadius: 6,
  background: 'var(--bg-button-secondary)',
  color: 'var(--text-primary)',
  cursor: 'pointer',
}

type Props = {
  onClick?: MouseEventHandler<HTMLButtonElement>
  style?: CSSProperties
  'aria-label'?: string
}

export function BackIconButton({
  onClick,
  style,
  'aria-label': ariaLabel = '뒤로가기',
}: Props) {
  return (
    <button
      type="button"
      onClick={onClick}
      aria-label={ariaLabel}
      style={{ ...baseStyle, ...style }}
    >
      <svg
        width="22"
        height="22"
        viewBox="0 0 24 24"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
        aria-hidden
      >
        <path
          d="M15 18l-6-6 6-6"
          stroke="currentColor"
          strokeWidth="2"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
      </svg>
    </button>
  )
}
