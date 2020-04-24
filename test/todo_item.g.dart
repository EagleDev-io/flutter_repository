// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_TodoItem _$_$_TodoItemFromJson(Map<String, dynamic> json) {
  return _$_TodoItem(
    id: json['id'] as String,
    title: json['title'] as String,
    order: json['order'] as int,
    completed: json['completed'] as bool,
  );
}

Map<String, dynamic> _$_$_TodoItemToJson(_$_TodoItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'order': instance.order,
      'completed': instance.completed,
    };
