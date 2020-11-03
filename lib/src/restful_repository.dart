import 'dart:convert' show JsonCodec;

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'http_repository/http_repository.dart';

import './base/repository_operation.dart';
import './base/identifiable.dart';

/// Implements CRUD for a well defined restful resource.
///
/// Note: an HttpFailure is returned if a response si outside the 200 range.
/// Resource nesting is not supported. To do this combine on or more RestfulRepository
/// instances.
class RestfulRepository<Entity extends WithId> extends HttpRepository<Entity> {
  final String resourceUrl;

  RestfulRepository({
    @required http.Client client,
    @required this.resourceUrl,
    JsonCodec jsonCodec,
    @required Map<String, dynamic> Function(Entity, RepositoryOperation) toJson,
    @required
        Entity Function(Map<String, dynamic>, RepositoryOperation) fromJson,
  }) : super(
            client: client,
            operationUrl: (operation, entity, id) {
              final putsIdPathSegment = [
                RepositoryOperation.getById,
                RepositoryOperation.edit
              ].contains(operation);
              return putsIdPathSegment ? '$resourceUrl/$id' : resourceUrl;
            },
            toJson: toJson,
            jsonCodec: jsonCodec,
            fromJson: fromJson);
}
