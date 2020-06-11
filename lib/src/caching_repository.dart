import 'package:dartz/dartz.dart';
import '../repository.dart';
import 'package:meta/meta.dart';

class CachingPolicy {
  /// Time condition to determine if data is fresh
  final Duration outdatedAfter;

  /// Determines if data will be fetched on next repository interaction or immediatly
  final bool eagerSynchronization;

  CachingPolicy({
    @required this.outdatedAfter,
    @required this.eagerSynchronization,
  });
}

class CacheState {
  DateTime _lastRefreshed; // Date of last refresh
  bool _isValidCache = false;
  final CachingPolicy _policy;

  CacheState({@required CachingPolicy policy}) : this._policy = policy;

  set lastRefresh(DateTime dateTime) => this.setLastRefresh(dateTime);

  bool get isValidCache => _isValidCache;

  void invalidate() {
    _isValidCache = false;
  }

  void setLastRefresh(DateTime dateTime) {
    _isValidCache =
        _lastRefreshed != null ? dateTime.isAfter(_lastRefreshed) : true;
    _lastRefreshed = dateTime;
  }

  bool get shouldFetchFresh {
    if (!_isValidCache) return !_isValidCache;

    final duration = _lastRefreshed?.difference(DateTime.now()).abs();
    if (duration == null) return true;
    final satisfiesTimeWindow = duration < _policy.outdatedAfter;

    final shouldRefresh = !satisfiesTimeWindow || !_isValidCache;

    return shouldRefresh;
  }
}

class CachingRepository<T extends WithId> extends Repository<T> {
  final NetworkInfo networkChecker;
  final CachingPolicy policy;
  CacheState state;
  final Repository<T> cache;
  final Repository<T> source;

  CachingRepository({
    @required this.policy,
    @required this.cache,
    @required this.source,
    @required this.networkChecker,
    this.state,
  }) {
    state ??= CacheState(policy: policy);
  }

  @override
  Future<Either<RepositoryBaseFailure, T>> add(T entity) async {
    final hasInternet = await networkChecker.isConnected;
    if (!hasInternet) return Left(RepositoryFailure.connectivity());
    final result = await source.add(entity);
    final entityOrNull = result.getOrElse(() => null);

    if (entityOrNull != null) {
      await cache.add(entityOrNull);
    }
    return result;
  }

  @override
  Future<Either<RepositoryBaseFailure, void>> delete(T entity) async {
    final hasInternet = await networkChecker.isConnected;
    if (!hasInternet) return Left(RepositoryFailure.connectivity());

    final result = await source.delete(entity);
    await cache.delete(entity);
    return result;
  }

  @override
  Future<Either<RepositoryBaseFailure, List<T>>> getAll() async {
    final hasInternet = await networkChecker.isConnected;

    final shouldFetchFresh = state.shouldFetchFresh;
    if (shouldFetchFresh && hasInternet) {
      final result = await source.getAll();
      await cache.clear();
      final entities = result.getOrElse(() => []);
      state.setLastRefresh(DateTime.now());
      entities.forEach((element) async {
        await cache.add(element);
      });

      return result;
    } else {
      final result = await cache.getAll();
      return result;
    }
  }

  @override
  Future<Either<RepositoryBaseFailure, T>> getById(UniqueId id) async {
    final hasInternetConnection = await networkChecker.isConnected;

    final shouldRefresh = state.shouldFetchFresh;
    if (shouldRefresh && hasInternetConnection) {
      final result = await source.getById(id);
      final entity = result.getOrElse(() => null);
      if (entity != null) {
        await _upsertIntoCache(entity);
      }
      return result;
    } else {
      final cached = await cache.getById(id);
      return cached;
    }
  }

  @override
  Future<Either<RepositoryBaseFailure, void>> update(T entity) async {
    final hasInternet = await networkChecker.isConnected;
    if (!hasInternet) return Left(RepositoryFailure.connectivity());
    final result = await source.update(entity);
    final cacheResult = await cache.update(entity);
    return result;
  }

  /// Marks cache outdated so, next call to getAll will be on source repository.
  void invalidateCache() {
    state.invalidate();
  }

  /// Clears cache and calls source repository to get fresh resources.
  /// Bypasses caching policy
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

  Future<void> _upsertIntoCache(T entity) async {
    final cached = await cache.getById(UniqueId(entity.stringedId));
    if (cached.isLeft()) {
      await cache.add(entity);
    } else {
      await cache.update(entity);
    }
  }
}
