// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_TodoItem _$_$_TodoItemFromJson(Map<String, dynamic> json) {
  return _$_TodoItem(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    title: json['title'] as String,
    completed: json['completed'] as bool ?? false,
  );
}

Map<String, dynamic> _$_$_TodoItemToJson(_$_TodoItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'title': instance.title,
      'completed': instance.completed,
    };
