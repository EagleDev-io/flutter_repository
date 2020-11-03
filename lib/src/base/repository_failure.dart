import 'package:equatable/equatable.dart';
import '../http_repository/http_exception.dart';

abstract class RepositoryBaseFailure {}

enum RepositoryFailureOrigin { local, remote, connectivity }

class RepositoryFailure extends Equatable implements RepositoryBaseFailure {
  final RepositoryFailureOrigin origin;
  final String message;
  RepositoryFailure(this.origin, this.message);

  factory RepositoryFailure.server(String message) =>
      RepositoryFailure(RepositoryFailureOrigin.remote, message);

  factory RepositoryFailure.cache(String message) =>
      RepositoryFailure(RepositoryFailureOrigin.local, message);

  factory RepositoryFailure.connectivity() => RepositoryFailure(
      RepositoryFailureOrigin.connectivity, 'No internet connection');

  @override
  List<Object> get props => [origin, message];

  @override
  bool get stringify => true;
}

class HttpFailure extends Equatable implements RepositoryBaseFailure {
  final int statusCode; // 400 < code
  final String body;

  HttpFailure({this.statusCode, this.body});
  factory HttpFailure.fromException(HttpException exception) {
    return HttpFailure(statusCode: exception.statusCode, body: exception.body);
  }

  @override
  List<Object> get props => [statusCode, body];
}
