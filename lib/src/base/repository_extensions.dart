import 'package:repository/repository.dart';

extension GetByIdConvertToCaching<T> on GetById<T> {
  GetById<T> cachingWith({
    Repository<T> cache,
    CachingPolicy policy,
    NetworkInfo networkChecker,
  }) {
    return CachingRepository(
        cache: cache,
        source: this,
        policy: policy,
        networkChecker: networkChecker);
  }
}

extension GetAllConvertToCaching<T> on GetAll<T> {
  GetAll<T> cachingWith({
    Repository<T> cache,
    CachingPolicy policy,
    NetworkInfo networkChecker,
  }) {
    return CachingRepository(
        cache: cache,
        source: this,
        policy: policy,
        networkChecker: networkChecker);
  }
}
