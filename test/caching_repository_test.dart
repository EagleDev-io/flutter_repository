import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:repository/repository.dart';
import 'package:repository/src/caching_repository.dart';

import 'spies/repository_spy.dart';
import 'todo_item.dart';
import 'repository_extensions.dart';

class MockSourceRepository extends Mock implements Repository<TodoItem> {}

class MockNetworkCheker extends Mock implements NetworkInfo {}

class CacheStateSpy extends Mock implements CacheState {
  final CacheState state;

  CacheStateSpy(this.state) {
    configure();
  }

  void configure() {
    when(shouldFetchFresh).thenAnswer((inv) => state.shouldFetchFresh);
    when(setLastRefresh(any)).thenAnswer(
        (inv) => state.setLastRefresh(inv.positionalArguments.first));
  }
}

void main() {
  CachingRepository<TodoItem> sut;
  RepositorySpy<TodoItem> cacheSpy;
  CacheStateSpy stateSpy;
  MockNetworkCheker networkCheckerMock;
  MockSourceRepository sourceMock;
  final policy = CachingPolicy();

  // Constants
  final tTodoItem = TodoItem.newItem('test task');
  final tTodoItems = [
    TodoItem.newItem('Task1'),
    TodoItem.newItem('Task2'),
    TodoItem.newItem('Task3'),
    TodoItem.newItem('Task4'),
  ];
  final tTodoItemsWithID = [
    TodoItem(id: '1', title: 'Task1'),
    TodoItem(id: '2', title: 'Task1'),
    TodoItem(id: '3', title: 'Task1'),
  ];

  setUp(() {
    sourceMock = MockSourceRepository();
    networkCheckerMock = MockNetworkCheker();

    cacheSpy = RepositorySpy(
        realRepository: InMemoryRepository.blank(),
        clearAction: (repository) {
          repository = InMemoryRepository.blank();
        });

    stateSpy = CacheStateSpy(CacheState(policy: policy));

    sut = CachingRepository(
      policy: null,
      state: stateSpy,
      cache: cacheSpy,
      source: sourceMock,
      networkChecker: networkCheckerMock,
    );
  });

  test('checks network status when calling get all', () async {
    when(networkCheckerMock.isConnected).thenAnswer((_) async => true);
    when(sourceMock.getAll()).thenAnswer((_) async => Right([]));
    final result = await sut.getAll();
    verify(networkCheckerMock.isConnected);
  });

  test(
      'synchronize calls source.getAll -> clears cache and add all new items into cache',
      () async {
    when(sourceMock.getAll()).thenAnswer((_) async => Right(tTodoItemsWithID));

    final result = await sut.synchronize();

    verify(cacheSpy.clear()).called(1);
    verify(sourceMock.getAll()).called(1);
    verify(cacheSpy.add(any)).called(tTodoItemsWithID.length);
    expect(result, Right(tTodoItemsWithID.length));
  });

  // =============== Time threhold not exceeded =============== //
  group('timeout threshold not exceeded', () {
    setUp(() {
      when(networkCheckerMock.isConnected).thenAnswer((_) async => true);
      when(stateSpy.shouldFetchFresh).thenReturn(false);
    });

    test('forwards getAll operation to cache', () async {
      final result = await sut.getAll();
      verify(cacheSpy.getAll()).called(1);
      verifyZeroInteractions(sourceMock);
      verify(stateSpy.shouldFetchFresh);
    });

    test('forwards getById operation to cache', () async {
      final tUniqueId = UniqueId('123');
      final tEntity = TodoItem(id: tUniqueId.value, title: 'test task');

      when(cacheSpy.getById(any)).thenAnswer((_) async => Right(tEntity));

      final result = await sut.getById(tUniqueId);

      expect(result.getOrElse(() => null), tEntity);
      verify(cacheSpy.getById(tUniqueId)).called(1);
      verifyNever(sourceMock.getById(any));
      verify(stateSpy.shouldFetchFresh).called(1);
    });
  });

  // =============== Device online and need fresh data =============== //
  group('Device is online and needs fresh data', () {
    setUp(() {
      when(networkCheckerMock.isConnected).thenAnswer((_) async => true);
      when(sourceMock.getAll())
          .thenAnswer((_) async => Right(tTodoItemsWithID));
      when(stateSpy.shouldFetchFresh).thenReturn(true);
    });
    test('calls source getAll when cache is invalidated', () async {
      final result = await sut.getAll();
      verify(sourceMock.getAll()).called(1);
      verifyNever(cacheSpy.getAll());
      verify(stateSpy.shouldFetchFresh);
    });

    test('populates cache when calling source getAll', () async {
      final result = await sut.entityCount;
      final cacheResult = await cacheSpy.entityCount;
      verify(cacheSpy.add(any)).called(tTodoItemsWithID.length);
      expect(result, cacheResult);
      expect(cacheResult, tTodoItemsWithID.length);
    });

    test('clears cache before populiting when calling source getAll', () async {
      await cacheSpy.add(TodoItem(id: 'asdasd', title: 'Test task'));
      final cacheCountBefore = await cacheSpy.entityCount;
      final result = await sut.entityCount;
      verify(cacheSpy.clear());
    });

    test('Set date of syncronization on state after calling source get all',
        () async {
      when(sourceMock.getAll()).thenAnswer((_) async => Right([]));
      await sut.getAll();
      verify(stateSpy.setLastRefresh(any));
    });

    test(
        'forwards getById operation to source and inserts when element not in cache',
        () async {
      final tId = UniqueId('123');
      when(sourceMock.getById(any)).thenAnswer(
          (_) async => Right(TodoItem(id: '123', title: 'Test task')));
      final result = await sut.getById(tId);
      final entityOrNull = result.getOrElse(() => null);

      expect(entityOrNull, isNotNull);
      verify(cacheSpy.add(entityOrNull));
    });

    test(
        'forwards getById operation to source and updates when element in cache',
        () async {
      final tId = UniqueId('123');
      final tEntity = TodoItem(id: '123', title: 'Test task');
      when(sourceMock.getById(any)).thenAnswer((_) async => Right(tEntity));

      await cacheSpy.add(tEntity);
      final result = await sut.getById(tId);

      final entityOrNull = result.getOrElse(() => null);

      expect(entityOrNull, isNotNull);
      verify(cacheSpy.update(entityOrNull));
    });
  });

  // =============== Write operations =============== //
  group('Device is online Write operations ', () {
    setUp(() {
      when(networkCheckerMock.isConnected).thenAnswer((_) async => true);
      when(sourceMock.delete(any)).thenAnswer((_) async => Right(null));
      when(stateSpy.shouldFetchFresh).thenReturn(false);
    });

    test('add calls source.add and pipes result to cache.add', () async {
      final tEntity = TodoItem.newItem('test task');
      final tEntityNew = tEntity.copyWith(id: '999');

      when(sourceMock.add(any)).thenAnswer((_) async => Right(tEntityNew));
      final result = await sut.add(tEntity);

      verify(sourceMock.add(tEntity)).called(1);
      verifyNever(stateSpy.shouldFetchFresh);
      verify(cacheSpy.add(tEntityNew));
      expect(result, Right(tEntityNew));
    });

    test('delete calls source.delete followed by cache.delete', () async {
      final tEntity = TodoItem(title: 'test task', id: '987');

      final result = await sut.delete(tEntity);
      verify(sourceMock.delete(tEntity)).called(1);
      verify(cacheSpy.delete(tEntity)).called(1);
      verifyNever(stateSpy.shouldFetchFresh);
      assert(result.isRight());
    });

    test('update calls source.update followed by cache.update', () async {
      final tEntity = TodoItem(title: 'test task', id: '987');
      when(sourceMock.update(any)).thenAnswer((_) async => Right(null));

      final result = await sut.update(tEntity);
      verify(sourceMock.update(tEntity)).called(1);
      verify(cacheSpy.update(tEntity)).called(1);
      verifyNever(stateSpy.shouldFetchFresh);
      assert(result.isRight());
    });
  });
  // =============== Offline Write operations =============== //
  group('Offline Write operations', () {
    setUp(() {
      when(networkCheckerMock.isConnected).thenAnswer((_) async => false);
      when(stateSpy.shouldFetchFresh).thenReturn(false);
    });
    test('add returns connection failure', () async {
      final tEntity = TodoItem.newItem('test task');
      final result = await sut.add(tEntity);
      verifyNever(sourceMock.add(any));
      verifyNever(cacheSpy.add(any));
      verify(networkCheckerMock.isConnected).called(1);
      expect(result, Left(RepositoryFailure.connectivity()));
    });

    test('update returns connection failure', () async {
      final tUniqueId = UniqueId('123');
      final tEntity = TodoItem(id: tUniqueId.value, title: 'test task');

      final result = await sut.update(tEntity);
      verifyNever(sourceMock.update(any));
      verifyNever(cacheSpy.update(any));
      verify(networkCheckerMock.isConnected).called(1);
      expect(result, Left(RepositoryFailure.connectivity()));
    });

    test('delete returns connection failure', () async {
      final tUniqueId = UniqueId('123');
      final tEntity = TodoItem(id: tUniqueId.value, title: 'test task');
      final result = await sut.delete(tEntity);
      verifyNever(sourceMock.delete(any));
      verifyNever(cacheSpy.delete(any));
      verify(networkCheckerMock.isConnected).called(1);
      expect(result, Left(RepositoryFailure.connectivity()));
    });
  });

  // =============== Device is offline read operations  =============== //
  group('Device is offline read operations', () {
    setUp(() {
      when(networkCheckerMock.isConnected).thenAnswer((_) async => false);
      when(sourceMock.getAll()).thenAnswer((_) async => Right([]));
    });

    test('Returns connection failure if no internet and cache not hydrated',
        () {});

    test('getAll forward call to cache when expired cache valid time window',
        () async {
      when(stateSpy.shouldFetchFresh).thenReturn(true);
      final result = await sut.getAll();
      verify(cacheSpy.getAll());
      verifyNever(sourceMock.getAll());
    });

    test('getById forward call to cache even if expired cache', () async {
      when(stateSpy.shouldFetchFresh).thenReturn(true);
      final tUniqueId = UniqueId('123');
      final result = await sut.getById(tUniqueId);
      verify(cacheSpy.getById(tUniqueId));
      verifyNever(sourceMock.getById(any));
    });

    test('when using cached results doesnt reset timeout interval', () async {
      when(stateSpy.shouldFetchFresh).thenReturn(true);
      final result = await sut.getAll();
      verify(cacheSpy.getAll());
      verifyNever(stateSpy.setLastRefresh(any));
    });
  });
}
