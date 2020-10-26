import 'cache_state.dart';
import 'caching_policy.dart';
import 'package:meta/meta.dart';

class CachingManager {
  CacheState state = CacheState();

  bool _isValidCache = false;
  CachingPolicy policy;

  CachingManager({@required this.policy});
  bool get shouldFetchFresh => !_isValidCache;
  bool get isValidCache => _isValidCache;

  /// Updates CacheState with new data and depending on CachingPolicy invalidates
  void process() {
    final shouldInvalidate = policy.shouldInvalidateCache(state);
    _isValidCache = shouldInvalidate;
  }

  void markRefreshDate(DateTime refreshDate) {
    state.markRefreshDate(refreshDate);
    process();
  }

  void setHasInternetConnection(bool connected) {
    state.setHasInternetConnection(connected);
    process();
  }

  void invalidate() {
    _isValidCache = false;
  }

  void invalidateCache() {
    _isValidCache = false;
  }
}
