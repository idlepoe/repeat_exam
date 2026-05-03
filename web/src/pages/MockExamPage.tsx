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
  loadQuestionFontStep,
  saveNavReversed,
} from '../lib/storage'
import { questionFontByStep } from '../lib/questionFont'
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
  const [fontStep] = useState(() => loadQuestionFontStep())

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
  const { base: baseFont, title: titleFs } = questionFontByStep(fontStep)

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

  const pickChoiceRef = useRef(pickChoice)
  pickChoiceRef.current = pickChoice

  useEffect(() => {
    if (!ready || !q) return

    const ignoreWhenTyping = (t: HTMLElement | null) => {
      if (!t) return false
      const tag = t.tagName
      if (tag === 'INPUT' || tag === 'TEXTAREA' || tag === 'SELECT') return true
      if (t.isContentEditable) return true
      return false
    }

    const parseDigit14 = (e: KeyboardEvent): number | null => {
      const d = /^Digit([1-4])$/.exec(e.code)
      if (d) return Number(d[1])
      const n = /^Numpad([1-4])$/.exec(e.code)
      if (n) return Number(n[1])
      if (['1', '2', '3', '4'].includes(e.key)) return Number(e.key)
      return null
    }

    const onKeyDown = (e: KeyboardEvent) => {
      if (
        showTimeUpDialog ||
        showEndConfirm ||
        showAnswerSheet ||
        showIncompleteDialog ||
        showResultDialog
      ) {
        return
      }
      if (ignoreWhenTyping(e.target as HTMLElement | null)) return

      const digit = parseDigit14(e)
      if (digit === null) return
      if (!q.choices.some((c) => c.no === digit)) return

      e.preventDefault()
      pickChoiceRef.current(digit)
    }

    window.addEventListener('keydown', onKeyDown)
    return () => window.removeEventListener('keydown', onKeyDown)
  }, [
    ready,
    q,
    showTimeUpDialog,
    showEndConfirm,
    showAnswerSheet,
    showIncompleteDialog,
    showResultDialog,
  ])

  const confirmEndExam = () => {
    sessionPersistEnabledRef.current = false
    clearMockSession('confirmEndExam')
    setShowEndConfirm(false)
    navigateToExamTypeListAfterMockExamComplete(navigate)
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
          borderBottom: '1px solid var(--border-app-bar)',
          background: 'var(--bg-surface)',
          boxSizing: 'border-box',
        }}
      >
        <button
          type="button"
          onClick={() => navigate(-1)}
          style={{
            padding: '6px 10px',
            border: '1px solid var(--border-subtle)',
            borderRadius: 6,
            background: 'var(--bg-button-secondary)',
            color: 'var(--text-primary)',
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
            color: 'var(--text-primary)',
          }}
        >
          {timeLabel}
        </div>
        <button
          type="button"
          onClick={() => setShowEndConfirm(true)}
          style={{
            padding: '6px 10px',
            border: '1px solid var(--border-mock-warning)',
            borderRadius: 6,
            background: 'var(--bg-danger)',
            color: 'var(--color-danger)',
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
            border: '1px solid var(--border-subtle)',
            borderRadius: 6,
            background: 'var(--bg-surface)',
            color: 'var(--text-primary)',
            cursor: 'pointer',
            fontSize: 13,
          }}
        >
          답안확인
        </button>
        <button
          type="button"
          onClick={() => navigate('/options')}
          style={{
            padding: '6px 10px',
            border: '1px solid var(--border-subtle)',
            borderRadius: 6,
            background: 'var(--bg-surface)',
            color: 'var(--text-primary)',
            cursor: 'pointer',
            fontSize: 13,
          }}
        >
          옵션
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
          fontSize: baseFont,
          lineHeight: 1.5,
          textAlign: 'left',
          color: 'var(--text-primary)',
        }}
      >
        <div
          style={{
            fontSize: titleFs,
            fontWeight: 600,
            marginBottom: 8,
            color: 'var(--text-secondary)',
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
                    border: '1px solid var(--border-muted)',
                    borderRadius: 6,
                    background: isSel ? answerHighlight.bg : 'var(--bg-choice)',
                    color: isSel ? answerHighlight.fg : 'var(--text-primary)',
                    cursor: 'pointer',
                    fontSize: baseFont,
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
                      borderBottom: '1px solid var(--border-row)',
                      background:
                        i === index ? 'var(--bg-row-current)' : 'var(--bg-surface)',
                      cursor: 'pointer',
                    }}
                  >
                    <div
                      style={{
                        fontWeight: 600,
                        fontSize: 13,
                        color: 'var(--text-primary)',
                      }}
                    >
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
                    <div
                      style={{
                        fontSize: 13,
                        color: 'var(--text-subtle)',
                        marginTop: 4,
                      }}
                    >
                      답안:{' '}
                      {label || (
                        <span
                          style={{ color: 'var(--text-faint)' }}
                          aria-label="미응답"
                        >
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
  border: '1px solid var(--dialog-primary-border)',
  borderRadius: 8,
  background: 'var(--dialog-primary-bg)',
  color: 'var(--text-inverse)',
  cursor: 'pointer',
}

const modalSecondaryBtn: CSSProperties = {
  width: '100%',
  padding: '12px',
  fontSize: 16,
  border: '1px solid var(--border-subtle)',
  borderRadius: 8,
  background: 'var(--bg-subtle)',
  color: 'var(--text-primary)',
  cursor: 'pointer',
}

function ModalOverlay({ children }: { children: ReactNode }) {
  return (
    <div
      role="presentation"
      style={{
        position: 'fixed',
        inset: 0,
        background: 'var(--overlay-scrim)',
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
        background: 'var(--bg-surface)',
        borderRadius: 12,
        padding: 20,
        maxWidth: 400,
        width: '100%',
        boxShadow: 'var(--shadow-dialog)',
        color: 'var(--text-primary)',
      }}
    >
      <p style={{ margin: '0 0 14px', fontSize: 17, fontWeight: 600 }}>{title}</p>
      {children}
    </div>
  )
}
