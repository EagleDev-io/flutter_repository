import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meta/meta.dart';

part 'todo_item.freezed.dart';
part 'todo_item.g.dart';

@freezed
abstract class TodoItem with _$TodoItem {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory TodoItem({
    @required String id,
    @required String userId,
    @required String title,
    @Default(false) bool completed,
  }) = _TodoItem;

  factory TodoItem.fromJson(Map<String, dynamic> json) =>
      _$TodoItemFromJson(json);
}
