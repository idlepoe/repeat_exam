import type { Question } from '../types/question'

/** GitHub raw 이미지 URL (`{question_id}` → 문항 `id`). `question_image_url` 필드는 사용하지 않는다. */
export const QUESTION_IMAGE_URL_TEMPLATE =
  'https://raw.githubusercontent.com/idlepoe/repeat_exam/main/assets/images/{question_id}.png'

/**
 * JSON의 `question_image_url`은 무시하고, 문항 `id`만으로 위 템플릿 URL을 만든다.
 * `id`가 비어 있으면 `null`.
 */
export function resolveQuestionImageSrc(q: Question): string | null {
  const id = q.id?.trim()
  if (!id) return null
  return QUESTION_IMAGE_URL_TEMPLATE.replaceAll('{question_id}', id)
}
