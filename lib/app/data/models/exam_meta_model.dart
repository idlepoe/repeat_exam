import 'package:freezed_annotation/freezed_annotation.dart';

part 'exam_meta_model.freezed.dart';
part 'exam_meta_model.g.dart';

@freezed
class ExamTypeListModel with _$ExamTypeListModel {
  const factory ExamTypeListModel({
    required String title,
    required List<String> exam_type_list,
  }) = _ExamTypeListModel;

  factory ExamTypeListModel.fromJson(Map<String, dynamic> json) =>
      _$ExamTypeListModelFromJson(json);
}

@freezed
class ExamSessionRowModel with _$ExamSessionRowModel {
  const factory ExamSessionRowModel({
    required String exam_type,
    required List<String> sessions,
  }) = _ExamSessionRowModel;

  factory ExamSessionRowModel.fromJson(Map<String, dynamic> json) =>
      _$ExamSessionRowModelFromJson(json);
}

@freezed
class ExamSessionListModel with _$ExamSessionListModel {
  const factory ExamSessionListModel({
    required String title,
    required List<ExamSessionRowModel> exam_session_list,
  }) = _ExamSessionListModel;

  factory ExamSessionListModel.fromJson(Map<String, dynamic> json) =>
      _$ExamSessionListModelFromJson(json);
}
