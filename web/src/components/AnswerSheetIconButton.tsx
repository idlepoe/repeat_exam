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
  background: 'var(--bg-surface)',
  color: 'var(--text-primary)',
  cursor: 'pointer',
}

function AnswerSheetIcon() {
  return (
    <svg
      width="22"
      height="22"
      viewBox="0 0 24 24"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      aria-hidden
    >
      <path
        d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8l-6-6z"
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <path
        d="M14 2v6h6"
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <path
        d="M8 11h5M8 19h8"
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
      />
      <path
        d="M8 15l2 2 4-4"
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
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

export function AnswerSheetIconButton({
  onClick,
  style,
  'aria-label': ariaLabel = '답안확인',
  title = '답안확인',
}: Props) {
  return (
    <button
      type="button"
      onClick={onClick}
      aria-label={ariaLabel}
      title={title}
      style={{ ...baseStyle, ...style }}
    >
      <AnswerSheetIcon />
    </button>
  )
}
