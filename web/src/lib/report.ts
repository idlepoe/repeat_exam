import { addDoc, collection, serverTimestamp } from 'firebase/firestore'
import { db } from './firebase'

export type ReportType =
  | '사진 누락'
  | '내용 누락'
  | '정답 오류'
  | '띄어쓰기 오류'

export interface QuestionReportPayload {
  questionId: string
  type: ReportType
  examType: string
  examSession: string
}

export async function submitQuestionReport(
  payload: QuestionReportPayload
): Promise<void> {
  await addDoc(collection(db, 'report'), {
    questionId: payload.questionId,
    type: payload.type,
    examType: payload.examType,
    examSession: payload.examSession,
    createdAt: serverTimestamp(),
  })
}
