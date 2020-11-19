import 'package:dartz/dartz.dart';
import 'package:repository/repository.dart';
import 'package:meta/meta.dart';

import '../../repository.dart';

extension GetByIdConvertToCaching<T> on GetById<T> {
  GetById<T> cachingWith({
    @required Repository<T> repository,
    @required CachingPolicy policy,
    @required NetworkInfo networkChecker,
  }) {
    return CachingGetById(
        cache: repository,
        source: this,
        policy: policy,
        networkChecker: networkChecker);
  }
}

extension GetAllConvertToCaching<T extends WithId> on GetAll<T> {
  GetAll<T> cachingWith({
    @required Repository<T> repository,
    @required CachingPolicy policy,
    @required NetworkInfo networkChecker,
  }) {
    return CachingGetAll<T>(
        cache: repository,
        source: this,
        policy: policy,
        networkChecker: networkChecker);
  }
}

extension ReadConvertToCaching<T extends WithId> on ReadOnlyRepository<T> {
  ReadOnlyRepository<T> cachingWith({
    @required Repository<T> repository,
    @required CachingPolicy policy,
    @required NetworkInfo networkChecker,
  }) {
    return CachingRepository<T>(
        cache: repository,
        source: this,
        policy: policy,
        networkChecker: networkChecker);
  }
}

extension RepositoryConvertToCaching<T extends WithId> on Repository<T> {
  Repository<T> cachingWith({
    @required Repository<T> repository,
    @required CachingPolicy policy,
    @required NetworkInfo networkChecker,
  }) {
    return CachingRepository<T>(
        cache: repository,
        source: this,
        policy: policy,
        networkChecker: networkChecker);
  }
}

extension GetByIdDecorate<T> on GetById<T> {
  GetById<T> logging(void Function(Either<RepositoryBaseFailure, T>) function) {
    return GetByIdFunction((id) async {
      final result = await this.getById(id);
      function(result);
      return result;
    });
  }
}

extension GetAllDecorate<T> on GetAll<T> {
  GetAll<T> logging(void Function(Either<RepositoryBaseFailure,List<T>>) function) {
    return GetAllFunction(() async {
      final result = await this.getAll();
      function(result);
      return result;
    });
  }
}

// extension RepositoryDecorate<T> on Repository<T> {
//   Repository<T> logging() {
//     final prefix = ">>> Repository";
//     this.logGetById((result) => print('$prefix getById $result'));

//   }

// }
