import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:repository/repository.dart';

import 'todo_item.dart';

abstract class Callable<T> {
  void call([T arg]) {}
}

abstract class Callable2<T, V> {
  void call([T arg, V arg2]) {}
}

class MockCallable<T> extends Mock implements Callable<T> {}
class MockCallable2<T, V> extends Mock implements Callable2<T,V> {}

class NetworkChecker implements NetworkInfo {
  @override
  Future<bool> get isConnected async => Future.value(true);
}

void main() {
  final Either<RepositoryFailure,String> tResult = Right('Helo');

  test('Test can add logging to getById', () async {
    final getById = GetByIdFunction<String>((id) async => tResult);
    final mockCallable = MockCallable();

    final sut = getById.logging((result) => mockCallable(result));
    await sut.getById(UniqueId('3'));

    verify(mockCallable(tResult));
  });

  test('Test can add logging to GetAll', () async {
    final Either<RepositoryBaseFailure, List<String>> tResult = Right([]);
    final operationClass = GetAllFunction<String>(() async => tResult);
    final mockCallable = MockCallable();

    final sut = operationClass.logging((result) => mockCallable(result));
    await sut.getAll();

    verify(mockCallable(tResult));
  });

  test('Test can access cache extension on GetAll', () async {
    final GetAll<TodoItem> operationClass = InMemoryRepository.blank();

    final GetAll<TodoItem> cachingOperationClass = operationClass.cachingWith(
      repository: InMemoryRepository.blank(),
      policy: TimedCachingPolicy(outdatedAfter: Duration(minutes: 3)),
      networkChecker: NetworkChecker(),
    );

    final result = await cachingOperationClass.getAll();
    assert(result.isRight());
  });

  test('Test can access cache extension on ReadOnlyRepository', () async {
    final ReadOnlyRepository<TodoItem> operationClass =
        InMemoryRepository.blank();

    final GetAll<TodoItem> cachingOperationClass = operationClass.cachingWith(
      repository: InMemoryRepository.blank(),
      policy: TimedCachingPolicy(outdatedAfter: Duration(minutes: 3)),
      networkChecker: NetworkChecker(),
    );

    final result = await cachingOperationClass.getAll();
    assert(result.isRight());
  });
}
