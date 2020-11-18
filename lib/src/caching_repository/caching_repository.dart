import 'package:dartz/dartz.dart';
import '../base/repository_failure.dart';
import '../base/repository.dart';
import 'package:meta/meta.dart';

import '../base/identifiable.dart';
import '../network_info.dart';
import 'cache_manager.dart';
import 'caching_policy.dart';

class _CachingBase<T extends WithId> {
  final NetworkInfo networkChecker;
  final CachingPolicy policy;
  CachingManager manager = CachingManager();

  final Repository<T> cache;

  _CachingBase(this.networkChecker, this.policy, this.cache);

  Future<bool> get _isConnected async {
    final hasInternet = await networkChecker.isConnected;
    manager.setHasInternetConnection(hasInternet);
    return hasInternet;
  }

  Future<void> _upsertIntoCache(T entity) async {
    final cached = await cache.getById(UniqueId(entity.stringedId));
    if (cached.isLeft()) {
      await cache.add(entity);
    } else {
      await cache.update(entity);
    }
  }
}

class CachingGetAll<T extends WithId> extends _CachingBase<T>
    implements GetAll<T> {
  final NetworkInfo networkChecker;
  final CachingPolicy policy;
  CachingManager manager = CachingManager();
  final Repository<T> cache;
  final GetAll<T> source;

  CachingGetAll({
    @required this.policy,
    @required this.cache,
    @required this.source,
    @required this.networkChecker,
  }) : super(networkChecker, policy, cache) {
    manager.policy = NetworkStatusCachingPolicy().and(policy);
  }

  @override
  Future<Either<RepositoryBaseFailure, List<T>>> getAll() async {
    final hasInternet = await _isConnected;

    final shouldFetchFresh = manager.shouldFetchFresh;
    if (shouldFetchFresh) {
      final result = await source.getAll();
      await cache.clear();
      final entities = result.getOrElse(() => []);
      manager.markRefreshDate(DateTime.now());
      entities.forEach((element) async {
        await cache.add(element);
      });

      return result;
    } else {
      final result = await cache.getAll();
      return result;
    }
  }

  Future<Either<RepositoryBaseFailure, int>> synchronize() async {
    int syncCount = 0;

    final result = await source.getAll();
    if (result.isLeft()) return result.map((r) => r.length);

    final List<T> entities = result.fold((l) => [], (r) => r);
    await cache.clear();

    for (var element in entities) {
      final result = await cache.add(element);
      syncCount += result.isRight() ? 1 : 0;
    }

    return result.map((r) => syncCount);
  }
}

class CachingGetById<T extends WithId> extends _CachingBase<T>
    implements GetById<T> {
  final NetworkInfo networkChecker;
  final CachingPolicy policy;
  CachingManager manager = CachingManager();
  final Repository<T> cache;
  final GetById<T> source;

  CachingGetById({
    @required this.policy,
    @required this.cache,
    @required this.source,
    @required this.networkChecker,
  }) : super(networkChecker, policy, cache) {
    manager.policy = NetworkStatusCachingPolicy().and(policy);
  }

  @override
  Future<Either<RepositoryBaseFailure, T>> getById(UniqueId id) async {
    final hasInternetConnection = await _isConnected;

    final shouldRefresh = manager.shouldFetchFresh;
    if (shouldRefresh) {
      final result = await source.getById(id);
      final entity = result?.getOrElse(() => null);
      if (entity != null) {
        await _upsertIntoCache(entity);
      }
      return result;
    } else {
      final cached = await cache.getById(id);
      return cached;
    }
  }
}

class CachingDelete<T extends WithId> extends _CachingBase<T>
    implements Delete<T> {
  final NetworkInfo networkChecker;
  final CachingPolicy policy;
  CachingManager manager = CachingManager();
  final Repository<T> cache;
  final Delete<T> source;

  CachingDelete({
    @required this.policy,
    @required this.cache,
    @required this.source,
    @required this.networkChecker,
  }) : super(networkChecker, policy, cache) {
    manager.policy = NetworkStatusCachingPolicy().and(policy);
  }

  @override
  Future<Either<RepositoryBaseFailure, void>> delete(T entity) async {
    final hasInternet = await _isConnected;
    if (!hasInternet) return Left(RepositoryFailure.connectivity());

    final result = await source.delete(entity);
    await cache.delete(entity);
    return result;
  }
}

