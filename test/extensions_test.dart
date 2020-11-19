import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:repository/repository.dart';

abstract class Callable<T> {
  void call([T arg]) {}
}

class MockCallable<T> extends Mock implements Callable<T> {}

class NetworkChecker implements NetworkInfo {
  @override
  Future<bool> get isConnected async => Future.value(true);
}

void main() {
  test('Test can add logging to getById', () async {
    final getById = GetByIdFunction<String>((id) async => Right('Hello'));
    final mockCallable = MockCallable();

    final sut = getById.logging((operation) => mockCallable(operation));
    await sut.getById(UniqueId('3'));

    verify(mockCallable(any));
  });

  test('Test can add logging to GetAll', () async {
    final operationClass = GetAllFunction<String>(() async => Right([]));
    final mockCallable = MockCallable();

    final sut = operationClass.logging((operation) => mockCallable(operation));
    await sut.getAll();

    verify(mockCallable(any));
  });

  //test('Test caching extension', () async {
  //final operationClass = GetAllFunction<String>(() async => Right([]));

  //final GetAll<String> cachingOperationClass = operationClass.cachingWith(
  //repository: InMemoryRepository.blank(),
  //policy: TimedCachingPolicy(outdatedAfter: Duration(minutes: 3)),
  //networkChecker: NetworkChecker(),
  //);

  //final result = await cachingOperationClass.getAll();
  //assert(result.isRight());
  //});
}
