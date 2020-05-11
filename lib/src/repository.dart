import 'package:dartz/dartz.dart';
import 'package:repository/repository.dart';
import 'package:repository/src/repository_failure.dart';
import './identifiable.dart';
import './task_extensions.dart';

abstract class Add<EntityType> {
  /// Saves a new instance to repository
  ///
  /// The newly created entity might get modified by the repository
  /// e.g gets a new Id. But could also be null.
  Future<Either<Failure, EntityType>> add(EntityType entity);
}

abstract class GetAll<EntityType> {
  Future<Either<Failure, List<EntityType>>> getAll();
}

abstract class Delete<EntityType> {
  /// Completely remove the entity instance from repository
  Future<Either<Failure, void>> delete(EntityType entity);
}

abstract class GetById<EntityType> {
  /// Returns the object with the given a unique id, or null if not present.
  Future<Either<Failure, EntityType>> getById(UniqueId id);
}

abstract class Update<EntityType> {
  /// Replaces an entity present in the repository
  /// by the provided one.
  /// Note: Concrete implementation will more likely constraints
  /// EntityType to be have an Id or be equatable.
  Future<Either<Failure, void>> update(EntityType entity);
}

/// Edit provides partial updates of entities.
///
/// Edit is a more complex operation since in some cases it could be expressed as a function
/// and others like a Map<String, dynamic>.
/// Note: Edit is not part of the repository definition as this would imply
/// Extending all repositories to have 2 type variables.
abstract class Edit<Operation, EntityType> {
  /// Performs some edit operation on a already present entity.
  Future<Either<Failure, EntityType>> edit(UniqueId id, Operation operation);
}

abstract class ReadOnlyRepository<EntityType>
    with GetAll<EntityType>, GetById<EntityType> {}

abstract class WriteOnlyRepository<EntityType>
    with Add<EntityType>, Delete<EntityType>, Update<EntityType> {}

abstract class Repository<EntityType> extends ReadOnlyRepository<EntityType>
    implements WriteOnlyRepository<EntityType> {}

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
