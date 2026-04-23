/** 시험 JSON URL: GitHub Raw /assets/json/exams/{pastry|bread}_YYYYMMDD.json */
export function examJsonUrl(examType: string, examSession: string): string {
  const ymd = examSession.replace(/-/g, '')
  const rawBaseUrl =
    'https://raw.githubusercontent.com/idlepoe/repeat_exam/main/assets/json/exams'
  if (examType === '제과기능사') {
    return `${rawBaseUrl}/pastry_${ymd}.json`
  }
  if (examType === '제빵기능사') {
    return `${rawBaseUrl}/bread_${ymd}.json`
  }
  throw new Error(`알 수 없는 시험 종류: ${examType}`)
}
