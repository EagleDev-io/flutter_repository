import 'package:meta/meta.dart';
import 'package:repository/src/caching_repository/cache_state.dart';

abstract class CachingPolicy {
  bool shouldInvalidateCache(CacheState state);
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
    return false;
  }
}
