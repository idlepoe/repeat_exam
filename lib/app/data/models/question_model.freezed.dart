// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'question_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

QuestionModel _$QuestionModelFromJson(Map<String, dynamic> json) {
  return _QuestionModel.fromJson(json);
}

/// @nodoc
mixin _$QuestionModel {
  String get id => throw _privateConstructorUsedError;
  String get exam_type => throw _privateConstructorUsedError;
  String get subject => throw _privateConstructorUsedError;
  String get exam_session => throw _privateConstructorUsedError;
  int get question_number => throw _privateConstructorUsedError;
  String get question_text => throw _privateConstructorUsedError;
  String? get question_image_url => throw _privateConstructorUsedError;
  List<ChoiceModel> get choices => throw _privateConstructorUsedError;
  int get correct_answer => throw _privateConstructorUsedError;
  List<String> get keywords => throw _privateConstructorUsedError;
  Map<String, dynamic>? get aiExplanation => throw _privateConstructorUsedError;

  /// Serializes this QuestionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of QuestionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QuestionModelCopyWith<QuestionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuestionModelCopyWith<$Res> {
  factory $QuestionModelCopyWith(
    QuestionModel value,
    $Res Function(QuestionModel) then,
  ) = _$QuestionModelCopyWithImpl<$Res, QuestionModel>;
  @useResult
  $Res call({
    String id,
    String exam_type,
    String subject,
    String exam_session,
    int question_number,
    String question_text,
    String? question_image_url,
    List<ChoiceModel> choices,
    int correct_answer,
    List<String> keywords,
    Map<String, dynamic>? aiExplanation,
  });
}

/// @nodoc
class _$QuestionModelCopyWithImpl<$Res, $Val extends QuestionModel>
    implements $QuestionModelCopyWith<$Res> {
  _$QuestionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QuestionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? exam_type = null,
    Object? subject = null,
    Object? exam_session = null,
    Object? question_number = null,
    Object? question_text = null,
    Object? question_image_url = freezed,
    Object? choices = null,
    Object? correct_answer = null,
    Object? keywords = null,
    Object? aiExplanation = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            exam_type: null == exam_type
                ? _value.exam_type
                : exam_type // ignore: cast_nullable_to_non_nullable
                      as String,
            subject: null == subject
                ? _value.subject
                : subject // ignore: cast_nullable_to_non_nullable
                      as String,
            exam_session: null == exam_session
                ? _value.exam_session
                : exam_session // ignore: cast_nullable_to_non_nullable
                      as String,
            question_number: null == question_number
                ? _value.question_number
                : question_number // ignore: cast_nullable_to_non_nullable
                      as int,
            question_text: null == question_text
                ? _value.question_text
                : question_text // ignore: cast_nullable_to_non_nullable
                      as String,
            question_image_url: freezed == question_image_url
                ? _value.question_image_url
                : question_image_url // ignore: cast_nullable_to_non_nullable
                      as String?,
            choices: null == choices
                ? _value.choices
                : choices // ignore: cast_nullable_to_non_nullable
                      as List<ChoiceModel>,
            correct_answer: null == correct_answer
                ? _value.correct_answer
                : correct_answer // ignore: cast_nullable_to_non_nullable
                      as int,
            keywords: null == keywords
                ? _value.keywords
                : keywords // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            aiExplanation: freezed == aiExplanation
                ? _value.aiExplanation
                : aiExplanation // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$QuestionModelImplCopyWith<$Res>
    implements $QuestionModelCopyWith<$Res> {
  factory _$$QuestionModelImplCopyWith(
    _$QuestionModelImpl value,
    $Res Function(_$QuestionModelImpl) then,
  ) = __$$QuestionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String exam_type,
    String subject,
    String exam_session,
    int question_number,
    String question_text,
    String? question_image_url,
    List<ChoiceModel> choices,
    int correct_answer,
    List<String> keywords,
    Map<String, dynamic>? aiExplanation,
  });
}

