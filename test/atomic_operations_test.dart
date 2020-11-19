import 'package:flutter_test/flutter_test.dart';
import 'package:repository/src/in_memory_repository.dart';
import 'package:repository/repository.dart';

import 'todo_item.dart';

abstract class TodoRepository implements Add<TodoItem>, Delete<TodoItem> {}

void main() {
  InMemoryRepository<TodoItem> repository;
  setUp(() {
    repository = InMemoryRepository.blank();
  });

  test(
      'can cast repository imlementation to subtype with partial repository implementation',
      () {
    final writeOnly = repository as WriteOnlyRepository<TodoItem>;
    final addOnly = repository as Add<TodoItem>;
    final readOnly = repository as ReadOnlyRepository<TodoItem>;

    assert(readOnly != null);
    assert(addOnly != null);
    assert(writeOnly != null);
  });

  test('correctly forwards allowed operation to underlying repository', () {});
}
