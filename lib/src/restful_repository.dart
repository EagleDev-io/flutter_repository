import 'dart:convert' show JsonCodec;

import 'package:repository/src/http_exception.dart';
import 'package:repository/src/http_repository.dart';
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
class RestfulRepository<Entity extends WithId> extends HttpRepository<Entity> {
  final String resourceUrl;
  // final Map<String, dynamic> Function(Entity, RepositoryOperation) toJson;
  // final Entity Function(Map<String, dynamic>, RepositoryOperation) fromJson;
  // final http.Client client;

  RestfulRepository({
    @required http.Client client,
    @required this.resourceUrl,
    JsonCodec jsonCodec,
    @required Map<String, dynamic> Function(Entity, RepositoryOperation) toJson,
    @required
        Entity Function(Map<String, dynamic>, RepositoryOperation) fromJson,
  }) : super(
            client: client,
            operationUrl: (operation, entity) {
              return resourceUrl;
            },
            toJson: toJson,
            jsonCodec: jsonCodec,
            fromJson: fromJson);
}
