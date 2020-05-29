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

  CacheState(this._policy);

  set lastRefresh(DateTime dateTime) => this.setLastRefresh(dateTime);

  void setLastRefresh(DateTime dateTime) {
    _lastRefreshed = dateTime;
  }

  bool get shouldFetchFresh {
    final duration = _lastRefreshed.difference(DateTime.now());
    final satisfiesTimeWindow = duration < _policy.outdatedAfter;
    _isValidCache = satisfiesTimeWindow;
  }
}

class CacheRepository<T extends WithId> extends Repository<T> {
  final NetworkInfo networkChecker;
  final CachingPolicy policy;
  CacheState state;
  final Repository<T> cache;
  final Repository<T> source;

  CacheRepository({
    @required this.policy,
    @required this.cache,
    @required this.source,
    @required this.networkChecker,
    this.state,
  }) {
    state ??= CacheState(policy);
  }

  @override
  Future<Either<RepositoryBaseFailure, T>> add(T entity) {
    throw UnimplementedError();
  }

  @override
  Future<Either<RepositoryBaseFailure, void>> delete(T entity) {
    throw UnimplementedError();
  }

  @override
  Future<Either<RepositoryBaseFailure, List<T>>> getAll() async {
    final shouldFetchFresh = state.shouldFetchFresh;
    if (shouldFetchFresh) {
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
  Future<Either<RepositoryBaseFailure, T>> getById(UniqueId entity) {
    throw UnimplementedError();
  }

  @override
  Future<Either<RepositoryBaseFailure, void>> update(T entity) {
    // TODO: implement update
    throw UnimplementedError();
  }

  /// Marks cache outdated so, next call to getAll will be on source repository.
  void invalidateCache() {}

  /// Clears cache and calls source repository to get fresh resources.
  /// Bypasses caching policy
  Future<Either<RepositoryFailure, bool>> synchronize() {}
}
