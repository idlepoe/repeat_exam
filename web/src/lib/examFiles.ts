/** 시험 JSON URL: /assets/json/exams/{pastry|bread}_YYYYMMDD.json */
export function examJsonUrl(examType: string, examSession: string): string {
  const ymd = examSession.replace(/-/g, '')
  if (examType === '제과기능사') {
    return `/assets/json/exams/pastry_${ymd}.json`
  }
  if (examType === '제빵기능사') {
    return `/assets/json/exams/bread_${ymd}.json`
  }
  throw new Error(`알 수 없는 시험 종류: ${examType}`)
}
