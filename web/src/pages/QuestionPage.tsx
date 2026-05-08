import { useEffect, useRef, useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import { AppBar } from '../components/AppBar'
import { BottomNavButtons } from '../components/BottomNavButtons'
import { questionFontByStep } from '../lib/questionFont'
import { examJsonUrl } from '../lib/examFiles'
import { fetchExamSessionList, nextSession } from '../lib/examMeta'
import {
  clearProgress,
  incrementSessionCountAndClearProgress,
  hasReportedQuestion,
  loadAnswerHighlight,
  loadNavReversed,
  loadQuestionFontStep,
  loadProgress,
  saveReportedQuestion,
  saveNavReversed,
  saveProgress,
} from '../lib/storage'
import { submitQuestionReport, type ReportType } from '../lib/report'
import type { Question } from '../types/question'

const REPORT_TYPES: ReportType[] = [
  '사진 누락',
  '내용 누락',
  '정답 오류',
  '띄어쓰기 오류',
]

export function QuestionPage() {
  const { examType: et, examSession: es } = useParams<{
    examType: string
    examSession: string
  }>()
  const navigate = useNavigate()
  const examType = et ? decodeURIComponent(et) : ''
  const examSession = es ? decodeURIComponent(es) : ''

  const [questions, setQuestions] = useState<Question[]>([])
  const [loadErr, setLoadErr] = useState<string | null>(null)
  const [index, setIndex] = useState(0)
  const [navReversed, setNavReversed] = useState(() => loadNavReversed())
  const [fontStep] = useState(() => loadQuestionFontStep())
  const [showNextSessionDialog, setShowNextSessionDialog] = useState(false)
  const [showReportDialog, setShowReportDialog] = useState(false)
  const [reportSubmitting, setReportSubmitting] = useState(false)
  const [reportToastVisible, setReportToastVisible] = useState(false)
  const [answerHighlight] = useState(() => loadAnswerHighlight())
  const [loadedSessionKey, setLoadedSessionKey] = useState<string | null>(null)
  const mainRef = useRef<HTMLDivElement>(null)
  const currentSessionKey = `${examType}::${examSession}`

  useEffect(() => {
    mainRef.current?.scrollTo(0, 0)
  }, [index, examType, examSession])

  useEffect(() => {
    if (!examType || !examSession) return
    let cancelled = false

    void (async () => {
      setLoadedSessionKey(null)
      setQuestions([])
      setIndex(0)
      setLoadErr(null)
      try {
        const url = examJsonUrl(examType, examSession)
        const res = await fetch(url)
        if (!res.ok) {
          throw new Error(`문제 파일을 불러올 수 없습니다. (${res.status})`)
        }
        const data = (await res.json()) as Question[]
        if (!Array.isArray(data) || data.length === 0) {
          throw new Error('문제 데이터가 비어 있습니다.')
        }
        const sorted = [...data].sort(
          (a, b) => a.question_number - b.question_number
        )
        const saved = loadProgress(examType, examSession)
        let start = 0
        if (
          saved &&
          saved.exam_type === examType &&
          saved.exam_session === examSession
        ) {
          const i = sorted.findIndex(
            (q) => q.question_number === saved.question_number
          )
          if (i >= 0) start = i
        }
        if (!cancelled) {
          setQuestions(sorted)
          setIndex(start)
          setLoadedSessionKey(currentSessionKey)
        }
      } catch (e) {
        if (!cancelled) {
          setLoadErr(e instanceof Error ? e.message : '로드 실패')
          setQuestions([])
          setLoadedSessionKey(null)
        }
      }
    })()

    return () => {
      cancelled = true
    }
  }, [examType, examSession, currentSessionKey])

  const q = questions[index]
  const isAlreadyReported = q ? hasReportedQuestion(q.id) : false

  useEffect(() => {
    if (!q) return
    if (loadedSessionKey !== currentSessionKey) return
    saveProgress(
      {
        exam_type: examType,
        exam_session: examSession,
        question_number: q.question_number,
      },
      examType,
      examSession
    )
  }, [q, examType, examSession, loadedSessionKey, currentSessionKey])

  useEffect(() => {
    saveNavReversed(navReversed)
  }, [navReversed])

  useEffect(() => {
    const sync = () => setNavReversed(loadNavReversed())
    window.addEventListener('repeat_exam:nav_reversed_changed', sync)
    return () =>
      window.removeEventListener('repeat_exam:nav_reversed_changed', sync)
  }, [])

  useEffect(() => {
    if (!reportToastVisible) return
    const timer = window.setTimeout(() => {
      setReportToastVisible(false)
    }, 2200)
    return () => {
      window.clearTimeout(timer)
    }
  }, [reportToastVisible])

  const goPrev = () => {
    if (index > 0) setIndex((i) => i - 1)
  }

  const goNext = () => {
    if (questions.length === 0) return
    if (index < questions.length - 1) {
      setIndex((i) => i + 1)
      return
    }
    setShowNextSessionDialog(true)
  }

  const handleNextSessionConfirm = async () => {
    setShowNextSessionDialog(false)
    incrementSessionCountAndClearProgress(examType, examSession)
    try {
      const meta = await fetchExamSessionList()
      const next = nextSession(meta, examType, examSession)
      if (!next) {
        window.alert('이어질 다음 회차가 없습니다.')
        return
      }
      // 다음 회차는 항상 1번부터 시작하도록 기존 진도를 지운다.
      clearProgress(examType, next)
      navigate(
        `/quiz/${encodeURIComponent(examType)}/${encodeURIComponent(next)}`
      )
    } catch (e) {
      window.alert(
        e instanceof Error ? e.message : '다음 회차 정보를 불러올 수 없습니다.'
      )
    }
  }

  const handleReport = async (type: ReportType) => {
    if (!q || reportSubmitting) return
    if (hasReportedQuestion(q.id)) {
      window.alert('이미 신고한 문제입니다.')
      setShowReportDialog(false)
      return
    }
    setReportSubmitting(true)
    try {
      await submitQuestionReport({
        questionId: q.id,
        type,
        examType,
        examSession,
      })
      saveReportedQuestion(q.id)
      setShowReportDialog(false)
      setReportToastVisible(true)
    } catch (e) {
      window.alert(e instanceof Error ? e.message : '신고 처리에 실패했습니다.')
    } finally {
      setReportSubmitting(false)
    }
  }

  const { base: baseFont, title: titleFs } = questionFontByStep(fontStep)

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
      <AppBar
        title={examSession ? `${examType}\n${examSession}회` : examType}
        showBack
        onBack={() =>
          navigate(`/sessions/${encodeURIComponent(examType)}`)
        }
        right={
          <button
            type="button"
            onClick={() => navigate('/options')}
            style={{
              padding: '6px 10px',
              fontSize: 14,
              border: '1px solid var(--border-subtle)',
              borderRadius: 6,
              background: 'var(--bg-surface)',
              color: 'var(--text-primary)',
              cursor: 'pointer',
            }}
          >
            옵션
          </button>
        }
      />

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
        {loadErr && (
          <p style={{ color: 'var(--color-danger)', marginBottom: 12 }}>
            {loadErr}
          </p>
        )}
        {!q && !loadErr && (
          <p style={{ color: 'var(--text-secondary)' }}>불러오는 중…</p>
        )}

        {q && (
          <>
            <div
              style={{
                fontSize: titleFs,
                fontWeight: 600,
                marginBottom: 8,
                color: 'var(--text-secondary)',
              }}
            >
              [{q.subject}]
            </div>
            <p style={{ margin: '0 0 16px' }}>
              <span style={{ fontWeight: 600 }}>{q.question_number}.</span>{' '}
              {q.question_text}
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
                const isAnswer = c.no === q.correct_answer
                return (
                  <li
                    key={c.no}
                    style={{
                      marginBottom: 10,
                      padding: '10px 12px',
                      border: '1px solid var(--border-muted)',
                      borderRadius: 6,
                      background: isAnswer ? answerHighlight.bg : 'var(--bg-choice)',
                      color: isAnswer ? answerHighlight.fg : 'var(--text-primary)',
                    }}
                  >
                    {c.no}. {c.text}
                  </li>
                )
              })}
            </ul>

            {q.aiExplanation ? (
              <section
                style={{
                  marginTop: 18,
                  padding: 12,
                  border: '1px solid var(--border-default)',
                  borderRadius: 8,
                  background: 'var(--bg-surface)',
                  color: 'var(--text-primary)',
                }}
                aria-label="AI 해설"
              >
                <h3 style={{ margin: '0 0 8px', fontSize: 16 }}>AI 해설</h3>

                <p style={{ margin: '0 0 10px' }}>
                  <strong>정답 해설</strong>
                  <br />
                  {q.aiExplanation.correctExplanation}
                </p>

                <div style={{ marginBottom: 10 }}>
                  <strong>오답 노트</strong>
                  <ul style={{ margin: '6px 0 0 18px', padding: 0 }}>
                    {q.aiExplanation.wrongAnswerNotes.map((note, i) => (
                      <li key={`${q.id}-ai-note-${i}`} style={{ marginBottom: 4 }}>
                        {note}
                      </li>
                    ))}
                  </ul>
                </div>

                <p style={{ margin: 0 }}>
                  <strong>쪽집게</strong>
                  <br />
                  {q.aiExplanation.examTip}
                </p>
              </section>
            ) : null}
            <div style={{ marginTop: 18 }}>
              <button
                type="button"
                onClick={() => setShowReportDialog(true)}
                disabled={isAlreadyReported}
                style={{
                  width: '100%',
                  padding: '10px 12px',
                  fontSize: 14,
                  border: '1px solid var(--border-report)',
                  borderRadius: 8,
                  background: 'var(--bg-surface)',
                  color: isAlreadyReported
                    ? 'var(--text-disabled)'
                    : 'var(--text-secondary)',
                  cursor: isAlreadyReported ? 'not-allowed' : 'pointer',
                }}
              >
                {isAlreadyReported ? '이미 신고한 문제입니다' : '문제 오류 신고 하기'}
              </button>
            </div>
          </>
        )}
      </main>

      {q ? (
        <>
          <BottomNavButtons
            navReversed={navReversed}
            prevDisabled={index <= 0}
            onPrev={goPrev}
            onNext={goNext}
          />
        </>
      ) : null}

      {showNextSessionDialog && (
        <div
          role="dialog"
          aria-modal="true"
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
          <div
            style={{
              background: 'var(--bg-surface)',
              borderRadius: 12,
              padding: 20,
              maxWidth: 360,
              width: '100%',
              boxShadow: 'var(--shadow-dialog)',
              color: 'var(--text-primary)',
            }}
          >
            <p style={{ margin: '0 0 16px', fontSize: 17, fontWeight: 600 }}>
              다음 회차로 이동할까요?
            </p>
            <div
              style={{
                display: 'flex',
                flexDirection: 'column',
                gap: 8,
              }}
            >
              <button
                type="button"
                onClick={() => setShowNextSessionDialog(false)}
                style={{
                  padding: '12px',
                  fontSize: 16,
                  border: '1px solid var(--border-subtle)',
                  borderRadius: 8,
                  background: 'var(--bg-subtle)',
                  color: 'var(--text-primary)',
                  cursor: 'pointer',
                }}
              >
                취소
              </button>
              <button
                type="button"
                onClick={() => {
                  setShowNextSessionDialog(false)
                  incrementSessionCountAndClearProgress(
                    examType,
                    examSession
                  )
                  navigate(`/sessions/${encodeURIComponent(examType)}`)
                }}
                style={{
                  padding: '12px',
                  fontSize: 16,
                  border: '1px solid var(--border-subtle)',
                  borderRadius: 8,
                  background: 'var(--bg-surface)',
                  color: 'var(--text-primary)',
                  cursor: 'pointer',
                }}
              >
                목록
              </button>
              <button
                type="button"
                onClick={handleNextSessionConfirm}
                style={{
                  padding: '12px',
                  fontSize: 16,
                  border: '1px solid var(--dialog-primary-border)',
                  borderRadius: 8,
                  background: 'var(--dialog-primary-bg)',
                  color: 'var(--text-inverse)',
                  cursor: 'pointer',
                }}
              >
                다음 회차
              </button>
            </div>
          </div>
        </div>
      )}
      {showReportDialog && q && (
        <div
          role="dialog"
          aria-modal="true"
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
          <div
            style={{
              background: 'var(--bg-surface)',
              borderRadius: 12,
              padding: 20,
              maxWidth: 360,
              width: '100%',
              boxShadow: 'var(--shadow-dialog)',
              color: 'var(--text-primary)',
            }}
          >
            <p style={{ margin: '0 0 14px', fontSize: 17, fontWeight: 600 }}>
              오류 유형을 선택해 주세요.
            </p>
            <div
              style={{
                display: 'flex',
                flexDirection: 'column',
                gap: 8,
                marginBottom: 8,
              }}
            >
              {REPORT_TYPES.map((type) => (
                <button
                  key={type}
                  type="button"
                  onClick={() => {
                    void handleReport(type)
                  }}
                  disabled={reportSubmitting || isAlreadyReported}
                  style={{
                    padding: '12px',
                    fontSize: 16,
                    border: '1px solid var(--border-subtle)',
                    borderRadius: 8,
                    background: 'var(--bg-surface)',
                    cursor:
                      reportSubmitting || isAlreadyReported
                        ? 'not-allowed'
                        : 'pointer',
                    color: 'var(--text-primary)',
                  }}
                >
                  {type}
                </button>
              ))}
            </div>
            <button
              type="button"
              onClick={() => setShowReportDialog(false)}
              disabled={reportSubmitting}
              style={{
                width: '100%',
                padding: '12px',
                fontSize: 16,
                border: '1px solid var(--border-subtle)',
                borderRadius: 8,
                background: 'var(--bg-subtle)',
                color: 'var(--text-primary)',
                cursor: reportSubmitting ? 'not-allowed' : 'pointer',
              }}
            >
              닫기
            </button>
          </div>
        </div>
      )}
      {reportToastVisible && (
        <div
          role="status"
          aria-live="polite"
          style={{
            position: 'fixed',
            left: '50%',
            bottom: 'calc(env(safe-area-inset-bottom, 0px) + 78px)',
            transform: 'translateX(-50%)',
            zIndex: 120,
            background: 'var(--bg-toast)',
            color: 'var(--toast-text)',
            padding: '10px 14px',
            borderRadius: 999,
            fontSize: 14,
            boxShadow: 'var(--shadow-toast)',
            maxWidth: 'calc(100% - 32px)',
            textAlign: 'center',
          }}
        >
          신고 감사합니다. 확인하고 고칠께요.
        </div>
      )}
    </div>
  )
}
