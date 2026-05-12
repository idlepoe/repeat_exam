import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { AppBar } from '../components/AppBar'
import { OptionsIconButton } from '../components/OptionsIconButton'
import { fetchExamTypeList, type ExamTypeListJson } from '../lib/examMeta'
import {
  clearMockHistory,
  clearMockSession,
  hasHistoryDetailPayload,
  loadMockHistory,
  loadMockSession,
  type MockHistoryRecord,
  type StoredMockSession,
} from '../lib/mockExamStorage'

const MOCK_TOTAL = 60
const EXAM_MS = 60 * 60 * 1000

function formatRemainMs(ms: number): string {
  const neg = ms < 0
  const abs = Math.abs(ms)
  const totalSec = Math.floor(abs / 1000)
  const m = Math.floor(totalSec / 60)
  const s = totalSec % 60
  const pad = (n: number) => n.toString().padStart(2, '0')
  if (neg) return `-${m}:${pad(s)}`
  return `${m}:${pad(s)}`
}

function readOngoingMockSession(): StoredMockSession | null {
  const s = loadMockSession()
  if (!s || s.questions.length !== MOCK_TOTAL) return null
  return s
}

function formatMockStartedAt(ts: number): string {
  return new Date(ts).toLocaleString('ko-KR', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
  })
}

function formatMockElapsedMs(ms: number): string {
  const totalSec = Math.max(0, Math.floor(ms / 1000))
  const h = Math.floor(totalSec / 3600)
  const m = Math.floor((totalSec % 3600) / 60)
  const s = totalSec % 60
  if (h > 0) return `${h}시간 ${m}분 ${s}초`
  return `${m}분 ${s}초`
}

function TrashIcon() {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width="20"
      height="20"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden
    >
      <path d="M3 6h18" />
      <path d="M19 6v14c0 1-1 2-2 2H7c-1 0-2-1-2-2V6" />
      <path d="M8 6V4c0-1 1-2 2-2h4c1 0 2 1 2 2v2" />
      <line x1="10" x2="10" y1="11" y2="17" />
      <line x1="14" x2="14" y1="11" y2="17" />
    </svg>
  )
}

