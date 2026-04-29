import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { AppBar } from '../components/AppBar'
import { BOTTOM_NAV_HEIGHT_PRESETS } from '../lib/bottomNavHeight'
import {
  clearProgress,
  clearSessionCount,
  loadAnswerHighlight,
  loadBottomNavHeightStep,
  saveAnswerHighlight,
  saveBottomNavHeightStep,
} from '../lib/storage'

export function OptionsPage() {
  const navigate = useNavigate()
  const [showHighlightDialog, setShowHighlightDialog] = useState(false)
  const [answerHighlight, setAnswerHighlight] = useState(() =>
    loadAnswerHighlight()
  )
  const [draftBg, setDraftBg] = useState(answerHighlight.bg)
  const [draftFg, setDraftFg] = useState(answerHighlight.fg)
  const [bottomNavHeightStep, setBottomNavHeightStep] = useState(() =>
    loadBottomNavHeightStep()
  )

  return (
    <div style={{ minHeight: '100svh', display: 'flex', flexDirection: 'column' }}>
      <AppBar
        title="옵션"
        showBack
        onBack={() => navigate('/')}
      />
      <main style={{ flex: 1, padding: 16 }}>
        <section style={{ marginBottom: 16 }}>
          <div
            style={{
              marginBottom: 12,
              paddingBottom: 8,
              fontSize: 14,
              fontWeight: 600,
              color: '#555',
              borderBottom: '1px solid #ddd',
            }}
          >
            옵션
          </div>

          <button
            type="button"
            onClick={() => {
              setDraftBg(answerHighlight.bg)
              setDraftFg(answerHighlight.fg)
              setShowHighlightDialog(true)
            }}
            style={{
              display: 'block',
              width: '100%',
              marginBottom: 12,
              padding: '12px 14px',
              fontSize: 15,
              textAlign: 'center',
              border: '1px solid #bbb',
              borderRadius: 8,
              background: answerHighlight.bg,
              color: answerHighlight.fg,
              cursor: 'pointer',
            }}
          >
            정답 하이라이트 색상 변경
          </button>
          <div style={{ marginBottom: 12 }}>
            <div
              style={{
                marginBottom: 8,
                fontSize: 14,
                fontWeight: 600,
                color: '#555',
              }}
            >
              하단 버튼 높이
            </div>
            <div style={{ display: 'flex', gap: 8, alignItems: 'flex-end' }}>
              {BOTTOM_NAV_HEIGHT_PRESETS.map((opt) => {
                const selected = bottomNavHeightStep === opt.step
                return (
                  <button
                    key={opt.step}
                    type="button"
                    onClick={() => {
                      saveBottomNavHeightStep(opt.step)
                      setBottomNavHeightStep(opt.step)
                      window.dispatchEvent(new Event('repeat_exam:bottom_nav_height_changed'))
                    }}
                    aria-pressed={selected}
                    style={{
                      flex: 1,
                      minWidth: 0,
                      padding: `${opt.verticalPadding}px 8px`,
                      fontSize: opt.fontSize,
                      textAlign: 'center',
                      border: selected ? '2px solid #222' : '1px solid #bbb',
                      borderRadius: 8,
                      background: selected ? '#f4f4f4' : '#fff',
                      color: '#111',
                      cursor: 'pointer',
                      fontWeight: selected ? 700 : 500,
                    }}
                  >
                    {opt.label}
                  </button>
                )
              })}
            </div>
          </div>
          <div
            style={{
              marginTop: 16,
              paddingTop: 16,
              borderTop: '1px solid #e5e4e7',
            }}
          >
            <button
              type="button"
              onClick={() => {
                clearProgress()
                clearSessionCount()
                window.alert('진행상황이 초기화되었습니다.')
              }}
              style={{
                display: 'block',
                width: '100%',
                padding: '12px 14px',
                fontSize: 15,
                textAlign: 'center',
                border: '1px solid #d44',
                borderRadius: 8,
                background: '#fff5f5',
                color: '#b00',
                cursor: 'pointer',
              }}
            >
              진행상황 초기화하기
            </button>
          </div>
        </section>
      </main>

      {showHighlightDialog && (
        <div
          role="dialog"
          aria-modal="true"
          style={{
            position: 'fixed',
            inset: 0,
            background: 'rgba(0,0,0,0.45)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            zIndex: 100,
            padding: 16,
          }}
        >
          <div
            style={{
              background: '#fff',
              borderRadius: 12,
              padding: 20,
              width: '100%',
              maxWidth: 360,
              boxShadow: '0 8px 24px rgba(0,0,0,0.2)',
            }}
          >
            <p style={{ margin: '0 0 12px', fontSize: 17, fontWeight: 600 }}>
              정답 하이라이트 색상
            </p>

            <label
              style={{
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                marginBottom: 8,
                fontSize: 14,
              }}
            >
              <span>배경 색상</span>
              <input
                type="color"
                value={draftBg}
                onChange={(e) => setDraftBg(e.target.value)}
              />
            </label>

            <label
              style={{
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                marginBottom: 14,
                fontSize: 14,
              }}
            >
              <span>글자 색상</span>
              <input
                type="color"
                value={draftFg}
                onChange={(e) => setDraftFg(e.target.value)}
              />
            </label>

            <div
              style={{
                marginBottom: 14,
                padding: '10px 12px',
                borderRadius: 8,
                border: '1px solid #ddd',
                background: draftBg,
                color: draftFg,
                fontSize: 14,
                fontWeight: 600,
              }}
            >
              미리보기: 정답 보기
            </div>

            <div style={{ display: 'flex', gap: 8 }}>
              <button
                type="button"
                onClick={() => setShowHighlightDialog(false)}
                style={{
                  flex: 1,
                  padding: '10px 12px',
                  border: '1px solid #ccc',
                  borderRadius: 8,
                  background: '#f5f5f5',
                  cursor: 'pointer',
                }}
              >
                취소
              </button>
              <button
                type="button"
                onClick={() => {
                  const next = { bg: draftBg, fg: draftFg }
                  saveAnswerHighlight(next)
                  setAnswerHighlight(next)
                  setShowHighlightDialog(false)
                }}
                style={{
                  flex: 1,
                  padding: '10px 12px',
                  border: '1px solid #333',
                  borderRadius: 8,
                  background: '#222',
                  color: '#fff',
                  cursor: 'pointer',
                }}
              >
                저장
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
