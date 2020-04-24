// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named

part of 'todo_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

TodoItem _$TodoItemFromJson(Map<String, dynamic> json) {
  return _TodoItem.fromJson(json);
}

mixin _$TodoItem {
  String get id;
  @JsonKey(ignore: true)
  String get primaryKey;
  String get title;
  int get order;
  bool get completed;

  TodoItem copyWith(
      {String id,
      @JsonKey(ignore: true) String primaryKey,
      String title,
      int order,
      bool completed});

  Map<String, dynamic> toJson();
}

class _$TodoItemTearOff {
  const _$TodoItemTearOff();

  _TodoItem call(
      {String id,
      @JsonKey(ignore: true) String primaryKey,
      String title,
      int order,
      bool completed}) {
    return _TodoItem(
      id: id,
      primaryKey: primaryKey,
      title: title,
      order: order,
      completed: completed,
    );
  }
}

const $TodoItem = _$TodoItemTearOff();

@JsonSerializable()
class _$_TodoItem implements _TodoItem {
  _$_TodoItem(
      {this.id,
      @JsonKey(ignore: true) this.primaryKey,
      this.title,
      this.order,
      this.completed});

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
  _$_TodoItem copyWith({
    Object id = freezed,
    Object primaryKey = freezed,
    Object title = freezed,
    Object order = freezed,
    Object completed = freezed,
  }) {
    return _$_TodoItem(
      id: id == freezed ? this.id : id as String,
      primaryKey:
          primaryKey == freezed ? this.primaryKey : primaryKey as String,
      title: title == freezed ? this.title : title as String,
      order: order == freezed ? this.order : order as int,
      completed: completed == freezed ? this.completed : completed as bool,
    );
  }

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
  _TodoItem copyWith(
      {String id,
      @JsonKey(ignore: true) String primaryKey,
      String title,
      int order,
      bool completed});
}
