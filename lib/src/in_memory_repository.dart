import 'package:dartz/dartz.dart';
import 'package:repository/src/repository_failure.dart';

import './repository.dart';
import './identifiable.dart';

typedef Endo<T> = void Function(T);

class InMemoryRepository<E extends WithId> implements Repository<E> {
  static const void unit = null;

  final Map<String, E> entitySet;

  final Duration delay;

  factory InMemoryRepository.fromList(List<E> entities, {Duration delay}) {
    final map = Map<String, E>.fromEntries(
        entities.map((e) => MapEntry(e.stringedId, e)));
    return InMemoryRepository._(map, delay);
  }

  factory InMemoryRepository.blank({Duration delay}) {
    return InMemoryRepository<E>._({}, delay);
  }

  InMemoryRepository._(this.entitySet, Duration delay)
      : this.delay = delay ?? const Duration(seconds: 0);

  String entityId(E entity) => entity.stringedId;

  @override
  Future<Either<Failure, E>> add(E entity) async {
    final id = entityId(entity);
    entitySet[id] = entity;
    return Right(entity);
  }

  @override
  Future<Either<Failure, void>> delete(E entity) async {
    entitySet.removeWhere((key, value) => value == entity);
    return Right(unit);
  }

  @override
  Future<Either<Failure, List<E>>> getAll() async {
    await Future.delayed(delay);
    final list = entitySet.values.toList();
    return Right(list);
  }

  @override
  Future<Either<Failure, E>> getById(UniqueId id) async {
    await Future.delayed(delay);
    final entity = entitySet[id.value];
    if (entity == null)
      return Left(RepositoryFailure.cache('Entity not found'));
    return Right(entity);
  }

  @override
  Future<Either<Failure, void>> update(E entity) async {
    final id = entityId(entity);
    entitySet[id] = entity;
    return Right(unit);
  }

  // @override
  // Future<Either<Failure, E>> edit(UniqueId id, operation) async {
  //   final entity = entitySet[id.value];
  //   if (entity == null)
  //     return Left(RepositoryFailure.cache('Entity not found'));

  //   final updated = operation(entity);
  //   return Right(updated);
  // }
}
