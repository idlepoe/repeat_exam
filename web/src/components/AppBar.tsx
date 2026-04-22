import type { ReactNode } from 'react'

type Props = {
  title?: string
  showBack?: boolean
  onBack?: () => void
  right?: ReactNode
}

export function AppBar({ title, showBack, onBack, right }: Props) {
  return (
    <header
      style={{
        position: 'sticky',
        top: 0,
        zIndex: 10,
        display: 'flex',
        alignItems: 'center',
        gap: 8,
        minHeight: 48,
        padding: '8px 12px',
        borderBottom: '1px solid #e5e4e7',
        background: '#fff',
        boxSizing: 'border-box',
      }}
    >
      {showBack ? (
        <button
          type="button"
          onClick={onBack}
          style={{
            padding: '6px 10px',
            border: '1px solid #ccc',
            borderRadius: 6,
            background: '#f8f8f8',
            cursor: 'pointer',
            fontSize: 14,
          }}
        >
          뒤로가기
        </button>
      ) : (
        <span style={{ width: 72 }} />
      )}
      <div style={{ flex: 1, fontWeight: 600, fontSize: 16, textAlign: 'center' }}>
        {title ?? ''}
      </div>
      <div style={{ minWidth: 72, display: 'flex', justifyContent: 'flex-end' }}>
        {right}
      </div>
    </header>
  )
}
