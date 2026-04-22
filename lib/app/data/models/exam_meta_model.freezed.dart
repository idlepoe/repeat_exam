// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exam_meta_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ExamTypeListModel _$ExamTypeListModelFromJson(Map<String, dynamic> json) {
  return _ExamTypeListModel.fromJson(json);
}

/// @nodoc
mixin _$ExamTypeListModel {
  String get title => throw _privateConstructorUsedError;
  List<String> get exam_type_list => throw _privateConstructorUsedError;

  /// Serializes this ExamTypeListModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExamTypeListModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExamTypeListModelCopyWith<ExamTypeListModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExamTypeListModelCopyWith<$Res> {
  factory $ExamTypeListModelCopyWith(
    ExamTypeListModel value,
    $Res Function(ExamTypeListModel) then,
  ) = _$ExamTypeListModelCopyWithImpl<$Res, ExamTypeListModel>;
  @useResult
  $Res call({String title, List<String> exam_type_list});
}

/// @nodoc
class _$ExamTypeListModelCopyWithImpl<$Res, $Val extends ExamTypeListModel>
    implements $ExamTypeListModelCopyWith<$Res> {
  _$ExamTypeListModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExamTypeListModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? title = null, Object? exam_type_list = null}) {
    return _then(
      _value.copyWith(
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            exam_type_list: null == exam_type_list
                ? _value.exam_type_list
                : exam_type_list // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExamTypeListModelImplCopyWith<$Res>
    implements $ExamTypeListModelCopyWith<$Res> {
  factory _$$ExamTypeListModelImplCopyWith(
    _$ExamTypeListModelImpl value,
    $Res Function(_$ExamTypeListModelImpl) then,
  ) = __$$ExamTypeListModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String title, List<String> exam_type_list});
}

/// @nodoc
class __$$ExamTypeListModelImplCopyWithImpl<$Res>
    extends _$ExamTypeListModelCopyWithImpl<$Res, _$ExamTypeListModelImpl>
    implements _$$ExamTypeListModelImplCopyWith<$Res> {
  __$$ExamTypeListModelImplCopyWithImpl(
    _$ExamTypeListModelImpl _value,
    $Res Function(_$ExamTypeListModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExamTypeListModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? title = null, Object? exam_type_list = null}) {
    return _then(
      _$ExamTypeListModelImpl(
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        exam_type_list: null == exam_type_list
            ? _value._exam_type_list
            : exam_type_list // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExamTypeListModelImpl implements _ExamTypeListModel {
  const _$ExamTypeListModelImpl({
    required this.title,
    required final List<String> exam_type_list,
  }) : _exam_type_list = exam_type_list;

  factory _$ExamTypeListModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExamTypeListModelImplFromJson(json);

  @override
  final String title;
  final List<String> _exam_type_list;
  @override
  List<String> get exam_type_list {
    if (_exam_type_list is EqualUnmodifiableListView) return _exam_type_list;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_exam_type_list);
  }

  @override
  String toString() {
    return 'ExamTypeListModel(title: $title, exam_type_list: $exam_type_list)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExamTypeListModelImpl &&
            (identical(other.title, title) || other.title == title) &&
            const DeepCollectionEquality().equals(
              other._exam_type_list,
              _exam_type_list,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    title,
    const DeepCollectionEquality().hash(_exam_type_list),
  );

  /// Create a copy of ExamTypeListModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExamTypeListModelImplCopyWith<_$ExamTypeListModelImpl> get copyWith =>
      __$$ExamTypeListModelImplCopyWithImpl<_$ExamTypeListModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ExamTypeListModelImplToJson(this);
  }
}

abstract class _ExamTypeListModel implements ExamTypeListModel {
  const factory _ExamTypeListModel({
    required final String title,
    required final List<String> exam_type_list,
  }) = _$ExamTypeListModelImpl;

  factory _ExamTypeListModel.fromJson(Map<String, dynamic> json) =
      _$ExamTypeListModelImpl.fromJson;

  @override
  String get title;
  @override
  List<String> get exam_type_list;

  /// Create a copy of ExamTypeListModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExamTypeListModelImplCopyWith<_$ExamTypeListModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ExamSessionRowModel _$ExamSessionRowModelFromJson(Map<String, dynamic> json) {
  return _ExamSessionRowModel.fromJson(json);
}

/// @nodoc
mixin _$ExamSessionRowModel {
  String get exam_type => throw _privateConstructorUsedError;
  List<String> get sessions => throw _privateConstructorUsedError;

  /// Serializes this ExamSessionRowModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExamSessionRowModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExamSessionRowModelCopyWith<ExamSessionRowModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExamSessionRowModelCopyWith<$Res> {
  factory $ExamSessionRowModelCopyWith(
    ExamSessionRowModel value,
    $Res Function(ExamSessionRowModel) then,
  ) = _$ExamSessionRowModelCopyWithImpl<$Res, ExamSessionRowModel>;
  @useResult
  $Res call({String exam_type, List<String> sessions});
}

/// @nodoc
class _$ExamSessionRowModelCopyWithImpl<$Res, $Val extends ExamSessionRowModel>
    implements $ExamSessionRowModelCopyWith<$Res> {
  _$ExamSessionRowModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExamSessionRowModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? exam_type = null, Object? sessions = null}) {
    return _then(
      _value.copyWith(
            exam_type: null == exam_type
                ? _value.exam_type
                : exam_type // ignore: cast_nullable_to_non_nullable
                      as String,
            sessions: null == sessions
                ? _value.sessions
                : sessions // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExamSessionRowModelImplCopyWith<$Res>
    implements $ExamSessionRowModelCopyWith<$Res> {
  factory _$$ExamSessionRowModelImplCopyWith(
    _$ExamSessionRowModelImpl value,
    $Res Function(_$ExamSessionRowModelImpl) then,
  ) = __$$ExamSessionRowModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String exam_type, List<String> sessions});
}

/// @nodoc
class __$$ExamSessionRowModelImplCopyWithImpl<$Res>
    extends _$ExamSessionRowModelCopyWithImpl<$Res, _$ExamSessionRowModelImpl>
    implements _$$ExamSessionRowModelImplCopyWith<$Res> {
  __$$ExamSessionRowModelImplCopyWithImpl(
    _$ExamSessionRowModelImpl _value,
    $Res Function(_$ExamSessionRowModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExamSessionRowModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? exam_type = null, Object? sessions = null}) {
    return _then(
      _$ExamSessionRowModelImpl(
        exam_type: null == exam_type
            ? _value.exam_type
            : exam_type // ignore: cast_nullable_to_non_nullable
                  as String,
        sessions: null == sessions
            ? _value._sessions
            : sessions // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExamSessionRowModelImpl implements _ExamSessionRowModel {
  const _$ExamSessionRowModelImpl({
    required this.exam_type,
    required final List<String> sessions,
  }) : _sessions = sessions;

  factory _$ExamSessionRowModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExamSessionRowModelImplFromJson(json);

  @override
  final String exam_type;
  final List<String> _sessions;
  @override
  List<String> get sessions {
    if (_sessions is EqualUnmodifiableListView) return _sessions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sessions);
  }

  @override
  String toString() {
    return 'ExamSessionRowModel(exam_type: $exam_type, sessions: $sessions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExamSessionRowModelImpl &&
            (identical(other.exam_type, exam_type) ||
                other.exam_type == exam_type) &&
            const DeepCollectionEquality().equals(other._sessions, _sessions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    exam_type,
    const DeepCollectionEquality().hash(_sessions),
  );

  /// Create a copy of ExamSessionRowModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExamSessionRowModelImplCopyWith<_$ExamSessionRowModelImpl> get copyWith =>
      __$$ExamSessionRowModelImplCopyWithImpl<_$ExamSessionRowModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ExamSessionRowModelImplToJson(this);
  }
}

abstract class _ExamSessionRowModel implements ExamSessionRowModel {
  const factory _ExamSessionRowModel({
    required final String exam_type,
    required final List<String> sessions,
  }) = _$ExamSessionRowModelImpl;

  factory _ExamSessionRowModel.fromJson(Map<String, dynamic> json) =
      _$ExamSessionRowModelImpl.fromJson;

  @override
  String get exam_type;
  @override
  List<String> get sessions;

  /// Create a copy of ExamSessionRowModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExamSessionRowModelImplCopyWith<_$ExamSessionRowModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ExamSessionListModel _$ExamSessionListModelFromJson(Map<String, dynamic> json) {
  return _ExamSessionListModel.fromJson(json);
}

/// @nodoc
mixin _$ExamSessionListModel {
  String get title => throw _privateConstructorUsedError;
  List<ExamSessionRowModel> get exam_session_list =>
      throw _privateConstructorUsedError;

  /// Serializes this ExamSessionListModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExamSessionListModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExamSessionListModelCopyWith<ExamSessionListModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExamSessionListModelCopyWith<$Res> {
  factory $ExamSessionListModelCopyWith(
    ExamSessionListModel value,
    $Res Function(ExamSessionListModel) then,
  ) = _$ExamSessionListModelCopyWithImpl<$Res, ExamSessionListModel>;
  @useResult
  $Res call({String title, List<ExamSessionRowModel> exam_session_list});
}

/// @nodoc
class _$ExamSessionListModelCopyWithImpl<
  $Res,
  $Val extends ExamSessionListModel
>
    implements $ExamSessionListModelCopyWith<$Res> {
  _$ExamSessionListModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExamSessionListModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? title = null, Object? exam_session_list = null}) {
    return _then(
      _value.copyWith(
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            exam_session_list: null == exam_session_list
                ? _value.exam_session_list
                : exam_session_list // ignore: cast_nullable_to_non_nullable
                      as List<ExamSessionRowModel>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExamSessionListModelImplCopyWith<$Res>
    implements $ExamSessionListModelCopyWith<$Res> {
  factory _$$ExamSessionListModelImplCopyWith(
    _$ExamSessionListModelImpl value,
    $Res Function(_$ExamSessionListModelImpl) then,
  ) = __$$ExamSessionListModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String title, List<ExamSessionRowModel> exam_session_list});
}

/// @nodoc
class __$$ExamSessionListModelImplCopyWithImpl<$Res>
    extends _$ExamSessionListModelCopyWithImpl<$Res, _$ExamSessionListModelImpl>
    implements _$$ExamSessionListModelImplCopyWith<$Res> {
  __$$ExamSessionListModelImplCopyWithImpl(
    _$ExamSessionListModelImpl _value,
    $Res Function(_$ExamSessionListModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExamSessionListModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? title = null, Object? exam_session_list = null}) {
    return _then(
      _$ExamSessionListModelImpl(
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        exam_session_list: null == exam_session_list
            ? _value._exam_session_list
            : exam_session_list // ignore: cast_nullable_to_non_nullable
                  as List<ExamSessionRowModel>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExamSessionListModelImpl implements _ExamSessionListModel {
  const _$ExamSessionListModelImpl({
    required this.title,
    required final List<ExamSessionRowModel> exam_session_list,
  }) : _exam_session_list = exam_session_list;

  factory _$ExamSessionListModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExamSessionListModelImplFromJson(json);

  @override
  final String title;
  final List<ExamSessionRowModel> _exam_session_list;
  @override
  List<ExamSessionRowModel> get exam_session_list {
    if (_exam_session_list is EqualUnmodifiableListView)
      return _exam_session_list;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_exam_session_list);
  }

  @override
  String toString() {
    return 'ExamSessionListModel(title: $title, exam_session_list: $exam_session_list)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExamSessionListModelImpl &&
            (identical(other.title, title) || other.title == title) &&
            const DeepCollectionEquality().equals(
              other._exam_session_list,
              _exam_session_list,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    title,
    const DeepCollectionEquality().hash(_exam_session_list),
  );

  /// Create a copy of ExamSessionListModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExamSessionListModelImplCopyWith<_$ExamSessionListModelImpl>
  get copyWith =>
      __$$ExamSessionListModelImplCopyWithImpl<_$ExamSessionListModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ExamSessionListModelImplToJson(this);
  }
}

abstract class _ExamSessionListModel implements ExamSessionListModel {
  const factory _ExamSessionListModel({
    required final String title,
    required final List<ExamSessionRowModel> exam_session_list,
  }) = _$ExamSessionListModelImpl;

  factory _ExamSessionListModel.fromJson(Map<String, dynamic> json) =
      _$ExamSessionListModelImpl.fromJson;

  @override
  String get title;
  @override
  List<ExamSessionRowModel> get exam_session_list;

  /// Create a copy of ExamSessionListModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExamSessionListModelImplCopyWith<_$ExamSessionListModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
