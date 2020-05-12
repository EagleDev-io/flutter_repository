library offline_first_repository;

import 'package:repository/src/repository_failure.dart';

import '../repository.dart';
import '../identifiable.dart';
import '../network_info.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import '../task_extensions.dart';
import 'synchronization_batch_result.dart';
import 'synchronized.dart';

/// OfflineFirstRepository
///
/// Coordinates a local persistent repository with a remote.
/// All operation are performed first in the local repository.
/// Write operations are performed by tagging entities for later synchronization.

class OfflineFirstRepository<Entity extends WithIdAndPrimaryKey>
    implements Repository<Entity> {
  final Repository<Entity> remote;
  final Repository<Synchronized<Entity>> local;
  final NetworkInfo networkChecker;

  static Task<Either<RepositoryBaseFailure, T>> connectivityFailureTask<T>() =>
      Task(() => Future.value(Left(RepositoryFailure.connectivity())));

  OfflineFirstRepository({
    @required this.remote,
    @required this.local,
    @required this.networkChecker,
  });

  Synchronized<Entity> entityWithStatus(
      Entity entity, SynchronizationStatus status) {
    final result = Synchronized(status: status, entity: entity);
    return result;
  }

  @override
  Future<Either<RepositoryBaseFailure, Entity>> add(Entity entity) {
    final localTask = Task(() => local
            .add(entityWithStatus(entity, SynchronizationStatus.needsCreation)))
        .mapEither((entityWrapper) => entityWrapper.entity);
    return localTask.run();
  }

  /// Updates the local repository entity for deletion.
  ///
  /// Works by marking the entity for deletion which will later be deleted
  /// with a synchronization batch.
  @override
  Future<Either<RepositoryBaseFailure, void>> delete(Entity entity) async {
    final markedForDeletion =
        entityWithStatus(entity, SynchronizationStatus.needsDeletion);
    final result = await local.update(markedForDeletion);
    return result;
  }

  @override
  Future<Either<RepositoryBaseFailure, List<Entity>>> getAll() async {
    final result = await local.getAll();
    final filteredResult = result.map(
      (lst) => lst
          .where((wrapper) =>
              wrapper.status != SynchronizationStatus.needsDeletion)
          .map((wrapper) => wrapper.entity)
          .toList(),
    );

    return filteredResult;
  }

  @override
  Future<Either<RepositoryBaseFailure, Entity>> getById(UniqueId id) {
    return local
        .getById(id)
        .then((value) => value.map((wrapper) => wrapper.entity));
  }

  @override
  Future<Either<RepositoryBaseFailure, void>> update(Entity entity) {
    final findEntityTask = Task(() async {
      final result = await local.getById(UniqueId(entity.stringedId));
      return result;
    }).orDefault(Task(() async {
      final result = await local.getById(UniqueId(entity.stringedPrimaryKey));
      return result;
    }));

    final task = findEntityTask.bindEither((item) => Task(() {
          final newStatus = (item.status == SynchronizationStatus.synced)
              ? SynchronizationStatus.needsUpdate
              : item.status;
          final newWrapper = Synchronized(
            key: item.key,
            status: newStatus,
            entity: entity,
          );

          return local.update(newWrapper);
        }));

    return task.run();
  }

  /// Updated or insert entity into local repository
  /// Note: local Repository should fail if entity is null.
  Future<Either<RepositoryBaseFailure, void>> upsert(
      Synchronized<Entity> wrapper) {
    final findEntityTask = Task(() async {
      final result = await local.getById(UniqueId(wrapper.stringedId));
      return result;
    }).orDefault(Task(() async {
      final result =
          await local.getById(UniqueId(wrapper.entity.stringedPrimaryKey));
      return result;
    }));

    final task = findEntityTask
        .bindEither((wrapper) => Task(() {
              return local.update(wrapper);
            }))
        .orDefault(Task(() async {
      final newWrapper = wrapper;
      // newWrapper.key ??= wrapper.entity.stringedId;
      return local.add(newWrapper);
    }));
    return task.run();
  }

  /// Pull data from remote repository to populate local db
  /// Should update or insert new entities.
  Future<Either<RepositoryBaseFailure, void>> hydrate() {
    final remoteTask = Task(() => remote.getAll());

    final task = remoteTask.bindEither((list) {
      return Task(() async {
        for (final entity in list) {
          final Synchronized<Entity> entityWrapper =
              entityWithStatus(entity, SynchronizationStatus.synced);
          await upsert(entityWrapper);
        }

        return Right(list);
      });
    });

    return Task(() => networkChecker.isConnected)
        .flatMap(
            (hasConnection) => hasConnection ? task : connectivityFailureTask())
        .run();
  }

// ===================== Synchronization =====================
  Future<SynchronizationBatchResult> synchronize() async {
    int processed = 0;
    final List<RepositoryBaseFailure> failures = [];
    final hasInternetConnection = await networkChecker.isConnected;

    if (!hasInternetConnection) {
      return SynchronizationBatchResult(failures: [], proccessed: 0);
    }

    final entities =
        await local.getAll().then((either) => either.withDefault([]));

    for (final wrapper in entities) {
      Either<RepositoryBaseFailure, dynamic> result;
      final Entity entity = wrapper.entity;

      if (wrapper.status == SynchronizationStatus.needsUpdate) {
        result = await remote.update(wrapper.entity);
      } else if (wrapper.status == SynchronizationStatus.needsDeletion) {
        result = await Task(() => remote.delete(entity))
            .andThen(Task(() => local.delete(wrapper)))
            .orDefault(Task(() => local.delete(wrapper)))
            .run();
      } else if (wrapper.status == SynchronizationStatus.needsCreation) {
        result = await Task(() => remote.add(entity))
            .bindEither((newEntity) => Task(() {
                  final newWrapper = Synchronized(
                    key: wrapper.key,
                    entity: newEntity,
                    status: SynchronizationStatus.synced,
                  );
                  return local.update(newWrapper);
                }))
            .run();
      }

      if (result != null) {
        processed += 1;
        failures.add(result.failure());
      }
    }

    return SynchronizationBatchResult(
      proccessed: processed,
      failures: failures,
    );
  }
}
