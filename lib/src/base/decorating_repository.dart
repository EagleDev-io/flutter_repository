import 'package:dartz/dartz.dart';
import 'package:repository/repository.dart';

class GetByIdDecorator<T> implements GetById<T> {
  final GetById<T> repository;
  final void Function() function;

  GetByIdDecorator(this.repository, this.function);

  @override
  Future<Either<RepositoryBaseFailure, T>> getById(UniqueId id) {
    function();
    return repository.getById(id);
  }
}
