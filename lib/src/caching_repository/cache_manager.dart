import 'cache_state.dart';
import 'caching_policy.dart';
import 'package:meta/meta.dart';

/**
  CachingManager works in conjunction with CachingRepository to determine when 
  to read from either source repository or cache.

  It also manages the state of the system, for example network status, las cache update date, etc.


  shouldFetchFresh determines if read operations should be redirected to cache or source repository.

  Because the strategy to cache might vary for example be time based, network state based.
  CacheManager actually works with a CachingPolicy object to determine when to invalidate the cache.
*/

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
