import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:repository/repository.dart';
import 'package:repository/src/cache_repository.dart';

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
  CacheRepository<TodoItem> sut;
  RepositorySpy<TodoItem> cacheSpy;
  CacheStateSpy stateSpy;
  MockNetworkCheker networkChekerMock;
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

    cacheSpy = RepositorySpy(
        realRepository: InMemoryRepository.blank(),
        clearAction: (repository) {
          repository = InMemoryRepository.blank();
        });

    stateSpy = CacheStateSpy(CacheState(policy));

    sut = CacheRepository(
      policy: null,
      state: stateSpy,
      cache: cacheSpy,
      source: sourceMock,
      networkChecker: networkChekerMock,
    );
  });

  group('timeout threshold not exceeded', () {
    test('forwards getAll operation to cache', () async {
      when(stateSpy.shouldFetchFresh).thenReturn(false);
      final result = await sut.getAll();
      verify(cacheSpy.getAll()).called(1);
      verifyZeroInteractions(sourceMock);
      verify(stateSpy.shouldFetchFresh);
    });
    test('forwards getById operation to cache', () async {});
  });

  group('Device is online', () {
    test('calls source getAll when cache is invalidated', () async {
      when(sourceMock.getAll())
          .thenAnswer((_) async => Right(tTodoItemsWithID));
      when(stateSpy.shouldFetchFresh).thenReturn(true);
      final result = await sut.getAll();
      verify(sourceMock.getAll()).called(1);
      verifyNever(cacheSpy.getAll());
      verify(stateSpy.shouldFetchFresh);
    });

    test('populates cache when calling source getAll', () async {
      when(stateSpy.shouldFetchFresh).thenReturn(true);
      when(sourceMock.getAll())
          .thenAnswer((_) async => Right(tTodoItemsWithID));
      final result = await sut.entityCount;
      final cacheResult = await cacheSpy.entityCount;
      verify(cacheSpy.add(any)).called(tTodoItemsWithID.length);
      expect(result, cacheResult);
      expect(cacheResult, tTodoItemsWithID.length);
    });

    test('clears cache before populiting when calling source getAll', () async {
      when(sourceMock.getAll())
          .thenAnswer((_) async => Right(tTodoItemsWithID));
      when(stateSpy.shouldFetchFresh).thenReturn(true);
      await cacheSpy.add(TodoItem(id: 'asdasd', title: 'Test task'));
      final cacheCountBefore = await cacheSpy.entityCount;
      final result = await sut.entityCount;
      verify(cacheSpy.clear());
    });

    test('Set date of syncronization on state after calling source get all',
        () async {
      when(stateSpy.shouldFetchFresh).thenReturn(true);
      when(sourceMock.getAll())
          .thenAnswer((_) async => Right(tTodoItemsWithID));
      when(sourceMock.getAll());
      await sut.getAll();
      verify(stateSpy.setLastRefresh(any));
    });

    group('timeout threshold exceeded', () {
      test('forwards getAll operation to source clears and updates cache',
          () async {});
      test('forwards getById operation to source and upserts cache',
          () async {});
    });
  });

  group('Device is offline', () {
    group('timeout threshold exceeded', () {
      test('fails and clears cache if configuration is so', () async {});

      test('uses cached results if configuration is so', () async {});

      test('when using cached results doesnt reset timeout interval', () {});
    });
  });
}
