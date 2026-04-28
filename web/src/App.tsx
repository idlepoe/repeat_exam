import { Navigate, Route, Routes } from 'react-router-dom'
import { ExamTypeListPage } from './pages/ExamTypeListPage'
import { ExamSessionListPage } from './pages/ExamSessionListPage'
import { OptionsPage } from './pages/OptionsPage'
import { QuestionPage } from './pages/QuestionPage'

function App() {
  return (
    <Routes>
      <Route path="/" element={<ExamTypeListPage />} />
      <Route path="/options" element={<OptionsPage />} />
      <Route path="/sessions/:examType" element={<ExamSessionListPage />} />
      <Route path="/quiz/:examType/:examSession" element={<QuestionPage />} />
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  )
}

export default App
