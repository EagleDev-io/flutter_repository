import 'package:flutter_test/flutter_test.dart';
import 'package:repository/repository.dart';
import 'todo_item.dart';
import 'repository_extensions.dart';

void main() {
  InMemoryRepository<TodoItem> sut;

  final TodoItem tEntity = TodoItem.newItem('test task');

  setUp(() {
    sut = InMemoryRepository.blank();
  });

  test('Can delete item from repository', () async {
    await sut.add(tEntity);
    final countAfterAdd = await sut.entityCount;
    await sut.delete(tEntity);
    final countAfterDelete = await sut.entityCount;

    assert(countAfterAdd == 1);
    assert(countAfterDelete == 0);
  });

  test('Can update item when present in repository', () async {
    await sut.add(tEntity);
    final updatedEntity = tEntity.copyWith(completed: true);
    await sut.update(updatedEntity);
    final fetched = await sut.getFirst;
    expect(fetched, updatedEntity);
    expect(fetched, isNot(tEntity));
  });

  test(
      'Returns left failure when getting element by id that is not present in repository',
      () async {
    final result = await sut.getById(UniqueId('999777'));
    final error = result.fold((e) => e, (_) => null);

    expect(error, isNotNull);
    expect(error, isA<RepositoryFailure>());
  });
}
