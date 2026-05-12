import type { ReactNode } from 'react'
import { BackIconButton } from './BackIconButton'

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
        borderBottom: '1px solid var(--border-app-bar)',
        background: 'var(--bg-surface)',
        boxSizing: 'border-box',
      }}
    >
      {showBack ? (
        <BackIconButton onClick={onBack} />
      ) : (
        <span style={{ width: 40, flexShrink: 0 }} aria-hidden />
      )}
      <div
        style={{
          flex: 1,
          fontWeight: 600,
          fontSize: 16,
          textAlign: 'center',
          whiteSpace: 'pre-line',
          lineHeight: 1.2,
          color: 'var(--text-primary)',
        }}
      >
        {title ?? ''}
      </div>
      <div style={{ minWidth: 72, display: 'flex', justifyContent: 'flex-end' }}>
        {right}
      </div>
    </header>
  )
}
