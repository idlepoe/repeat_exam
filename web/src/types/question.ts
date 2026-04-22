export interface Choice {
  no: number
  text: string
}

export interface Question {
  id: string
  exam_type: string
  exam_session: string
  subject: string
  question_number: number
  question_text: string
  question_image_url: string | null
  choices: Choice[]
  correct_answer: number
  keywords: string[]
}
