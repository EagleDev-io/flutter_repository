import 'package:meta/meta.dart';
import 'package:repository/src/identifiable.dart';
import 'package:uuid/uuid.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo_item.freezed.dart';
part 'todo_item.g.dart';

String idToString(dynamic id) => '$id';

@freezed
abstract class TodoItem
    with _$TodoItem
    implements WithIdAndPrimaryKey<String, String> {
  factory TodoItem({
    String id,
    @JsonKey(ignore: true) String primaryKey,
    String title,
    int order,
    bool completed,
  }) = _TodoItem;

  factory TodoItem.fromJson(Map<String, dynamic> json) =>
      _$TodoItemFromJson(json);

  factory TodoItem.newItem(String title) {
    return TodoItem(
      title: title,
      completed: false,
      primaryKey: Uuid().v4(),
      id: null,
      order: null,
    );
  }
}

class TodoItemEdit extends _$_TodoItem {
  final String title;
  final String id;
  final bool completed;
  final int order;

  TodoItemEdit({this.id, this.title, this.completed, this.order});

  @override
  String primaryKey = null;
}

class TodoItemModel extends _$_TodoItem
    implements WithId<String>, WithPrimaryKey<String> {
  final String title;
  final String id;
  final bool completed;
  final int order;

  TodoItemModel({this.id, this.title, this.completed, this.order});

  @override
  String primaryKey = Uuid().v4();
}
