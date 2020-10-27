import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:repository/src/identifiable.dart';
import 'package:repository/repository.dart';
import 'package:uuid/uuid.dart';
import './spies/repository_spy.dart';
import 'todo_item.dart';
import 'repository_extensions.dart';

class MockRemoteRepository extends Mock implements Repository<TodoItem> {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  OfflineFirstRepository<TodoItem> sut;
  MockRemoteRepository mockRemoteRepository;
  RepositorySpy<Synchronized<TodoItem>> mockLocalRepository;
  MockNetworkInfo mockNetworkInfo;

  final tTodoItem = TodoItem.newItem('test task');
  final tTodoItems = [
    TodoItem.newItem('Task1'),
    TodoItem.newItem('Task2'),
    TodoItem.newItem('Task3'),
    TodoItem.newItem('Task4'),
  ];

  setUp(() {
    mockLocalRepository = RepositorySpy(
        realRepository: InMemoryRepository.blank(),
        clearAction: (repository) {
          repository = InMemoryRepository.blank();
        });

    mockRemoteRepository = MockRemoteRepository();
    mockNetworkInfo = MockNetworkInfo();
    sut = OfflineFirstRepository(
      remote: mockRemoteRepository,
      local: mockLocalRepository,
      networkChecker: mockNetworkInfo,
    );
  });

  tearDown(() {
    mockLocalRepository.tearDown();
  });

  group('CRUD', () {
    test('''Update does not mark entity needsUpdate when 
    entity is already marked  needsCreation''', () async {
      final updatedItem = tTodoItem.copyWith(title: 'new title');

      await sut.add(tTodoItem);
      await sut.update(updatedItem);
      final result = await mockLocalRepository.realRepository
          .getById(UniqueId(tTodoItem.primaryKey));
      final wrapper = result.withDefault(null);

      expect(wrapper.entity, updatedItem);
      expect(wrapper.status, SynchronizationStatus.needsCreation);
    });
    test('Does not interact with remote on any operations', () async {
      final tTodoItemUpdated = tTodoItem.copyWith(title: 'test task 2');
      await sut.add(tTodoItem);
      await sut.update(tTodoItemUpdated);
      await sut.delete(tTodoItem);

      verify(mockLocalRepository.add(any));
      verify(mockLocalRepository.update(any));
      verifyZeroInteractions(mockRemoteRepository);
    });

    test('''Calls update with needsDeletion on local repository 
      when performing a delete''', () async {
      final tSynchronized = Synchronized(
          entity: tTodoItem, status: SynchronizationStatus.needsDeletion);
      await sut.delete(tTodoItem);
      verify(mockLocalRepository.update(tSynchronized));
    });

    test(
        '''getAll returns all cached items except those marked with needsDeletion 
      from local when succesful''', () async {
      final tTodoItem2 = TodoItem.newItem('Some other task');
      await sut.add(tTodoItem);
      await sut.add(tTodoItem2);
      await sut.delete(tTodoItem);
      final count = await sut.entityCount;
      final inCacheCount = await mockLocalRepository.realRepository.entityCount;

      expect(count, 1);
      expect(inCacheCount, greaterThan(count));
    });
  });
  test('Local repository sized is preserved when only performing updates',
      () async {
    final countBefore = await mockLocalRepository.realRepository.entityCount;
    sut.add(tTodoItem.copyWith(id: '1234'));
    sut.update(tTodoItem.copyWith(completed: true));
    final countAfter = await mockLocalRepository.realRepository.entityCount;
    expect(countAfter, 1);
    expect(countBefore, isNot(countAfter));
  });
  // ================== Hydrate ==================
  group('Hydrate repository', () {
    setUp(() {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
    });
    test('Calls add when entity not already in cache', () async {
      final tTodoItemFromServer =
          TodoItem.newItem('Created online').copyWith(id: '1234');

      when(mockRemoteRepository.getAll())
          .thenAnswer((_) async => Right([tTodoItemFromServer]));

      await sut.hydrate();

      final wrapper = Synchronized(
          entity: tTodoItemFromServer, status: SynchronizationStatus.synced);
      verify(mockRemoteRepository.getAll());
      verify(mockLocalRepository.add(wrapper));
    });

    test('Calls update when entity already in cache', () async {
      final tTodoItemFromServer = tTodoItem.copyWith(id: '1234');

      when(mockRemoteRepository.getAll())
          .thenAnswer((_) async => Right([tTodoItemFromServer]));

      await sut.add(tTodoItem);
      await sut.hydrate();

      final wrapper = Synchronized(
          entity: tTodoItemFromServer, status: SynchronizationStatus.synced);
      verify(mockRemoteRepository.getAll());
      verify(mockLocalRepository.update(any));
    });
  });

  // ================== Synchronize ==================
  group('Synchronize', () {
    setUp(() {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
    });

    test('wrapper primary key is preserved after sync', () async {
      when(mockRemoteRepository.add(any)).thenAnswer((inv) async {
        final itemWithId = (inv.positionalArguments.first as TodoItem)
            .copyWith(id: Uuid().v1());
        return Right(itemWithId);
      });

      await sut.add(tTodoItem);
      await sut.synchronize();

      final entity = await sut.getFirst;
      await sut.update(entity.copyWith(completed: true));
      final entityCount = await sut.entityCount;
      final wrapper = await mockLocalRepository.realRepository.getFirst;

      expect(wrapper.key, tTodoItem.primaryKey);
      expect(wrapper.key, wrapper.entity.primaryKey);
      expect(wrapper.entity.primaryKey, tTodoItem.primaryKey);
      expect(tTodoItem.id, null);
      expect(entity.id, isNotNull);
      expect(entityCount, 1);
    });

    test('Deletes from cache iff deleting on remote succeded', () async {
      when(mockRemoteRepository.delete(any)).thenAnswer((_) async {
        return Left(RepositoryFailure.server(''));
      });

      await sut.add(tTodoItem);
      await sut.delete(tTodoItem);
      final inCacheResult = await mockLocalRepository.realRepository.getAll();
      final List<Synchronized<TodoItem>> inCacheItems =
          inCacheResult.fold((_) => [], (lst) => lst);
      final status = inCacheItems.first.status;

      expect(inCacheItems.length, 1);
      expect(status, SynchronizationStatus.needsDeletion);
    });

    test('Does not add to remote items that are in synced state', () async {
      when(mockRemoteRepository.add(any)).thenAnswer((inv) async {
        final itemWithId = (inv.positionalArguments.first as TodoItem)
            .copyWith(id: Uuid().v1());
        return Right(itemWithId);
      });

      await sut.add(tTodoItem);
      await sut.synchronize();
      await sut.synchronize();

      verify(mockRemoteRepository.add(tTodoItem)).called(1);
      verifyNoMoreInteractions(mockRemoteRepository);
    });
  });
}
