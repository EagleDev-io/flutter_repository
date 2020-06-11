// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named

part of 'todo_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;
TodoItem _$TodoItemFromJson(Map<String, dynamic> json) {
  return _TodoItem.fromJson(json);
}

class _$TodoItemTearOff {
  const _$TodoItemTearOff();

  _TodoItem call(
      {String id,
      @JsonKey(ignore: true) String primaryKey,
      String title,
      int order,
      bool completed = false}) {
    return _TodoItem(
      id: id,
      primaryKey: primaryKey,
      title: title,
      order: order,
      completed: completed,
    );
  }
}

// ignore: unused_element
const $TodoItem = _$TodoItemTearOff();

mixin _$TodoItem {
  String get id;
  @JsonKey(ignore: true)
  String get primaryKey;
  String get title;
  int get order;
  bool get completed;

  Map<String, dynamic> toJson();
  $TodoItemCopyWith<TodoItem> get copyWith;
}

abstract class $TodoItemCopyWith<$Res> {
  factory $TodoItemCopyWith(TodoItem value, $Res Function(TodoItem) then) =
      _$TodoItemCopyWithImpl<$Res>;
  $Res call(
      {String id,
      @JsonKey(ignore: true) String primaryKey,
      String title,
      int order,
      bool completed});
}

class _$TodoItemCopyWithImpl<$Res> implements $TodoItemCopyWith<$Res> {
  _$TodoItemCopyWithImpl(this._value, this._then);

  final TodoItem _value;
  // ignore: unused_field
  final $Res Function(TodoItem) _then;

  @override
  $Res call({
    Object id = freezed,
    Object primaryKey = freezed,
    Object title = freezed,
    Object order = freezed,
    Object completed = freezed,
  }) {
    return _then(_value.copyWith(
      id: id == freezed ? _value.id : id as String,
      primaryKey:
          primaryKey == freezed ? _value.primaryKey : primaryKey as String,
      title: title == freezed ? _value.title : title as String,
      order: order == freezed ? _value.order : order as int,
      completed: completed == freezed ? _value.completed : completed as bool,
    ));
  }
}

abstract class _$TodoItemCopyWith<$Res> implements $TodoItemCopyWith<$Res> {
  factory _$TodoItemCopyWith(_TodoItem value, $Res Function(_TodoItem) then) =
      __$TodoItemCopyWithImpl<$Res>;
  @override
  $Res call(
      {String id,
      @JsonKey(ignore: true) String primaryKey,
      String title,
      int order,
      bool completed});
}

class __$TodoItemCopyWithImpl<$Res> extends _$TodoItemCopyWithImpl<$Res>
    implements _$TodoItemCopyWith<$Res> {
  __$TodoItemCopyWithImpl(_TodoItem _value, $Res Function(_TodoItem) _then)
      : super(_value, (v) => _then(v as _TodoItem));

  @override
  _TodoItem get _value => super._value as _TodoItem;

  @override
  $Res call({
    Object id = freezed,
    Object primaryKey = freezed,
    Object title = freezed,
    Object order = freezed,
    Object completed = freezed,
  }) {
    return _then(_TodoItem(
      id: id == freezed ? _value.id : id as String,
      primaryKey:
          primaryKey == freezed ? _value.primaryKey : primaryKey as String,
      title: title == freezed ? _value.title : title as String,
      order: order == freezed ? _value.order : order as int,
      completed: completed == freezed ? _value.completed : completed as bool,
    ));
  }
}

@JsonSerializable()
class _$_TodoItem implements _TodoItem {
  _$_TodoItem(
      {this.id,
      @JsonKey(ignore: true) this.primaryKey,
      this.title,
      this.order,
      this.completed = false})
      : assert(completed != null);

  factory _$_TodoItem.fromJson(Map<String, dynamic> json) =>
      _$_$_TodoItemFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(ignore: true)
  final String primaryKey;
  @override
  final String title;
  @override
  final int order;
  @JsonKey(defaultValue: false)
  @override
  final bool completed;

  @override
  String toString() {
    return 'TodoItem(id: $id, primaryKey: $primaryKey, title: $title, order: $order, completed: $completed)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _TodoItem &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.primaryKey, primaryKey) ||
                const DeepCollectionEquality()
                    .equals(other.primaryKey, primaryKey)) &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.order, order) ||
                const DeepCollectionEquality().equals(other.order, order)) &&
            (identical(other.completed, completed) ||
                const DeepCollectionEquality()
                    .equals(other.completed, completed)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(primaryKey) ^
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(order) ^
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
  factory _TodoItem(
      {String id,
      @JsonKey(ignore: true) String primaryKey,
      String title,
      int order,
      bool completed}) = _$_TodoItem;

  factory _TodoItem.fromJson(Map<String, dynamic> json) = _$_TodoItem.fromJson;

  @override
  String get id;
  @override
  @JsonKey(ignore: true)
  String get primaryKey;
  @override
  String get title;
  @override
  int get order;
  @override
  bool get completed;
  @override
  _$TodoItemCopyWith<_TodoItem> get copyWith;
}
