import 'package:meta/meta.dart';
import 'package:repository/src/caching_repository/cache_state.dart';

abstract class CachingPolicy {
  bool shouldInvalidateCache(CacheState state);

  static CachingPolicy combine(List<CachingPolicy> policies) {
    final combinedPolicy = policies
        .reduce((accum, policy) => _CombinedCachingPolicy(accum, policy));
    return combinedPolicy;
  }
}

class _CombinedCachingPolicy implements CachingPolicy {
  final CachingPolicy first;
  final CachingPolicy second;

  _CombinedCachingPolicy(this.first, this.second);

  @override
  bool shouldInvalidateCache(CacheState state) {
    final result = first.shouldInvalidateCache(state) ||
        second.shouldInvalidateCache(state);
    return result;
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
    if (duration == null) return true;
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
