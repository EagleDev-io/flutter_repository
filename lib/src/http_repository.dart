import 'dart:convert' show JsonCodec;

import 'package:repository/src/http_exception.dart';
import 'package:repository/src/repository_failure.dart';

import 'repository.dart';
import 'identifiable.dart';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

/// Implements CRUD for a well defined restful resource.
///
/// Note: an HttpFailure is returned if a response si outside the 200 range.
/// Resource nesting is not supported. To do this combine on or more RestfulRepository
/// instances.
class HttpRepository<Entity>
    implements Repository<Entity>, Edit<Map<String, dynamic>, Entity> {
  final Map<String, dynamic> Function(Entity, RepositoryOperation) toJson;
  final Entity Function(Map<String, dynamic>, RepositoryOperation) fromJson;
  final String Function(RepositoryOperation, Entity)
      operationUrl; // Entity might be null for some operations
  final http.Client client;
  final JsonCodec jsonCodec;

  static const void unit = null;

  String resourceURLForEntity(Entity entity, RepositoryOperation operation,
      {String id}) {
    final url = operationUrl(operation, entity);
    return id != null ? '$url/$id' : url;
  }

  HttpRepository({
    @required this.operationUrl,
    JsonCodec jsonCodec,
    @required this.client,
    @required this.toJson,
    @required this.fromJson,
  }) : this.jsonCodec = jsonCodec ?? JsonCodec();

  @override
  Future<Either<Failure, Entity>> add(Entity entity) {
    final task = Task(() async {
      final url = resourceURLForEntity(entity, RepositoryOperation.add);
      final jsonMap = toJson(entity, RepositoryOperation.add);
      jsonMap.removeWhere((key, value) => value == null);
      final jsonString = jsonCodec.encode(jsonMap);
      final response = await client.post(
        '$url',
        body: jsonString,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).validate();
      final createdJsonMap =
          jsonCodec.decode(response.body) as Map<String, dynamic>;
      final createdObject = fromJson(createdJsonMap, RepositoryOperation.add);
      return createdObject;
    }).attempt().map(
        (either) => either.leftMap((errorObj) => handleException(errorObj)));
    return task.run();
  }

  @override
  Future<Either<Failure, void>> delete(Entity entity) {
    final url = resourceURLForEntity(entity, RepositoryOperation.delete);
    final task = Task(() async {
      final response = await client.delete(url, headers: {'Accept': '*/*'});
      return response;
    }).attempt().map((either) => either
        .leftMap((errorObj) => RepositoryFailure.server('$errorObj'))
        .map((_) => unit));
    return task.run();
  }

  @override
  Future<Either<Failure, List<Entity>>> getAll() {
    final task = Task(() async {
      final url = resourceURLForEntity(null, RepositoryOperation.getAll);
      final response = await client.get(url);
      final bodyString = response.body;
      final json = jsonCodec.decode(bodyString);
      if (json is List<dynamic>) {
        final objects = json
            .map((jsonMap) => fromJson(
                jsonMap as Map<String, dynamic>, RepositoryOperation.getAll))
            .toList();
        return objects;
      } else if (json is Map<String, dynamic>) {
        final jsonList = json.values.whereType<List<dynamic>>().first;
        final objects = jsonList
            .map((jsonMap) => fromJson(
                jsonMap as Map<String, dynamic>, RepositoryOperation.getAll))
            .toList();
        return objects;
      }
    }).attempt().map((either) => either.leftMap(
          (errorObj) => handleException(errorObj),
        ));

    return task.run();
  }

  @override
  Future<Either<Failure, Entity>> getById(UniqueId id) {
    final task = Task(() async {
      final url =
          resourceURLForEntity(null, RepositoryOperation.getById, id: id.value);
      final response = await client.get('$url').validate();
      final bodyString = response.body;
      final jsonMap = jsonCodec.decode(bodyString) as Map<String, dynamic>;
      final object = fromJson(jsonMap, RepositoryOperation.getById);
      return object;
    })
        .attempt()
        .map((either) => either.leftMap((error) => handleException(error)));

    return task.run();
  }

  @override
  Future<Either<Failure, void>> update(Entity entity) async {
    final task = Task(() {
      final jsonMap = toJson(entity, RepositoryOperation.update);
      final jsonString = jsonCodec.encode(jsonMap);
      final url = resourceURLForEntity(entity, RepositoryOperation.update);
      return client.put(
        url,
        body: jsonString,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).validate();
    }).attempt().map(
        (either) => either.leftMap((e) => handleException(e)).map((_) => unit));
    return task.run();
  }

  @override
  Future<Either<Failure, Entity>> edit(
      UniqueId id, Map<String, dynamic> operation) {
    final task = Task(() async {
      final patch = operation;
      patch.removeWhere((key, value) => value == null);

      final url =
          resourceURLForEntity(null, RepositoryOperation.edit, id: id.value);
      final jsonString = jsonCodec.encode(patch);
      final response = await client.patch(
        url,
        body: jsonString,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).validate();
      final responseMap =
          jsonCodec.decode(response.body) as Map<String, dynamic>;
      final object = fromJson(responseMap, RepositoryOperation.edit);

      return object;
    }).attempt().map(
          (either) => either.leftMap((error) => handleException(error)),
        );

    return task.run();
  }

  Failure handleException(Exception error) {
    if (error is HttpException) {
      return HttpFailure.fromException(error);
    }
    return RepositoryFailure.server('$error');
  }
}

extension ValidateHttpResponse on Future<http.Response> {
  Future<http.Response> ensure(
      {bool Function(http.Response) satisfies,
      Exception Function(http.Response) otherwise}) {
    return then((response) {
      final passesCheck = satisfies(response);
      if (!passesCheck) {
        throw otherwise(response);
      }
      return response;
    });
  }

  Future<http.Response> validate() {
    return ensure(
        satisfies: (response) => response.statusCode < 400,
        otherwise: (response) => HttpException(
            statusCode: response.statusCode, body: response.body));
  }
}
