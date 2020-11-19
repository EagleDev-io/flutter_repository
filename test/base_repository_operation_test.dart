import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repository/repository.dart';

void main() {
  test('Can get operation value for operation class', () {
    final getById = GetByIdFunction<int>(
        (_) async => Left(RepositoryFailure.connectivity()));
    final getAll =
        GetAllFunction<int>(() async => Left(RepositoryFailure.connectivity()));
    final delete = DeleteFunction<int>(
        (_) async => Left(RepositoryFailure.connectivity()));
    final update = UpdateFunction<int>(
        (_) async => Left(RepositoryFailure.connectivity()));
    final add =
        AddFunction<int>((_) async => Left(RepositoryFailure.connectivity()));

    assert(getById.operation == RepositoryOperation.getById);
    assert(getAll.operation == RepositoryOperation.getAll);
    assert(add.operation == RepositoryOperation.add);
    assert(update.operation == RepositoryOperation.update);
    assert(delete.operation == RepositoryOperation.delete);
  });

}