/// @nodoc
class __$$QuestionModelImplCopyWithImpl<$Res>
    extends _$QuestionModelCopyWithImpl<$Res, _$QuestionModelImpl>
    implements _$$QuestionModelImplCopyWith<$Res> {
  __$$QuestionModelImplCopyWithImpl(
    _$QuestionModelImpl _value,
    $Res Function(_$QuestionModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of QuestionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? exam_type = null,
    Object? subject = null,
    Object? exam_session = null,
    Object? question_number = null,
    Object? question_text = null,
    Object? question_image_url = freezed,
    Object? choices = null,
    Object? correct_answer = null,
    Object? keywords = null,
    Object? aiExplanation = freezed,
  }) {
    return _then(
      _$QuestionModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        exam_type: null == exam_type
            ? _value.exam_type
            : exam_type // ignore: cast_nullable_to_non_nullable
                  as String,
        subject: null == subject
            ? _value.subject
            : subject // ignore: cast_nullable_to_non_nullable
                  as String,
        exam_session: null == exam_session
            ? _value.exam_session
            : exam_session // ignore: cast_nullable_to_non_nullable
                  as String,
        question_number: null == question_number
            ? _value.question_number
            : question_number // ignore: cast_nullable_to_non_nullable
                  as int,
        question_text: null == question_text
            ? _value.question_text
            : question_text // ignore: cast_nullable_to_non_nullable
                  as String,
        question_image_url: freezed == question_image_url
            ? _value.question_image_url
            : question_image_url // ignore: cast_nullable_to_non_nullable
                  as String?,
        choices: null == choices
            ? _value._choices
            : choices // ignore: cast_nullable_to_non_nullable
                  as List<ChoiceModel>,
        correct_answer: null == correct_answer
            ? _value.correct_answer
            : correct_answer // ignore: cast_nullable_to_non_nullable
                  as int,
        keywords: null == keywords
            ? _value._keywords
            : keywords // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        aiExplanation: freezed == aiExplanation
            ? _value._aiExplanation
            : aiExplanation // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$QuestionModelImpl implements _QuestionModel {
  const _$QuestionModelImpl({
    required this.id,
    required this.exam_type,
    required this.subject,
    required this.exam_session,
    required this.question_number,
    required this.question_text,
    this.question_image_url,
    required final List<ChoiceModel> choices,
    required this.correct_answer,
    required final List<String> keywords,
    final Map<String, dynamic>? aiExplanation,
  }) : _choices = choices,
       _keywords = keywords,
       _aiExplanation = aiExplanation;

  factory _$QuestionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuestionModelImplFromJson(json);

  @override
  final String id;
  @override
  final String exam_type;
  @override
  final String subject;
  @override
  final String exam_session;
  @override
  final int question_number;
  @override
  final String question_text;
  @override
  final String? question_image_url;
  final List<ChoiceModel> _choices;
  @override
  List<ChoiceModel> get choices {
    if (_choices is EqualUnmodifiableListView) return _choices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_choices);
  }

  @override
  final int correct_answer;
  final List<String> _keywords;
  @override
  List<String> get keywords {
    if (_keywords is EqualUnmodifiableListView) return _keywords;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_keywords);
  }

  final Map<String, dynamic>? _aiExplanation;
  @override
  Map<String, dynamic>? get aiExplanation {
    final value = _aiExplanation;
    if (value == null) return null;
    if (_aiExplanation is EqualUnmodifiableMapView) return _aiExplanation;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'QuestionModel(id: $id, exam_type: $exam_type, subject: $subject, exam_session: $exam_session, question_number: $question_number, question_text: $question_text, question_image_url: $question_image_url, choices: $choices, correct_answer: $correct_answer, keywords: $keywords, aiExplanation: $aiExplanation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuestionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.exam_type, exam_type) ||
                other.exam_type == exam_type) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.exam_session, exam_session) ||
                other.exam_session == exam_session) &&
            (identical(other.question_number, question_number) ||
                other.question_number == question_number) &&
            (identical(other.question_text, question_text) ||
                other.question_text == question_text) &&
            (identical(other.question_image_url, question_image_url) ||
                other.question_image_url == question_image_url) &&
            const DeepCollectionEquality().equals(other._choices, _choices) &&
            (identical(other.correct_answer, correct_answer) ||
                other.correct_answer == correct_answer) &&
            const DeepCollectionEquality().equals(other._keywords, _keywords) &&
            const DeepCollectionEquality().equals(
              other._aiExplanation,
              _aiExplanation,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    exam_type,
    subject,
    exam_session,
    question_number,
    question_text,
    question_image_url,
    const DeepCollectionEquality().hash(_choices),
    correct_answer,
    const DeepCollectionEquality().hash(_keywords),
    const DeepCollectionEquality().hash(_aiExplanation),
  );

  /// Create a copy of QuestionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QuestionModelImplCopyWith<_$QuestionModelImpl> get copyWith =>
      __$$QuestionModelImplCopyWithImpl<_$QuestionModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuestionModelImplToJson(this);
  }
}

abstract class _QuestionModel implements QuestionModel {
  const factory _QuestionModel({
    required final String id,
    required final String exam_type,
    required final String subject,
    required final String exam_session,
    required final int question_number,
    required final String question_text,
    final String? question_image_url,
    required final List<ChoiceModel> choices,
    required final int correct_answer,
    required final List<String> keywords,
    final Map<String, dynamic>? aiExplanation,
  }) = _$QuestionModelImpl;

  factory _QuestionModel.fromJson(Map<String, dynamic> json) =
      _$QuestionModelImpl.fromJson;

  @override
  String get id;
  @override
  String get exam_type;
  @override
  String get subject;
  @override
  String get exam_session;
  @override
  int get question_number;
  @override
  String get question_text;
  @override
  String? get question_image_url;
  @override
  List<ChoiceModel> get choices;
  @override
  int get correct_answer;
  @override
  List<String> get keywords;
  @override
  Map<String, dynamic>? get aiExplanation;

  /// Create a copy of QuestionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QuestionModelImplCopyWith<_$QuestionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
