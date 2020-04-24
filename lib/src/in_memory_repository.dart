import 'package:dartz/dartz.dart';

import './repository.dart';
import './identifiable.dart';

class InMemoryRepository<E extends WithId> implements Repository<E> {
  static const void unit = null;

  final Map<String, E> entitySet;

  factory InMemoryRepository.fromList(List<E> entities) {
    final map = Map<String, E>.fromEntries(
        entities.map((e) => MapEntry(e.stringedId, e)));
    return InMemoryRepository._(map);
  }

  factory InMemoryRepository.blank() {
    return InMemoryRepository<E>._({});
  }

  InMemoryRepository._(this.entitySet);

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
    final list = entitySet.values.toList();
    return Right(list);
  }

  @override
  Future<Either<Failure, E>> getById(UniqueId id) async {
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

  @override
  Future<Either<Failure, E>> edit<O extends E>(UniqueId id, O operation) {
    throw UnimplementedError();
    final entity = entitySet[id.value];
    return Future.value(Right(entity));
  }
}
