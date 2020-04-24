import 'dart:convert';

import 'repository.dart';
import 'identifiable.dart';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

class RestfulRepository<Entity extends WithId> implements Repository<Entity> {
  final String resourceUrl;
  final Function1<Entity, Map<String, dynamic>> toJson;
  final Function1<Map<String, dynamic>, Entity> fromJson;
  final http.Client client;

  static const void unit = null;

  String resourceURLForEntity(Entity entity) {
    final id = (entity as WithId).stringedId;
    return '$resourceUrl/$id';
  }

  RestfulRepository({
    @required this.client,
    @required this.resourceUrl,
    @required this.toJson,
    @required this.fromJson,
  });

  @override
  Future<Either<Failure, Entity>> add(Entity entity) {
    final task = Task(() async {
      final jsonMap = toJson(entity);
      jsonMap.removeWhere((key, value) => value == null);
      final jsonString = json.encode(jsonMap);
      final response = await client.post(
        '$resourceUrl',
        body: jsonString,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ); //.validate();
      final createdJsonMap = json.decode(response.body) as Map<String, dynamic>;
      final createdObject = fromJson(createdJsonMap);
      return createdObject;
    }).attempt().map((either) =>
        either.leftMap((errorObj) => RepositoryFailure.server('$errorObj')));
    return task.run();
  }

  @override
  Future<Either<Failure, void>> delete(Entity entity) {
    final url = resourceURLForEntity(entity);
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
      final response = await client.get(resourceUrl);
      final bodyString = response.body;
      final jsonList = jsonDecode(bodyString) as List<dynamic>;
      final objects = jsonList
          .map((jsonMap) => fromJson(jsonMap as Map<String, dynamic>))
          .toList();
      return objects;
    }).attempt().map((either) => either.leftMap(
          (errorObj) => RepositoryFailure.server('$errorObj'),
        ));

    return task.run();
  }

  @override
  Future<Either<Failure, Entity>> getById(UniqueId id) {
    final task = Task(() async {
      final response = await client.get('$resourceUrl/${id.value}').validate();
      final bodyString = response.body;
      final jsonMap = jsonDecode(bodyString) as Map<String, dynamic>;
      final object = fromJson(jsonMap);
      return object;
    }).attempt().map((either) => either.leftMap(
          (errorObj) => RepositoryFailure.server('$errorObj'),
        ));

    return task.run();
  }

  @override
  Future<Either<Failure, void>> update(Entity entity) async {
    final task = Task(() {
      final jsonMap = toJson(entity);
      final jsonString = json.encode(jsonMap);
      return client.put(
        resourceURLForEntity(entity),
        body: jsonString,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).validate();
    }).attempt().map((either) => either
        .leftMap((errorObj) => RepositoryFailure.server('$errorObj'))
        .map((_) => unit));
    return task.run();
  }

  @override
  Future<Either<Failure, Entity>> edit<E extends Entity>(
      UniqueId id, E operation) {
    final task = Task(() async {
      final patch = toJson(operation);

      patch.removeWhere((key, value) => value == null);

      final jsonString = json.encode(patch);
      final response = await client.patch(
        '$resourceUrl/${id.value}',
        body: jsonString,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).validate();
      final responseMap = json.decode(response.body) as Map<String, dynamic>;
      final object = fromJson(responseMap);

      return object;
    }).attempt().map((either) => either.leftMap(
          (errorObj) => RepositoryFailure.server('$errorObj'),
        ));

    return task.run();
  }
}

extension ValidateHttpResponse on Future<http.Response> {
  Future<http.Response> ensure(
      {bool Function(http.Response) satisfies, Exception otherwise}) {
    return then((response) {
      final passesCheck = satisfies(response);
      if (!passesCheck) {
        throw otherwise;
      }
      return response;
    });
  }

  Future<http.Response> validate() {
    return ensure(
        satisfies: (response) {
          final hasCorrectStatusCode =
              200 >= response.statusCode && response.statusCode < 300;
          final hasCorrectContentType = response.headers['content-type']
                  ?.startsWith('application/json') ??
              false;
          return hasCorrectStatusCode && hasCorrectContentType;
        },
        otherwise: Exception('Http response validation failure'));
  }
}
