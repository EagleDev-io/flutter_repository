// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies

part of 'todo_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;
TodoItem _$TodoItemFromJson(Map<String, dynamic> json) {
  return _TodoItem.fromJson(json);
}

/// @nodoc
class _$TodoItemTearOff {
  const _$TodoItemTearOff();

// ignore: unused_element
  _TodoItem call(
      {@required String id,
      @required String userId,
      @required String title,
      bool completed = false}) {
    return _TodoItem(
      id: id,
      userId: userId,
      title: title,
      completed: completed,
    );
  }

// ignore: unused_element
  TodoItem fromJson(Map<String, Object> json) {
    return TodoItem.fromJson(json);
  }
}

/// @nodoc
// ignore: unused_element
const $TodoItem = _$TodoItemTearOff();

/// @nodoc
mixin _$TodoItem {
  String get id;
  String get userId;
  String get title;
  bool get completed;

  Map<String, dynamic> toJson();
  $TodoItemCopyWith<TodoItem> get copyWith;
}

/// @nodoc
abstract class $TodoItemCopyWith<$Res> {
  factory $TodoItemCopyWith(TodoItem value, $Res Function(TodoItem) then) =
      _$TodoItemCopyWithImpl<$Res>;
  $Res call({String id, String userId, String title, bool completed});
}

/// @nodoc
class _$TodoItemCopyWithImpl<$Res> implements $TodoItemCopyWith<$Res> {
  _$TodoItemCopyWithImpl(this._value, this._then);

  final TodoItem _value;
  // ignore: unused_field
  final $Res Function(TodoItem) _then;

  @override
  $Res call({
    Object id = freezed,
    Object userId = freezed,
    Object title = freezed,
    Object completed = freezed,
  }) {
    return _then(_value.copyWith(
      id: id == freezed ? _value.id : id as String,
      userId: userId == freezed ? _value.userId : userId as String,
      title: title == freezed ? _value.title : title as String,
      completed: completed == freezed ? _value.completed : completed as bool,
    ));
  }
}

/// @nodoc
abstract class _$TodoItemCopyWith<$Res> implements $TodoItemCopyWith<$Res> {
  factory _$TodoItemCopyWith(_TodoItem value, $Res Function(_TodoItem) then) =
      __$TodoItemCopyWithImpl<$Res>;
  @override
  $Res call({String id, String userId, String title, bool completed});
}

/// @nodoc
class __$TodoItemCopyWithImpl<$Res> extends _$TodoItemCopyWithImpl<$Res>
    implements _$TodoItemCopyWith<$Res> {
  __$TodoItemCopyWithImpl(_TodoItem _value, $Res Function(_TodoItem) _then)
      : super(_value, (v) => _then(v as _TodoItem));

  @override
  _TodoItem get _value => super._value as _TodoItem;

  @override
  $Res call({
    Object id = freezed,
    Object userId = freezed,
    Object title = freezed,
    Object completed = freezed,
  }) {
    return _then(_TodoItem(
      id: id == freezed ? _value.id : id as String,
      userId: userId == freezed ? _value.userId : userId as String,
      title: title == freezed ? _value.title : title as String,
      completed: completed == freezed ? _value.completed : completed as bool,
    ));
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)

/// @nodoc
class _$_TodoItem implements _TodoItem {
  const _$_TodoItem(
      {@required this.id,
      @required this.userId,
      @required this.title,
      this.completed = false})
      : assert(id != null),
        assert(userId != null),
        assert(title != null),
        assert(completed != null);

  factory _$_TodoItem.fromJson(Map<String, dynamic> json) =>
      _$_$_TodoItemFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String title;
  @JsonKey(defaultValue: false)
  @override
  final bool completed;

  @override
  String toString() {
    return 'TodoItem(id: $id, userId: $userId, title: $title, completed: $completed)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _TodoItem &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.userId, userId) ||
                const DeepCollectionEquality().equals(other.userId, userId)) &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.completed, completed) ||
                const DeepCollectionEquality()
                    .equals(other.completed, completed)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(userId) ^
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(completed);

  @override
  _$TodoItemCopyWith<_TodoItem> get copyWith =>
      __$TodoItemCopyWithImpl<_TodoItem>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$_$_TodoItemToJson(this);
  }
}

abstract class _TodoItem implements TodoItem {
  const factory _TodoItem(
      {@required String id,
      @required String userId,
      @required String title,
      bool completed}) = _$_TodoItem;

  factory _TodoItem.fromJson(Map<String, dynamic> json) = _$_TodoItem.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get title;
  @override
  bool get completed;
  @override
  _$TodoItemCopyWith<_TodoItem> get copyWith;
}
