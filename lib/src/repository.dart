import 'package:dartz/dartz.dart';
import 'package:repository/src/repository_failure.dart';

import './identifiable.dart';
import './task_extensions.dart';

abstract class Repository<EntityType> {
  /// Saves a new instance to repository
  ///
  /// The newly created entity might get modified by the repository
  /// e.g gets a new Id. But could also be null.
  Future<Either<Failure, EntityType>> add(EntityType entity);

  /// Completely remove the entity instance from repository
  Future<Either<Failure, void>> delete(EntityType entity);
  Future<Either<Failure, List<EntityType>>> getAll();

  /// Returns the object with the given a unique id, or null if not present.
  Future<Either<Failure, EntityType>> getById(UniqueId id);

  /// Replaces an entity present in the repository
  /// by the provided one.
  /// Note: Concrete implementation will more likely constraints
  /// EntityType to be have an Id or be equatable.
  Future<Either<Failure, void>> update(EntityType entity);

  /// Performs some edit operation on a already present entity.
  Future<Either<Failure, EntityType>> edit<O extends EntityType>(
      UniqueId id, O operation);
}

extension RepositoryExtensions on Repository {
  Future<Either<Failure, void>> clear() async {
    final result = Task(() => getAll()).bindEither((items) => Task(() async {
          for (final item in items) {
            await delete(item);
          }
          return;
        }));

    return result.run();
  }
}
