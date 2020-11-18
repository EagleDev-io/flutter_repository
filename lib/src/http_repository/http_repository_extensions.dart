import 'dart:convert' show JsonCodec;

import 'package:http/http.dart' as http;

import '../base/repository_operation.dart';
import 'http_exception.dart';
import 'http_repository.dart';

extension HttpClientForHttpRepository on http.Client {
  HttpRepositoryProccesingFunction httpRepositoryProccesingFunction(
      [JsonCodec jsonCoder]) {
    final operationProcessingFunction = (RepositoryOperation operation,
        Map<String, dynamic> jsonMap, String url) async {
      final JsonCodec jsonCodec = jsonCoder ?? JsonCodec();
      final client = this;
      final jsonString = jsonMap != null ? jsonCodec.encode(jsonMap) : null;

      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      if (operation == RepositoryOperation.add) {
        final response = await client
            .post(
              url,
              body: jsonString,
              headers: headers,
            )
            .validate();
        final createdJsonMap =
            jsonCodec.decode(response.body) as Map<String, dynamic>;

        return createdJsonMap;
      } else if (operation == RepositoryOperation.getById) {
        final response = await client.get(url, headers: headers).validate();
        final responseMap =
            jsonCodec.decode(response.body) as Map<String, dynamic>;
        return responseMap;
      } else if (operation == RepositoryOperation.delete) {
        final response = await client.delete(url, headers: headers);
        return response;
      } else if (operation == RepositoryOperation.update) {
        final response = client
            .put(
              url,
              body: jsonString,
              headers: headers,
            )
            .validate();
        return response;
      } else if (operation == RepositoryOperation.getAll) {
        final response = await client.get(url);
        final json = jsonCodec.decode(response.body);
        if (json is Map<String, dynamic>) {
          final jsonList = json.values.whereType<List<dynamic>>().first;
          return jsonList;
        }
        return json;
      } else if (operation == RepositoryOperation.edit) {
        final response = await client
            .patch(
              url,
              body: jsonString,
              headers: headers,
            )
            .validate();
        final responseMap =
            jsonCodec.decode(response.body) as Map<String, dynamic>;
        return responseMap;
      }

      return null;
    };

    return operationProcessingFunction;
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
