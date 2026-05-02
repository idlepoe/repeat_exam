import { Navigate, Route, Routes } from 'react-router-dom'
import { AppShell } from './components/AppShell'
import { ExamTypeListPage } from './pages/ExamTypeListPage'
import { ExamSessionListPage } from './pages/ExamSessionListPage'
import { MockExamHistoryDetailPage } from './pages/MockExamHistoryDetailPage'
import { MockExamPage } from './pages/MockExamPage'
import { OptionsPage } from './pages/OptionsPage'
import { QuestionPage } from './pages/QuestionPage'

function App() {
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
