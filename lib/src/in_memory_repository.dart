import 'package:dartz/dartz.dart';
import './base/repository_failure.dart';

import './base/repository.dart';
import './base/identifiable.dart';

typedef Endo<T> = void Function(T);

class InMemoryRepository<E extends WithId> implements Repository<E> {
  static const void unit = null;

  Map<String, E> _entitySet;

  final Duration delay;

  factory InMemoryRepository.fromList(List<E> entities, {Duration delay}) {
    final map = Map<String, E>.fromEntries(
        entities.map((e) => MapEntry(e.stringedId, e)));
    return InMemoryRepository._(map, delay);
  }

  factory InMemoryRepository.blank({Duration delay}) {
    return InMemoryRepository<E>._({}, delay);
  }

  InMemoryRepository._(this._entitySet, Duration delay)
      : this.delay = delay ?? const Duration(seconds: 0);

  String entityId(E entity) => entity.stringedId;

  @override
  Future<Either<RepositoryBaseFailure, E>> add(E entity) async {
    final id = entityId(entity);
    _entitySet[id] = entity;
    return Right(entity);
  }

  @override
  Future<Either<RepositoryBaseFailure, void>> delete(E entity) async {
    _entitySet.removeWhere((key, value) => value == entity);
    return Right(unit);
  }

  @override
  Future<Either<RepositoryBaseFailure, List<E>>> getAll() async {
    await Future.delayed(delay);
    final list = _entitySet.values.toList();
    return Right(list);
  }

  @override
  Future<Either<RepositoryBaseFailure, E>> getById(UniqueId id) async {
    await Future.delayed(delay);
    final entity = _entitySet[id.value];
    if (entity == null)
      return Left(RepositoryFailure.cache('Entity not found'));
    return Right(entity);
  }

  @override
  Future<Either<RepositoryBaseFailure, void>> update(E entity) async {
    final id = entityId(entity);
    _entitySet[id] = entity;
    return Right(unit);
  }

  @override
  Future<Either<RepositoryBaseFailure, void>> clear() async {
    _entitySet = {};
    return null;
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
