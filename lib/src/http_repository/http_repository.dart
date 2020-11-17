import 'dart:convert' show JsonCodec;

import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';

import '../base/repository.dart';
import '../base/repository_failure.dart';
import '../base/repository_operation.dart';
import 'http_exception.dart';
import '../base/identifiable.dart';

typedef HttpRepositoryProccesingFunction = Future<dynamic> Function(
    RepositoryOperation, Map<String, dynamic>, String url);

/// Flexible json HTTP repository
///
/// Allows conditional parsing based on RepositoryOperation
/// Can do non restful implementations by providing different url per RepositoryOperation.
/// Note: an HttpFailure is returned if a response si outside the 200 range.
class HttpRepository<Entity> extends Repository<Entity>
    implements Edit<Map<String, dynamic>, Entity> {
  final Map<String, dynamic> Function(Entity, RepositoryOperation) toJson;
  final Entity Function(Map<String, dynamic>, RepositoryOperation) fromJson;
  final String Function(RepositoryOperation, Entity, UniqueId id)
      operationUrl; // Entity might be null for some operations
  final HttpRepositoryProccesingFunction process;
  final JsonCodec jsonCodec;

  static const void unit = null;

  String resourceURLForEntity(Entity entity, RepositoryOperation operation,
      {UniqueId id}) {
    final url = operationUrl(operation, entity, id);
    return url;
  }

  HttpRepository({
    @required this.operationUrl,
    JsonCodec jsonCodec,
    @required this.toJson,
    @required this.process,
    @required this.fromJson,
  }) : this.jsonCodec = jsonCodec ?? JsonCodec();

  @override
  Future<Either<RepositoryBaseFailure, Entity>> add(Entity entity) {
    final task = Task(() async {
      final url = resourceURLForEntity(entity, RepositoryOperation.add);
      final jsonMap = toJson(entity, RepositoryOperation.add);
      jsonMap.removeWhere((key, value) => value == null);

      final response = await process(RepositoryOperation.add, jsonMap, url)
          as Map<String, dynamic>;

      final createdObject = fromJson(response, RepositoryOperation.add);
      return createdObject;
    }).attempt().map(
        (either) => either.leftMap((errorObj) => handleException(errorObj)));
    return task.run();
  }

  @override
  Future<Either<RepositoryBaseFailure, void>> delete(Entity entity) {
    final url = resourceURLForEntity(entity, RepositoryOperation.delete);
    final task = Task(() async {
      final response = await process(RepositoryOperation.delete, null, url);
      return response;
    }).attempt().map((either) => either
        .leftMap((errorObj) => RepositoryFailure.server('$errorObj'))
        .map((_) => unit));
    return task.run();
  }

  @override
  Future<Either<RepositoryBaseFailure, List<Entity>>> getAll() {
    final task = Task(() async {
      final url = resourceURLForEntity(null, RepositoryOperation.getAll);

      final response =
          await process(RepositoryOperation.getAll, null, url) as List<dynamic>;

      final objects = response
          .map((jsonMap) => fromJson(
              jsonMap as Map<String, dynamic>, RepositoryOperation.getAll))
          .toList();

      return objects;
    }).attempt().map((either) => either.leftMap(
          (errorObj) => handleException(errorObj),
        ));

    return task.run();
  }

  @override
  Future<Either<RepositoryBaseFailure, Entity>> getById(UniqueId id) {
    final task = Task(() async {
      final url =
          resourceURLForEntity(null, RepositoryOperation.getById, id: id);
      final response = await process(RepositoryOperation.getById, null, url)
          as Map<String, dynamic>;
      final object = fromJson(response, RepositoryOperation.getById);
      return object;
    })
        .attempt()
        .map((either) => either.leftMap((error) => handleException(error)));

    return task.run();
  }

  @override
  Future<Either<RepositoryBaseFailure, void>> update(Entity entity) async {
    final task = Task(() async {
      final url = resourceURLForEntity(entity, RepositoryOperation.update);
      final jsonMap = toJson(entity, RepositoryOperation.update);
      final response = await process(RepositoryOperation.update, jsonMap, url);
      return response;
    }).attempt().map(
        (either) => either.leftMap((e) => handleException(e)).map((_) => unit));
    return task.run();
  }

  @override
  Future<Either<RepositoryBaseFailure, Entity>> edit(
      UniqueId id, Map<String, dynamic> operation) {
    final task = Task(() async {
      final patch = operation;
      patch.removeWhere((key, value) => value == null);

      final url = resourceURLForEntity(null, RepositoryOperation.edit, id: id);
      final responseMap = await process(RepositoryOperation.edit, patch, url)
          as Map<String, dynamic>;
      final object = fromJson(responseMap, RepositoryOperation.edit);

      return object;
    }).attempt().map(
          (either) => either.leftMap((error) => handleException(error)),
        );

    return task.run();
  }

  RepositoryBaseFailure handleException(Exception error) {
    if (error is HttpException) {
      return HttpFailure.fromException(error);
    }
    return RepositoryFailure.server('$error');
  }
}
