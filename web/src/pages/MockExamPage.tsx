import { useEffect, useRef, useState, type CSSProperties, type ReactNode } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import {
  buildMockExamQuestions,
  countCorrectAnswers,
  isMockExamPassed,
  mockExamScoreFloored,
} from '../lib/mockExamBuild'
import { navigateToExamTypeListAfterMockExamComplete } from '../lib/mockExamNavigation'
import {
  appendMockHistory,
  clearMockSession,
  loadMockSession,
  saveMockSession,
  type MockExamKind,
} from '../lib/mockExamStorage'
import {
  loadAnswerHighlight,
  loadNavReversed,
  saveNavReversed,
} from '../lib/storage'
import { BottomNavButtons } from '../components/BottomNavButtons'
import type { Question } from '../types/question'

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

function isMockKind(s: string): s is MockExamKind {
  return s === '제빵기능사' || s === '제과기능사'
}

export function MockExamPage() {
  const { examKind: ek } = useParams<{ examKind: string }>()
  const navigate = useNavigate()
  const examKind = ek ? decodeURIComponent(ek) : ''

  const [ready, setReady] = useState(false)
  const [loadErr, setLoadErr] = useState<string | null>(null)
  const [questions, setQuestions] = useState<Question[]>([])
  const [index, setIndex] = useState(0)
  const [answers, setAnswers] = useState<Record<string, number>>({})
  const [startedAt, setStartedAt] = useState(0)
  const [remainMs, setRemainMs] = useState(EXAM_MS)
  const [navReversed, setNavReversed] = useState(() => loadNavReversed())
  const [answerHighlight] = useState(() => loadAnswerHighlight())

  const [showTimeUpDialog, setShowTimeUpDialog] = useState(false)
  const [showEndConfirm, setShowEndConfirm] = useState(false)
  const [showAnswerSheet, setShowAnswerSheet] = useState(false)
  const [showIncompleteDialog, setShowIncompleteDialog] = useState(false)
  /** 마지막 문항 선택 직후 미완료 체크용 (state 배치 전 스냅샷) */
  const [incompleteAnswersSnapshot, setIncompleteAnswersSnapshot] =
    useState<Record<string, number> | null>(null)
  const [showResultDialog, setShowResultDialog] = useState(false)
  const [resultSummary, setResultSummary] = useState<{
    passed: boolean
    correct: number
    score: number
  } | null>(null)

  const timeUpFiredRef = useRef(false)
  /** false면 localStorage에 모의고사 세션을 쓰지 않음(종료·제출 후 persist 재저장 방지) */
  const sessionPersistEnabledRef = useRef(true)
  const mainRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    mainRef.current?.scrollTo(0, 0)
  }, [index])

  useEffect(() => {
    saveNavReversed(navReversed)
  }, [navReversed])

  useEffect(() => {
    if (!isMockKind(examKind)) {
      navigate('/', { replace: true })
      return
    }

    sessionPersistEnabledRef.current = true

    let cancelled = false
    void (async () => {
      const stored = loadMockSession()
      if (
        stored &&
        stored.examKind === examKind &&
        stored.questions.length === MOCK_TOTAL
      ) {
        if (!cancelled) {
          setQuestions(stored.questions)
          setAnswers(stored.answers)
          setIndex(stored.currentIndex)
          setStartedAt(stored.startedAt)
          setReady(true)
          setLoadErr(null)
        }
        return
      }

      clearMockSession()
      try {
        const qs = await buildMockExamQuestions(examKind)
        const start = Date.now()
        if (!cancelled) {
          setQuestions(qs)
          setAnswers({})
          setIndex(0)
          setStartedAt(start)
          saveMockSession({
            examKind,
            questions: qs,
            answers: {},
            currentIndex: 0,
            startedAt: start,
          })
          setReady(true)
          setLoadErr(null)
        }
      } catch (e) {
        if (!cancelled) {
          setLoadErr(e instanceof Error ? e.message : '모의고사 준비 실패')
          setReady(false)
        }
      }
    })()

    return () => {
      cancelled = true
    }
  }, [examKind, navigate])

  useEffect(() => {
    if (!ready || startedAt <= 0) return
    const tick = () => {
      const left = startedAt + EXAM_MS - Date.now()
      setRemainMs(left)
      if (left <= 0 && !timeUpFiredRef.current) {
        timeUpFiredRef.current = true
        setShowTimeUpDialog(true)
      }
    }
    tick()
    const id = window.setInterval(tick, 1000)
    return () => window.clearInterval(id)
  }, [ready, startedAt])

  useEffect(() => {
    if (!sessionPersistEnabledRef.current) {
      if (import.meta.env.DEV) {
        console.log('[MockExam]', 'persist skipped (세션 종료됨)')
      }
      return
    }
    if (!ready || questions.length !== MOCK_TOTAL || !isMockKind(examKind)) return
    if (import.meta.env.DEV) {
      console.log('[MockExam]', 'persist effect: saveMockSession')
    }
    saveMockSession({
      examKind,
      questions,
      answers,
      currentIndex: index,
      startedAt,
    })
  }, [answers, examKind, index, questions, ready, startedAt])

  const q = questions[index]

  const pickChoice = (choiceNo: number) => {
    if (!q) return
    const nextAnswers = { ...answers, [q.id]: choiceNo }
    setAnswers(nextAnswers)
    if (index < MOCK_TOTAL - 1) {
      setIndex((i) => i + 1)
    } else {
      handleLastQuestionNav(nextAnswers)
    }
  }

  const handleLastQuestionNav = (nextAnswers: Record<string, number>) => {
    const unanswered = questions.findIndex((qq) => nextAnswers[qq.id] === undefined)
    if (unanswered >= 0) {
      setIncompleteAnswersSnapshot(nextAnswers)
      setShowIncompleteDialog(true)
      return
    }
    finishExam(nextAnswers)
  }

  const finishExam = (finalAnswers: Record<string, number>) => {
    const endedAt = Date.now()
    const correct = countCorrectAnswers(questions, finalAnswers)
    const score = mockExamScoreFloored(correct)
    const passed = isMockExamPassed(score)

    console.log('[MockExam]', 'finishExam: start', {
      correct,
      score,
      passed,
      answerKeys: Object.keys(finalAnswers).length,
    })

    sessionPersistEnabledRef.current = false

    appendMockHistory({
      examKind: examKind as MockExamKind,
      startedAt,
      endedAt,
      correctCount: correct,
      totalQuestions: MOCK_TOTAL,
      scoreFloored: score,
      passed,
      questions,
      answers: finalAnswers,
    })
    clearMockSession('finishExam')
    console.log('[MockExam]', 'finishExam: after clearMockSession, opening result dialog')

    setResultSummary({ passed, correct, score })
    setShowResultDialog(true)
  }

  const goNext = () => {
    if (questions.length === 0) return
    if (index < MOCK_TOTAL - 1) {
      setIndex((i) => i + 1)
      return
    }
    handleLastQuestionNav(answers)
  }

  const goPrev = () => {
    if (index > 0) setIndex((i) => i - 1)
  }

  const confirmEndExam = () => {
    sessionPersistEnabledRef.current = false
    clearMockSession('confirmEndExam')
    setShowEndConfirm(false)
    navigate(-1)
  }

  if (!isMockKind(examKind)) {
    return null
  }

  if (loadErr) {
    return (
      <div style={{ padding: 16 }}>
        <p style={{ color: 'crimson' }}>{loadErr}</p>
        <button type="button" onClick={() => navigate('/')}>
          목록으로
        </button>
      </div>
    )
  }

  if (!ready || !q) {
    return (
      <div style={{ padding: 24 }}>
        <p>모의고사 준비 중…</p>
      </div>
    )
  }

  const timeLabel = `${formatRemainMs(remainMs)} / 60`

  return (
    <div
      style={{
        height: '100svh',
        display: 'flex',
        flexDirection: 'column',
        overflow: 'hidden',
        maxWidth: '100%',
      }}
    >
      <header
        style={{
          position: 'sticky',
          top: 0,
          zIndex: 10,
          display: 'flex',
          flexWrap: 'wrap',
          alignItems: 'center',
          gap: 8,
          minHeight: 48,
          padding: '8px 10px',
          borderBottom: '1px solid #e5e4e7',
          background: '#fff',
          boxSizing: 'border-box',
        }}
      >
        <button
          type="button"
          onClick={() => navigate(-1)}
          style={{
            padding: '6px 10px',
            border: '1px solid #ccc',
            borderRadius: 6,
            background: '#f8f8f8',
            cursor: 'pointer',
            fontSize: 13,
          }}
        >
          뒤로가기
        </button>
        <div
          style={{
            flex: '1 1 120px',
            fontWeight: 600,
            fontSize: 14,
            textAlign: 'center',
          }}
        >
          {timeLabel}
        </div>
        <button
          type="button"
          onClick={() => setShowEndConfirm(true)}
          style={{
            padding: '6px 10px',
            border: '1px solid #c44',
            borderRadius: 6,
            background: '#fff5f5',
            color: '#b00',
            cursor: 'pointer',
            fontSize: 13,
          }}
        >
          시험종료
        </button>
        <button
          type="button"
          onClick={() => setShowAnswerSheet(true)}
          style={{
            padding: '6px 10px',
            border: '1px solid #ccc',
            borderRadius: 6,
            background: '#fff',
            cursor: 'pointer',
            fontSize: 13,
          }}
        >
          답안확인
        </button>
      </header>

      <main
        ref={mainRef}
        style={{
          flex: 1,
          minHeight: 0,
          overflowY: 'auto',
          WebkitOverflowScrolling: 'touch',
          padding: 16,
          paddingBottom: 8,
          fontSize: 16,
          lineHeight: 1.5,
          textAlign: 'left',
        }}
      >
        <div
          style={{
            fontSize: 15,
            fontWeight: 600,
            marginBottom: 8,
            color: '#333',
          }}
        >
          [{q.subject}] {index + 1}/{MOCK_TOTAL}
        </div>
        <p style={{ margin: '0 0 16px' }}>
          <span style={{ fontWeight: 600 }}>{index + 1}.</span> {q.question_text}
        </p>

        {q.question_image_url ? (
          <div style={{ marginBottom: 16 }}>
            <img
              src={q.question_image_url}
              alt=""
              style={{ maxWidth: '100%', height: 'auto' }}
            />
          </div>
        ) : null}

        <ul
          style={{
            listStyle: 'none',
            padding: 0,
            margin: 0,
          }}
        >
          {q.choices.map((c) => {
            const picked = answers[q.id]
            const isSel = picked === c.no
            return (
              <li key={c.no} style={{ marginBottom: 10 }}>
                <button
                  type="button"
                  onClick={() => pickChoice(c.no)}
                  style={{
                    width: '100%',
                    textAlign: 'left',
                    padding: '10px 12px',
                    border: '1px solid #ddd',
                    borderRadius: 6,
                    background: isSel ? answerHighlight.bg : '#fafafa',
                    color: isSel ? answerHighlight.fg : '#111',
                    cursor: 'pointer',
                    fontSize: 16,
                  }}
                >
                  {c.no}. {c.text}
                </button>
              </li>
            )
          })}
        </ul>
      </main>

      <BottomNavButtons
        navReversed={navReversed}
        prevDisabled={index <= 0}
        onPrev={goPrev}
        onNext={goNext}
        onToggleOrder={() => setNavReversed((v) => !v)}
      />

      {showTimeUpDialog && (
        <ModalOverlay>
          <ModalCard title="안내">
            <p style={{ marginBottom: 16 }}>시험 시간(60분)이 지났습니다.</p>
            <button
              type="button"
              onClick={() => setShowTimeUpDialog(false)}
              style={modalPrimaryBtn}
            >
              확인
            </button>
          </ModalCard>
        </ModalOverlay>
      )}

      {showEndConfirm && (
        <ModalOverlay>
          <ModalCard title="모의고사 종료">
            <p style={{ marginBottom: 16 }}>모의고사를 종료하시겠습니까?</p>
            <div style={{ display: 'flex', gap: 8, flexDirection: 'column' }}>
              <button type="button" onClick={confirmEndExam} style={modalPrimaryBtn}>
                확인
              </button>
              <button
                type="button"
                onClick={() => setShowEndConfirm(false)}
                style={modalSecondaryBtn}
              >
                취소
              </button>
            </div>
          </ModalCard>
        </ModalOverlay>
      )}

      {showAnswerSheet && (
        <ModalOverlay>
          <ModalCard title="답안 확인">
            <div
              style={{
                maxHeight: '60vh',
                overflowY: 'auto',
                marginBottom: 12,
              }}
            >
              {questions.map((qq, i) => {
                const ans = answers[qq.id]
                const label =
                  ans !== undefined ? `${ans}번` : ''
                return (
                  <button
                    key={qq.id}
                    type="button"
                    onClick={() => {
                      setIndex(i)
                      setShowAnswerSheet(false)
                    }}
                    style={{
                      display: 'block',
                      width: '100%',
                      textAlign: 'left',
                      padding: '10px 8px',
                      border: 'none',
                      borderBottom: '1px solid #eee',
                      background: i === index ? '#f0f7ff' : '#fff',
                      cursor: 'pointer',
                    }}
                  >
                    <div style={{ fontWeight: 600, fontSize: 13 }}>
                      {i + 1}.{' '}
                      <span
                        style={{
                          display: 'inline-block',
                          maxWidth: '100%',
                          overflow: 'hidden',
                          textOverflow: 'ellipsis',
                          whiteSpace: 'nowrap',
                          verticalAlign: 'bottom',
                        }}
                      >
                        {qq.question_text}
                      </span>
                    </div>
                    <div style={{ fontSize: 13, color: '#666', marginTop: 4 }}>
                      답안:{' '}
                      {label || (
                        <span style={{ color: '#ccc' }} aria-label="미응답">
                          —
                        </span>
                      )}
                    </div>
                  </button>
                )
              })}
            </div>
            <button
              type="button"
              onClick={() => setShowAnswerSheet(false)}
              style={modalSecondaryBtn}
            >
              닫기
            </button>
          </ModalCard>
        </ModalOverlay>
      )}

      {showIncompleteDialog && (
        <ModalOverlay>
          <ModalCard title="안내">
            <p style={{ marginBottom: 16 }}>
              풀지 않은 문제가 있습니다. 이동하시겠습니까?
            </p>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
              <button
                type="button"
                onClick={() => {
                  const map = incompleteAnswersSnapshot ?? answers
                  const ui = questions.findIndex((qq) => map[qq.id] === undefined)
                  if (ui >= 0) setIndex(ui)
                  setIncompleteAnswersSnapshot(null)
                  setShowIncompleteDialog(false)
                }}
                style={modalPrimaryBtn}
              >
                해당 문제로 이동
              </button>
              <button
                type="button"
                onClick={() => {
                  setIncompleteAnswersSnapshot(null)
                  setShowIncompleteDialog(false)
                }}
                style={modalSecondaryBtn}
              >
                닫기
              </button>
            </div>
          </ModalCard>
        </ModalOverlay>
      )}

      {showResultDialog && resultSummary && (
        <ModalOverlay>
          <ModalCard title="결과">
            <p style={{ marginBottom: 8, whiteSpace: 'pre-line', lineHeight: 1.5 }}>
              {resultSummary.passed ? '합격' : '불합격'}하셨습니다.
              {'\n'}
              {resultSummary.correct}/{MOCK_TOTAL}
              {'\n'}점수 {resultSummary.score}
            </p>
            <p style={{ marginBottom: 16 }}>수고하셨습니다.</p>
            <button
              type="button"
              onClick={() => {
                setShowResultDialog(false)
                navigateToExamTypeListAfterMockExamComplete(navigate)
              }}
              style={modalPrimaryBtn}
            >
              확인
            </button>
          </ModalCard>
        </ModalOverlay>
      )}
    </div>
  )
}

const modalPrimaryBtn: CSSProperties = {
  width: '100%',
  padding: '12px',
  fontSize: 16,
  border: '1px solid #333',
  borderRadius: 8,
  background: '#222',
  color: '#fff',
  cursor: 'pointer',
}

const modalSecondaryBtn: CSSProperties = {
  width: '100%',
  padding: '12px',
  fontSize: 16,
  border: '1px solid #ccc',
  borderRadius: 8,
  background: '#f5f5f5',
  cursor: 'pointer',
}

function ModalOverlay({ children }: { children: ReactNode }) {
  return (
    <div
      role="presentation"
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
      {children}
    </div>
  )
}

function ModalCard({
  title,
  children,
}: {
  title: string
  children: React.ReactNode
}) {
  return (
    <div
      role="dialog"
      aria-modal="true"
      style={{
        background: '#fff',
        borderRadius: 12,
        padding: 20,
        maxWidth: 400,
        width: '100%',
        boxShadow: '0 8px 24px rgba(0,0,0,0.2)',
      }}
    >
      <p style={{ margin: '0 0 14px', fontSize: 17, fontWeight: 600 }}>{title}</p>
      {children}
    </div>
  )
}
