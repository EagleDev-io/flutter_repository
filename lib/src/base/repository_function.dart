import 'package:repository/src/base/repository_failure.dart';

import 'package:repository/src/base/identifiable.dart';

import 'package:dartz/dartz.dart';

import './repository.dart';

typedef GetByIdFunc<T> = Future<Either<RepositoryBaseFailure, T>> Function(
    UniqueId);

typedef GetAllFunc<T> = Future<Either<RepositoryBaseFailure, List<T>>>
    Function();

typedef UpdateFunc<T> = Future<Either<RepositoryBaseFailure, void>> Function(T);
typedef DeleteFunc<T> = Future<Either<RepositoryBaseFailure, void>> Function(T);

class GetByIdFunction<T> implements GetById<T> {
  final GetByIdFunc<T> function;

  GetByIdFunction(this.function);

  @override
  Future<Either<RepositoryBaseFailure, T>> getById(UniqueId id) => function(id);
}

class GetAllFunction<T> implements GetAll<T> {
  final GetAllFunc<T> function;

  GetAllFunction(this.function);

  @override
  Future<Either<RepositoryBaseFailure, List<T>>> getAll() => function();
}

class UpdateFunction<T> implements Update<T> {
  final UpdateFunc function;

  UpdateFunction(this.function);

  @override
  Future<Either<RepositoryBaseFailure, void>> update(T entity) =>
      function(entity);
}

class AddFunction<T> implements Add<T> {
  final UpdateFunc function;

  AddFunction(this.function);

  @override
  Future<Either<RepositoryBaseFailure, T>> add(T entity) => function(entity);
}

class DeleteFunction<T> implements Delete<T> {
  final DeleteFunc function;

  DeleteFunction(this.function);

  @override
  Future<Either<RepositoryBaseFailure, void>> delete(T entity) =>
      function(entity);
}
