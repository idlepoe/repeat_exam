import { useEffect } from 'react'
import { Navigate, Route, Routes } from 'react-router-dom'
import { AppShell } from './components/AppShell'
import { loadThemePreference } from './lib/storage'
import {
  applyThemeToDocument,
  resolveEffectiveTheme,
  subscribeSystemTheme,
} from './lib/theme'
import { ExamTypeListPage } from './pages/ExamTypeListPage'
import { ExamSessionListPage } from './pages/ExamSessionListPage'
import { MockExamHistoryDetailPage } from './pages/MockExamHistoryDetailPage'
import { MockExamPage } from './pages/MockExamPage'
import { OptionsPage } from './pages/OptionsPage'
import { QuestionPage } from './pages/QuestionPage'

function App() {
  useEffect(() => {
    const apply = () => {
      applyThemeToDocument(resolveEffectiveTheme(loadThemePreference()))
    }
    apply()

    let unsubMq: (() => void) | undefined
    const attachMqIfNeeded = () => {
      unsubMq?.()
      unsubMq = undefined
      if (loadThemePreference() === 'system') {
        unsubMq = subscribeSystemTheme(apply)
      }
    }
    attachMqIfNeeded()

    const onThemeChanged = () => {
      apply()
      attachMqIfNeeded()
    }
    window.addEventListener('repeat_exam:theme_changed', onThemeChanged)
    return () => {
      window.removeEventListener('repeat_exam:theme_changed', onThemeChanged)
      unsubMq?.()
    }
  }, [])

  return (
    <AppShell>
      <Routes>
        <Route path="/" element={<ExamTypeListPage />} />
        <Route path="/mock-quiz/:examKind" element={<MockExamPage />} />
        <Route
          path="/mock-history/:historyId"
          element={<MockExamHistoryDetailPage />}
        />
        <Route path="/options" element={<OptionsPage />} />
        <Route path="/sessions/:examType" element={<ExamSessionListPage />} />
        <Route
          path="/quiz/:examType/:examSession"
          element={<QuestionPage />}
        />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </AppShell>
  )
}

export default App
