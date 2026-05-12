import 'package:flutter/material.dart';

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

/// [resolveQuestionImageSrc]로 만든 URL 이미지. 로드 실패·404 시 빈 위젯.
class QuestionNetworkImage extends StatelessWidget {
  const QuestionNetworkImage({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      frameBuilder: (context, child, frame, _) {
        if (frame == null) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: child,
        );
      },
      errorBuilder: (context, error, stackTrace) =>
          const SizedBox.shrink(),
    );
  }
}