class CachingUpdate<T extends WithId> extends _CachingBase<T>
    implements Update<T> {
  final NetworkInfo networkChecker;
  final CachingPolicy policy;
  CachingManager manager = CachingManager();
  final Repository<T> cache;
  final Update<T> source;

  CachingUpdate({
    @required this.policy,
    @required this.cache,
    @required this.source,
    @required this.networkChecker,
  }) : super(networkChecker, policy, cache) {
    manager.policy = NetworkStatusCachingPolicy().and(policy);
  }

  @override
  Future<Either<RepositoryBaseFailure, void>> update(T entity) async {
    final hasInternet = await _isConnected;
    if (!hasInternet) return Left(RepositoryFailure.connectivity());
    final result = await source.update(entity);
    final cacheResult = await cache.update(entity);
    return result;
  }
}

class CachingAdd<T extends WithId> extends _CachingBase<T> implements Add<T> {
  final NetworkInfo networkChecker;
  final CachingPolicy policy;
  CachingManager manager = CachingManager();
  final Repository<T> cache;
  final Add<T> source;

  CachingAdd({
    @required this.policy,
    @required this.cache,
    @required this.source,
    @required this.networkChecker,
  }) : super(networkChecker, policy, cache) {
    manager.policy = NetworkStatusCachingPolicy().and(policy);
  }

  @override
  Future<Either<RepositoryBaseFailure, T>> add(T entity) async {
    final hasInternet = await _isConnected;
    if (!hasInternet) return Left(RepositoryFailure.connectivity());
    final result = await source.add(entity);
    final entityOrNull = result.getOrElse(() => null);

    if (entityOrNull != null) {
      await cache.add(entityOrNull);
    }
    return result;
  }
}

// Should be a private class but kept public for testing purposes
class CachingRepository<T extends WithId> extends Repository<T> {
  final NetworkInfo networkChecker;
  final CachingPolicy policy;
  CachingManager _manager = CachingManager();
  final Repository<T> cache;
  final Repository<T> source;

  // MARK: Underlying repos
  CachingGetAll _getAll;
  CachingAdd _add;
  CachingUpdate _update;
  CachingDelete _delete;
  CachingGetById _getById;

  set manager(CachingManager newManager) {
    this._manager = newManager;
    _getAll.manager = _manager;
    _add.manager = _manager;
    _update.manager = _manager;
    _delete.manager = _manager;
    _getById.manager = _manager;
  }

  CachingRepository({
    @required this.policy,
    @required this.cache,
    @required this.source,
    @required this.networkChecker,
  }) {
    _manager.policy = NetworkStatusCachingPolicy().and(policy);
    _getAll = CachingGetAll<T>(
        cache: cache,
        policy: policy,
        source: source,
        networkChecker: networkChecker);
    _getById = CachingGetById<T>(
        cache: cache,
        policy: policy,
        source: source,
        networkChecker: networkChecker);
    _delete = CachingDelete<T>(
        cache: cache,
        policy: policy,
        source: source,
        networkChecker: networkChecker);
    _update = CachingUpdate<T>(
        cache: cache,
        policy: policy,
        source: source,
        networkChecker: networkChecker);
    _add = CachingAdd<T>(
        cache: cache,
        policy: policy,
        source: source,
        networkChecker: networkChecker);
    _getAll.manager = _manager;
    _add.manager = _manager;
    _update.manager = _manager;
    _delete.manager = _manager;
    _getById.manager = _manager;
  }

  @override
  Future<Either<RepositoryBaseFailure, T>> add(T entity) => _add.add(entity);

  @override
  Future<Either<RepositoryBaseFailure, void>> delete(T entity) =>
      _delete.delete(entity);

  @override
  Future<Either<RepositoryBaseFailure, List<T>>> getAll() => _getAll.getAll();

  @override
  Future<Either<RepositoryBaseFailure, T>> getById(UniqueId id) =>
      _getById.getById(id);

  @override
  Future<Either<RepositoryBaseFailure, void>> update(T entity) =>
      _update.update(entity);

  /// Marks cache outdated so, next call to getAll will be on source repository.
  void invalidateCache() {
    _manager.invalidate();
  }

  /// Clears cache and calls source repository to get fresh resources.
  /// Bypasses caching policy
  Future<Either<RepositoryBaseFailure, int>> synchronize() =>
      _getAll.synchronize();
}
