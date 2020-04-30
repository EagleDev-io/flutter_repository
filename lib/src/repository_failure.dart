import 'package:equatable/equatable.dart';

abstract class Failure {}

enum RepositoryFailureOrigin { local, remote, connectivity }

class RepositoryFailure extends Equatable implements Failure {
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
