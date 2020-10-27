import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mockito/mockito.dart';
import 'package:repository/repository.dart';
import 'todo_item.dart';

class MockRemoteRepository extends Mock implements Repository<TodoItem> {}

class MockLocalRepository with Mock implements Repository<TodoItem> {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  RemoteFirstRepository sut;
  MockRemoteRepository mockRemoteRepository;
  MockLocalRepository mockLocalRepository;
  MockNetworkInfo mockNetworkChecker;

  final listEquality = const ListEquality().equals;
  final tEntity = TodoItem.newItem('test task');
  final tUniqueId = UniqueId('0');
  final tEntities = [
    TodoItem.newItem('Task1'),
    TodoItem.newItem('Task2'),
    TodoItem.newItem('Task3'),
    TodoItem.newItem('Task4'),
  ];
  const void unit = null;

  setUp(() {
    mockRemoteRepository = MockRemoteRepository();
    mockLocalRepository = MockLocalRepository();
    mockNetworkChecker = MockNetworkInfo();

    sut = RemoteFirstRepository(
        networkChecker: mockNetworkChecker,
        cacheRepository: mockLocalRepository,
        remoteRepository: mockRemoteRepository);
  });

  tearDown(() {
    // sut.clearAllFromCache();
  });

// ======================== Online tests ========================
  group('Device is online', () {
    setUp(() {
      when(mockNetworkChecker.isConnected).thenAnswer((_) async => true);
    });

    group('add operation', () {
      test('fails when remote repository fails', () async {
        //arrange
        when(mockRemoteRepository.add(any))
            .thenAnswer((_) async => Left(RepositoryFailure.server('')));
        final result = await sut.add(tEntity);
        expect(result, Left(RepositoryFailure.server('')));
      });
      test('does not call cache when remote repository fails', () async {
        when(mockRemoteRepository.add(any))
            .thenAnswer((_) async => Left(RepositoryFailure.server('')));
        await sut.add(tEntity);
        verify(mockRemoteRepository.add(tEntity));
        verifyZeroInteractions(mockLocalRepository);
      });

      test('calls cache when remote repository succeeds', () async {
        when(mockRemoteRepository.add(any))
            .thenAnswer((_) async => Right(tEntity));
        await sut.add(tEntity);
        verify(mockLocalRepository.add(tEntity));
      });
    });

    group('delete operation', () {
      test('fails when remote repository fails', () async {
        //arrange
        when(mockRemoteRepository.delete(any))
            .thenAnswer((_) async => Left(RepositoryFailure.server('')));
        final result = await sut.delete(tEntity);
        expect(result, Left(RepositoryFailure.server('')));
      });
      test('does not call cache when remote repository fails', () async {
        when(mockRemoteRepository.delete(any))
            .thenAnswer((_) async => Left(RepositoryFailure.server('')));
        await sut.delete(tEntity);
        verify(mockRemoteRepository.delete(tEntity));
        verifyZeroInteractions(mockLocalRepository);
      });

      test('calls cache when remote repository succeeds', () async {
        when(mockRemoteRepository.delete(any))
            .thenAnswer((_) async => Right(unit));
        await sut.delete(tEntity);
        verify(mockLocalRepository.delete(tEntity));
      });
    });
    group('update operation', () {
      test('fails when remote repository fails', () async {
        //arrange
        when(mockRemoteRepository.update(any))
            .thenAnswer((_) async => Left(RepositoryFailure.server('')));
        final result = await sut.update(tEntity);
        expect(result, Left(RepositoryFailure.server('')));
      });
      test('does not call cache when remote repository fails', () async {
        when(mockRemoteRepository.update(any))
            .thenAnswer((_) async => Left(RepositoryFailure.server('')));
        await sut.update(tEntity);
        verify(mockRemoteRepository.update(tEntity));
        verifyZeroInteractions(mockLocalRepository);
      });

      test('calls cache when remote repository succeeds', () async {
        when(mockRemoteRepository.update(any))
            .thenAnswer((_) async => Right(unit));
        await sut.update(tEntity);
        verify(mockLocalRepository.update(tEntity));
      });
    });

    // READ OPERATIONS
    group('get all operation', () {
      test('overwrites data in cache when remote succeeds', () async {
        when(mockLocalRepository.getAll())
            .thenAnswer((_) async => Right([tEntity]));
        when(mockRemoteRepository.getAll())
            .thenAnswer((_) async => Right(tEntities));

        final result = await sut.getAll();

        verify(mockLocalRepository.delete(any)).called(1);
      });

      test('falls back to cache when remote fails', () async {
        when(mockRemoteRepository.getAll())
            .thenAnswer((_) async => Left(RepositoryFailure.server('')));
        when(mockLocalRepository.getAll())
            .thenAnswer((_) async => Right(tEntities));

        final result = await sut.getAll();
        final entities = result.fold((_) => [], (v) => v);

        assert(result.isRight());
        assert(listEquality(entities, tEntities));
        verify(mockRemoteRepository.getAll());
        verify(mockLocalRepository.getAll());
      });

      test(
          'caches every entity gotten from remote when remote fetch is succesful',
          () async {
        when(mockRemoteRepository.getAll())
            .thenAnswer((_) async => Right(tEntities));
        when(mockLocalRepository.getAll()).thenAnswer((_) async => Right([]));

        final result = await sut.getAll();
        assert(result.isRight());
        verify(mockLocalRepository.add(any)).called(tEntities.length);
      });
    });
    group('get by id', () {
      test('falls back to cache when remote fails', () async {
        when(mockRemoteRepository.getById(any))
            .thenAnswer((_) async => Left(RepositoryFailure.server('')));
        when(mockLocalRepository.getById(any))
            .thenAnswer((_) async => Right(tEntity));

        final result = await sut.getById(tUniqueId);

        expect(result, Right(tEntity));
        verify(mockRemoteRepository.getById(tUniqueId));
        verify(mockLocalRepository.getById(tUniqueId));
      });

      test(
          'caches every entity gotten from remote when remote fetch is succesful',
          () async {
        when(mockRemoteRepository.getById(any))
            .thenAnswer((_) async => Right(tEntity));

        final result = await sut.getById(tUniqueId);
        assert(result.isRight());
        verify(mockLocalRepository.add(any)).called(1);
      });
    });
  });

// ======================== Offline tests ========================
  group('Device is offline', () {
    setUp(() {
      when(mockNetworkChecker.isConnected).thenAnswer((_) async => false);
    });
    group('get by id', () {
      test('calls cache directly if internet connectivity is down', () async {
        when(mockLocalRepository.getById(any))
            .thenAnswer((_) async => Right(tEntity));

        final result = await sut.getById(tUniqueId);

        expect(result, Right(tEntity));
        verify(mockLocalRepository.getById(tUniqueId));
        verifyZeroInteractions(mockRemoteRepository);
      });
    });

    group('get all', () {
      test('calls cache directly if internet connectivity is down', () async {
        when(mockLocalRepository.getAll())
            .thenAnswer((_) async => Right(tEntities));

        await sut.getAll();

        verify(mockLocalRepository.getAll());
        verifyZeroInteractions(mockRemoteRepository);
      });
    });

    group('add operation', () {
      test('fails withouth calling remote when connectiviy is down', () async {
        final result = await sut.add(tEntity);
        verifyZeroInteractions(mockRemoteRepository);
        expect(result, Left(RepositoryFailure.connectivity()));
      });
    });

    group('delete operation', () {
      test('fails withouth calling remote when connectiviy is down', () async {
        final result = await sut.delete(tEntity);
        verifyZeroInteractions(mockRemoteRepository);
        expect(result, Left(RepositoryFailure.connectivity()));
      });
    });

    group('update operation', () {
      test('fails withouth calling remote when connectiviy is down', () async {
        final result = await sut.update(tEntity);
        verifyZeroInteractions(mockRemoteRepository);

        final error = result.fold((err) => err, (_) => null);

        expect(error, RepositoryFailure.connectivity());
        expect(error, isA<RepositoryFailure>());
      });
    });
  });
}
