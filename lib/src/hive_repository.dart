import 'package:repository/src/repository_failure.dart';

import './repository.dart';
import './identifiable.dart';
import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';

/// HiveRepository
///
/// Requires a TypeAdapter<Entity> to be registered.
class HiveRepository<Entity extends WithId> extends Repository<Entity> {
  final Box<Entity> _hiveBox;
  static const void unit = null;

  HiveRepository({@required Box<Entity> box}) : _hiveBox = box;

  bool get isBoxClosed => !(_hiveBox?.isOpen ?? false);

  @override
  Future<Either<RepositoryBaseFailure, Entity>> add(Entity entity) async {
    if (isBoxClosed) {
      return null;
    }

    await _hiveBox.put(entity.stringedId, entity);
    return Right(entity);
  }

  @override
  Future<Either<RepositoryBaseFailure, void>> delete(Entity entity) async {
    await _hiveBox.delete(entity.stringedId);
    return Right(unit);
  }

  @override
  Future<Either<RepositoryBaseFailure, List<Entity>>> getAll() {
    final allObjects = _hiveBox.toMap().values.toList();
    return Future.value(Right(allObjects));
  }

  @override
  Future<Either<RepositoryBaseFailure, Entity>> getById(UniqueId id) {
    if (isBoxClosed) {
      return null;
    }

    final object = _hiveBox.get(id.value) as Entity;

    return Future.value(Right(object));
  }

  @override
  Future<Either<RepositoryBaseFailure, void>> update(Entity entity) async {
    await _hiveBox.put(entity.stringedId, entity);
    return Future.value(Right(unit));
  }

  @override
  Future<Either<RepositoryBaseFailure, Entity>> edit<O extends Entity>(
      UniqueId id, O operation) {
    throw UnimplementedError();
  }
}
