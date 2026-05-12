import type { Question } from '../types/question'

/** JSON에 저장된 GitHub raw 이미지 URL 템플릿(플레이스홀더). */
export const QUESTION_IMAGE_URL_TEMPLATE =
  'https://raw.githubusercontent.com/idlepoe/repeat_exam/main/assets/images/{question_id}.png'

const PREFIX =
  'https://raw.githubusercontent.com/idlepoe/repeat_exam/main/assets/images/'

/**
 * 위 템플릿(또는 동일 prefix + 해당 문항 id.png)일 때만 최종 이미지 URL을 반환한다.
 * 그 외 값은 표시하지 않는다.
 */
export function resolveQuestionImageSrc(q: Question): string | null {
  const raw = q.question_image_url?.trim()
  if (!raw) return null

  if (raw.includes('{question_id}')) {
    return raw.replaceAll('{question_id}', q.id)
  }

  const expected = `${PREFIX}${q.id}.png`
  if (raw === expected) return raw

  return null
}
