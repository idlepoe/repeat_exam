// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_meta_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExamTypeListModelImpl _$$ExamTypeListModelImplFromJson(
  Map<String, dynamic> json,
) => _$ExamTypeListModelImpl(
  title: json['title'] as String,
  exam_type_list: (json['exam_type_list'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$$ExamTypeListModelImplToJson(
  _$ExamTypeListModelImpl instance,
) => <String, dynamic>{
  'title': instance.title,
  'exam_type_list': instance.exam_type_list,
};

_$ExamSessionRowModelImpl _$$ExamSessionRowModelImplFromJson(
  Map<String, dynamic> json,
) => _$ExamSessionRowModelImpl(
  exam_type: json['exam_type'] as String,
  sessions: (json['sessions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$$ExamSessionRowModelImplToJson(
  _$ExamSessionRowModelImpl instance,
) => <String, dynamic>{
  'exam_type': instance.exam_type,
  'sessions': instance.sessions,
};

_$ExamSessionListModelImpl _$$ExamSessionListModelImplFromJson(
  Map<String, dynamic> json,
) => _$ExamSessionListModelImpl(
  title: json['title'] as String,
  exam_session_list: (json['exam_session_list'] as List<dynamic>)
      .map((e) => ExamSessionRowModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$ExamSessionListModelImplToJson(
  _$ExamSessionListModelImpl instance,
) => <String, dynamic>{
  'title': instance.title,
  'exam_session_list': instance.exam_session_list,
};