export function ExamTypeListPage() {
  const navigate = useNavigate()
  const [data, setData] = useState<ExamTypeListJson | null>(null)
  const [err, setErr] = useState<string | null>(null)
  const [ongoingMock, setOngoingMock] = useState<StoredMockSession | null>(null)
  const [mockHistory, setMockHistory] = useState<MockHistoryRecord[]>([])
  const [, setTimerTick] = useState(0)

  useEffect(() => {
    fetchExamTypeList()
      .then(setData)
      .catch((e: Error) => setErr(e.message))
  }, [])

  useEffect(() => {
    const refresh = () => {
      setOngoingMock(readOngoingMockSession())
      setMockHistory(loadMockHistory())
    }
    refresh()
    window.addEventListener('storage', refresh)
    document.addEventListener('visibilitychange', refresh)
    return () => {
      window.removeEventListener('storage', refresh)
      document.removeEventListener('visibilitychange', refresh)
    }
  }, [])

  useEffect(() => {
    if (!ongoingMock) return
    const id = window.setInterval(() => {
      setTimerTick((t) => t + 1)
    }, 1000)
    return () => window.clearInterval(id)
  }, [ongoingMock])

  const handleEndOngoingMock = () => {
    if (!window.confirm('모의고사를 종료하시겠습니까?')) return
    clearMockSession('examTypeList-banner')
    setOngoingMock(null)
  }

  const handleClearMockHistory = () => {
    if (!window.confirm('이력을 삭제하시겠습니까?')) return
    clearMockHistory()
    setMockHistory([])
  }
  const detailedMockHistory = mockHistory.filter(hasHistoryDetailPayload)

  return (
    <div style={{ minHeight: '100svh', display: 'flex', flexDirection: 'column' }}>
      <AppBar
        title={data?.title ?? '시험 리스트'}
        right={
          <OptionsIconButton
            onClick={() => navigate('/options')}
            style={{
              borderRadius: 8,
              background: 'var(--bg-surface)',
              color: 'var(--text-secondary)',
            }}
          />
        }
      />
      <main style={{ flex: 1, padding: 16 }}>
        <section style={{ marginBottom: 24 }}>
          <div
            style={{
              marginBottom: 12,
              paddingBottom: 8,
              fontSize: 14,
              fontWeight: 600,
              color: 'var(--text-muted)',
              borderBottom: '1px solid var(--border-muted)',
            }}
          >
            기출문제 (정답&해설 표시)
          </div>
          {err && <p style={{ color: 'var(--color-danger)' }}>{err}</p>}
          {!data && !err && (
            <p style={{ color: 'var(--text-secondary)' }}>불러오는 중…</p>
          )}
          {data?.exam_type_list.map((name) => (
            <button
              key={name}
              type="button"
              onClick={() =>
                navigate(`/sessions/${encodeURIComponent(name)}`)
              }
              style={{
                display: 'block',
                width: '100%',
                marginBottom: 12,
                padding: '14px 16px',
                fontSize: 18,
                textAlign: 'left',
                border: '1px solid var(--border-subtle)',
                borderRadius: 8,
                background: 'var(--bg-muted)',
                color: 'var(--text-primary)',
                cursor: 'pointer',
              }}
            >
              {name}
            </button>
          ))}
        </section>

        {ongoingMock ? (
          <section
            style={{
              marginBottom: 20,
              padding: 14,
              borderRadius: 10,
              border: '1px solid var(--color-primary)',
              background: 'var(--bg-primary-soft)',
            }}
          >
            <div
              style={{
                fontSize: 14,
                fontWeight: 700,
                color: 'var(--text-primary-accent)',
                marginBottom: 8,
              }}
            >
              모의고사 진행 중
            </div>
            <div
              style={{
                fontSize: 14,
                marginBottom: 6,
                color: 'var(--text-secondary)',
              }}
            >
              {ongoingMock.examKind}
            </div>
            <div
              style={{
                fontSize: 14,
                marginBottom: 4,
                color: 'var(--text-body)',
              }}
            >
              현재 문제: {ongoingMock.currentIndex + 1} / {MOCK_TOTAL}
            </div>
            <div
              style={{
                fontSize: 14,
                marginBottom: 12,
                color: 'var(--text-body)',
              }}
            >
              남은 시간:{' '}
              {formatRemainMs(
                ongoingMock.startedAt + EXAM_MS - Date.now()
              )}{' '}
              / 60:00
            </div>
            <button
              type="button"
              onClick={() =>
                navigate(
                  `/mock-quiz/${encodeURIComponent(ongoingMock.examKind)}`
                )
              }
              style={{
                width: '100%',
                padding: '12px 14px',
                fontSize: 16,
                fontWeight: 600,
                border: 'none',
                borderRadius: 8,
                background: 'var(--color-primary)',
                color: 'var(--text-inverse)',
                cursor: 'pointer',
              }}
            >
              모의고사 이어서 풀기
            </button>
            <button
              type="button"
              onClick={handleEndOngoingMock}
              style={{
                width: '100%',
                marginTop: 8,
                padding: '12px 14px',
                fontSize: 15,
                fontWeight: 600,
                border: '1px solid var(--border-mock-warning)',
                borderRadius: 8,
                background: 'var(--bg-surface)',
                color: 'var(--color-danger)',
                cursor: 'pointer',
              }}
            >
              모의고사 종료
            </button>
          </section>
        ) : null}

        <section style={{ marginBottom: 24 }}>
          <div
            style={{
              marginBottom: 12,
              paddingBottom: 8,
              fontSize: 14,
              fontWeight: 600,
              color: 'var(--text-muted)',
              borderBottom: '1px solid var(--border-muted)',
            }}
          >
            모의고사
          </div>
          <button
            type="button"
            onClick={() =>
              navigate(`/mock-quiz/${encodeURIComponent('제빵기능사')}`)
            }
            style={{
              display: 'block',
              width: '100%',
              marginBottom: 12,
              padding: '14px 16px',
              fontSize: 18,
              textAlign: 'left',
              border: '1px solid var(--border-subtle)',
              borderRadius: 8,
              background: 'var(--bg-muted)',
              color: 'var(--text-primary)',
              cursor: 'pointer',
            }}
          >
            제빵기능사
          </button>
          <button
            type="button"
            onClick={() =>
              navigate(`/mock-quiz/${encodeURIComponent('제과기능사')}`)
            }
            style={{
              display: 'block',
              width: '100%',
              marginBottom: 12,
              padding: '14px 16px',
              fontSize: 18,
              textAlign: 'left',
              border: '1px solid var(--border-subtle)',
              borderRadius: 8,
              background: 'var(--bg-muted)',
              color: 'var(--text-primary)',
              cursor: 'pointer',
            }}
          >
            제과기능사
          </button>
        </section>

        <section style={{ marginBottom: 24 }}>
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
              gap: 8,
              marginBottom: 12,
              paddingBottom: 8,
              borderBottom: '1px solid var(--border-muted)',
            }}
          >
            <span
              style={{ fontSize: 14, fontWeight: 600, color: 'var(--text-muted)' }}
            >
              모의고사 이력
            </span>
            <button
              type="button"
              onClick={handleClearMockHistory}
              aria-label="모의고사 이력 전체 삭제"
              title="이력 전체 삭제"
              style={{
                display: 'inline-flex',
                alignItems: 'center',
                justifyContent: 'center',
                flexShrink: 0,
                width: 36,
                height: 36,
                padding: 0,
                border: '1px solid var(--border-muted)',
                borderRadius: 8,
                background: 'var(--bg-surface)',
                color: 'var(--text-subtle)',
                cursor: 'pointer',
              }}
            >
              <TrashIcon />
            </button>
          </div>
          {detailedMockHistory.length === 0 ? (
            <p style={{ margin: 0, fontSize: 14, color: 'var(--text-disabled)' }}>
              아직 기록된 이력이 없습니다.
            </p>
          ) : (
            <ul
              style={{
                margin: 0,
                padding: 0,
                listStyle: 'none',
              }}
            >
              {detailedMockHistory.map((row) => (
                <li
                  key={row.id}
                  style={{
                    marginBottom: 12,
                  }}
                >
                  <button
                    type="button"
                    onClick={() =>
                      navigate(`/mock-history/${encodeURIComponent(row.id)}`)
                    }
                    style={{
                      width: '100%',
                      textAlign: 'left',
                      padding: 12,
                      border: '1px solid var(--border-card)',
                      borderRadius: 8,
                      background: 'var(--bg-muted)',
                      fontSize: 14,
                      color: 'var(--text-secondary)',
                      cursor: 'pointer',
                    }}
                  >
                    <div
                      style={{
                        display: 'flex',
                        justifyContent: 'space-between',
                        alignItems: 'center',
                        gap: 8,
                        marginBottom: 6,
                      }}
                    >
                      <span style={{ fontWeight: 600 }}>{row.examKind}</span>
                      <span
                        style={{
                          flexShrink: 0,
                          fontWeight: 700,
                          fontSize: 13,
                          color: row.passed
                            ? 'var(--color-pass)'
                            : 'var(--color-fail)',
                        }}
                      >
                        {row.passed ? '합격' : '불합격'}
                      </span>
                    </div>
                    <div
                      style={{
                        marginBottom: 4,
                        color: 'var(--text-body)',
                      }}
                    >
                      시작: {formatMockStartedAt(row.startedAt)}
                    </div>
                    <div
                      style={{
                        marginBottom: 4,
                        color: 'var(--text-body)',
                      }}
                    >
                      경과: {formatMockElapsedMs(row.endedAt - row.startedAt)}
                    </div>
                    <div
                      style={{
                        display: 'flex',
                        justifyContent: 'space-between',
                        alignItems: 'baseline',
                        gap: 8,
                        color: 'var(--text-body)',
                      }}
                    >
                      <span>
                        문항 {row.totalQuestions} · 정답 {row.correctCount}
                      </span>
                      <span
                        style={{
                          flexShrink: 0,
                          fontWeight: 600,
                          color: 'var(--text-secondary)',
                        }}
                      >
                        {row.scoreFloored}점
                      </span>
                    </div>
                  </button>
                </li>
              ))}
            </ul>
          )}
        </section>
      </main>
    </div>
  )
}
