import 'models/question_model.dart';

/// GitHub raw 이미지 URL. `{question_id}`는 [QuestionModel.id]로만 치환한다.
/// JSON의 `question_image_url` 필드는 사용하지 않는다.
const String kQuestionImageUrlTemplate =
    'https://raw.githubusercontent.com/idlepoe/repeat_exam/main/assets/images/{question_id}.png';

String? resolveQuestionImageSrc(QuestionModel q) {
  final id = q.id.trim();
  if (id.isEmpty) return null;
  return kQuestionImageUrlTemplate.replaceAll('{question_id}', id);
}
