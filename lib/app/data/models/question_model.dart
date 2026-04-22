import 'package:freezed_annotation/freezed_annotation.dart';
import 'choice_model.dart';

part 'question_model.freezed.dart';
part 'question_model.g.dart';

@freezed
class QuestionModel with _$QuestionModel {
  const factory QuestionModel({
    required String id,
    required String exam_type,
    required String subject,
    required String exam_session,
    required int question_number,
    required String question_text,
    String? question_image_url,
    required List<ChoiceModel> choices,
    required int correct_answer,
    required List<String> keywords,
  }) = _QuestionModel;

  factory QuestionModel.fromJson(Map<String, dynamic> json) =>
      _$QuestionModelFromJson(json);
}
