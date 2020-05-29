import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:repository/src/repository_failure.dart';

import './repository.dart';
import './identifiable.dart';
import './network_info.dart';
import './task_extensions.dart';

/// RemoteFirstRepository coordinates two repository instances
///
/// The source of truth is the remote repository.
/// Only read operations are allowed offline.
class RemoteFirstRepository<Entity> extends Repository<Entity> {
  static Task<Either<RepositoryBaseFailure, T>> connectivityFailureTask<T>() =>
      Task(() => Future.value(Left(RepositoryFailure.connectivity())));

  final Repository<Entity> remoteRepository;
  final Repository<Entity> cacheRepository;

  final NetworkInfo networkChecker;

  RemoteFirstRepository({
    @required this.networkChecker,
    @required this.remoteRepository,
    @required this.cacheRepository,
  });

  /// Adds new entity
  ///
  /// Fails if remote fails. Caches only when remote succeeds.
  @override
  Future<Either<RepositoryBaseFailure, Entity>> add(Entity entity) {
    final task =
        Task(() => remoteRepository.add(entity)).bindEither((createdEntity) {
      return Task(() => cacheRepository.add(createdEntity ?? entity));
    });

    return Task(() => networkChecker.isConnected)
        .flatMap((isConnected) =>
            isConnected ? task : connectivityFailureTask<Entity>())
        .run();
  }

  /// Delete entity
  ///
  /// Fails is remote fails.
  /// Deletes from cache only when first deleted from remote
  @override
  Future<Either<RepositoryBaseFailure, void>> delete(Entity entity) {
    final task = Task(() => remoteRepository.delete(entity)).bindEither((_) {
      return Task(() => cacheRepository.delete(entity));
    });

    return Task(() => networkChecker.isConnected)
        .flatMap((isConnected) =>
            isConnected ? task : connectivityFailureTask<void>())
        .run();
  }

  /// Get all entities
  ///
  /// If remote succeeds results are cached.
  /// If remote fails fallback to cache result.
  @override
  Future<Either<RepositoryBaseFailure, List<Entity>>> getAll() {
    final cacheTask = Task(() => cacheRepository.getAll());
    final remoteTask = Task(() => remoteRepository.getAll());

    final task = remoteTask.bindEither((list) {
      return Task(() async {
        await clearAllFromCache();
        for (final entity in list) {
          await cacheRepository.add(entity);
        }

        return Right(list);
      });
    }).orDefault(cacheTask);

    return Task(() => networkChecker.isConnected)
        .flatMap((hasConnection) => hasConnection ? task : cacheTask)
        .run();
  }

  /// Get entity by id
  ///
  /// If remote succeeds the entity is cached.
  /// If remote fails fallback to cache result.
  @override
  Future<Either<RepositoryBaseFailure, Entity>> getById(UniqueId id) {
    final cacheTask = Task(() => cacheRepository.getById(id));
    final remoteTask = Task(() => remoteRepository.getById(id));

    final task = remoteTask.bindEither((entity) {
      return Task(() async {
        await cacheRepository.add(entity);
        return Right(entity);
      });
    }).orDefault(cacheTask);

    return Task(() => networkChecker.isConnected)
        .flatMap((hasConnection) => hasConnection ? task : cacheTask)
        .run();
  }

  /// Update entity
  /// Fails on any remote failure
  /// Caches only when remote update succeeds
  @override
  Future<Either<RepositoryBaseFailure, void>> update(Entity entity) {
    final task = Task(() => remoteRepository.update(entity)).bindEither((_) {
      return Task(() => cacheRepository.update(entity));
    });

    return Task(() => networkChecker.isConnected)
        .flatMap((isConnected) =>
            isConnected ? task : connectivityFailureTask<void>())
        .run();
  }

  // =========================== Helpers ===================
  Future<void> clearAllFromCache() async {
    final result = await cacheRepository.getAll();
    final List<Entity> entities = result.fold((_) => [], (lst) => lst);

    for (final entity in entities) {
      await cacheRepository.delete(entity);
    }
  }
}
