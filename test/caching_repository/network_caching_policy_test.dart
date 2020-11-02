import 'package:flutter_test/flutter_test.dart';
import 'package:repository/repository.dart';

void main() {
  NetworkStatusCachingPolicy sut;
  CacheState mockState;

  setUp(() {
    sut = NetworkStatusCachingPolicy();
    mockState = CacheState();
  });

  test('Does not invalidate cache if no network connection', () {
    mockState.setHasInternetConnection(false);
    final result = sut.shouldInvalidateCache(mockState);
    assert(!result);
  });

  test('cache is not invalidated if time expired but no internet', () {
    final combinedPolicy = NetworkStatusCachingPolicy()
        .and(TimedCachingPolicy(outdatedAfter: Duration(minutes: 3)));

    final tDate = DateTime.now().subtract(Duration(days: 1));
    final tState = CacheState();
    tState.markRefreshDate(tDate);
    final result = combinedPolicy.shouldInvalidateCache(tState);
    assert(!result);
  });
}
