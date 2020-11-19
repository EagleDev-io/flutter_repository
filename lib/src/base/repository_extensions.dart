import 'package:repository/repository.dart';
import 'package:meta/meta.dart';

import '../../repository.dart';

extension GetByIdConvertToCaching<T> on GetById<T> {
  GetById<T> cachingWith({
    @required Repository<T> repository,
    @required CachingPolicy policy,
    @required NetworkInfo networkChecker,
  }) {
    return CachingRepository(
        cache: repository,
        source: this,
        policy: policy,
        networkChecker: networkChecker);
  }
}

extension GetAllConvertToCaching<T> on GetAll<T> {
  GetAll<T> cachingWith({
    @required Repository<T> repository,
    @required CachingPolicy policy,
    @required NetworkInfo networkChecker,
  }) {
    return CachingRepository(
        cache: repository,
        source: this,
        policy: policy,
        networkChecker: networkChecker);
  }
}

extension ReadConvertToCaching<T> on ReadOnlyRepository<T> {
  ReadOnlyRepository<T> cachingWith({
    @required Repository<T> repository,
    @required CachingPolicy policy,
    @required NetworkInfo networkChecker,
  }) {
    return CachingRepository(
        cache: repository,
        source: this,
        policy: policy,
        networkChecker: networkChecker);
  }
}

extension RepositoryConvertToCaching<T> on Repository<T> {
  Repository<T> cachingWith({
    @required Repository<T> repository,
    @required CachingPolicy policy,
    @required NetworkInfo networkChecker,
  }) {
    return CachingRepository(
        cache: repository,
        source: this,
        policy: policy,
        networkChecker: networkChecker);
  }
}

extension GetByIdDecorate<T> on GetById<T> {
  GetById<T> logging(void Function(RepositoryOperation) function) {
    return GetByIdFunction((id) async {
      function(RepositoryOperation.getById);
      return await this.getById(id);
    });
  }
}

extension GetAllDecorate<T> on GetAll<T> {
  GetAll<T> logging(void Function(RepositoryOperation) function) {
    return GetAllFunction(() async {
      function(RepositoryOperation.getAll);
      return await this.getAll();
    });
  }
}
