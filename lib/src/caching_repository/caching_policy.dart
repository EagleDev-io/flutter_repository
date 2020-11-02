import 'package:meta/meta.dart';
import 'package:repository/src/caching_repository/cache_state.dart';

abstract class CachingPolicy {
  bool shouldInvalidateCache(CacheState state);
}

extension CombinedPolicy on CachingPolicy {
  CachingPolicy and(CachingPolicy policy) {
    return _CombinedCachingPolicy.and(this, policy);
  }

  CachingPolicy or(CachingPolicy policy) {
    return _CombinedCachingPolicy.or(this, policy);
  }
}

class _CombinedCachingPolicy implements CachingPolicy {
  final CachingPolicy first;
  final CachingPolicy second;
  final bool Function(bool, bool) operation;

  _CombinedCachingPolicy(this.first, this.second, this.operation);

  factory _CombinedCachingPolicy.and(
    CachingPolicy first,
    CachingPolicy second,
  ) {
    return _CombinedCachingPolicy(
      first,
      second,
      (left, right) => left && right,
    );
  }

  factory _CombinedCachingPolicy.or(
    CachingPolicy first,
    CachingPolicy second,
  ) {
    return _CombinedCachingPolicy(
      first,
      second,
      (left, right) => left || right,
    );
  }

  @override
  bool shouldInvalidateCache(CacheState state) {
    final firstResult = first.shouldInvalidateCache(state);
    final secondResult = second.shouldInvalidateCache(state);
    return operation(firstResult, secondResult);
  }
}

class TimedCachingPolicy extends CachingPolicy {
  /// Time condition to determine if data is fresh
  final Duration outdatedAfter;

  /// Determines if data will be fetched on next repository interaction or immediatly
  TimedCachingPolicy({
    @required this.outdatedAfter,
  });

  @override
  bool shouldInvalidateCache(CacheState state) {
    if (state.mostRecentRefresh == null || state.previousRefresh == null)
      return true;

    final now = DateTime.now();
    final duration = now.difference(state.mostRecentRefresh).abs();
    final satisfiesTimeWindow = duration < outdatedAfter;

    return !satisfiesTimeWindow;
  }
}

class NetworkStatusCachingPolicy extends CachingPolicy {
  @override
  bool shouldInvalidateCache(CacheState state) {
    // Always read from cache if no internet connection
    if (!state.hasInternet) return false;
    return true;
  }
}
