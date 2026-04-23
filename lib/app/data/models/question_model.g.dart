// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QuestionModelImpl _$$QuestionModelImplFromJson(Map<String, dynamic> json) =>
    _$QuestionModelImpl(
      id: json['id'] as String,
      exam_type: json['exam_type'] as String,
      subject: json['subject'] as String,
      exam_session: json['exam_session'] as String,
      question_number: (json['question_number'] as num).toInt(),
      question_text: json['question_text'] as String,
      question_image_url: json['question_image_url'] as String?,
      choices: (json['choices'] as List<dynamic>)
          .map((e) => ChoiceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      correct_answer: (json['correct_answer'] as num).toInt(),
      keywords: (json['keywords'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      aiExplanation: json['aiExplanation'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$QuestionModelImplToJson(_$QuestionModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'exam_type': instance.exam_type,
      'subject': instance.subject,
      'exam_session': instance.exam_session,
      'question_number': instance.question_number,
      'question_text': instance.question_text,
      'question_image_url': instance.question_image_url,
      'choices': instance.choices,
      'correct_answer': instance.correct_answer,
      'keywords': instance.keywords,
      'aiExplanation': instance.aiExplanation,
    };
