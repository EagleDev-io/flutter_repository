import 'package:flutter_test/flutter_test.dart';
import 'package:repository/repository.dart';
import 'package:mockito/mockito.dart';

class MockCachingPolicy extends Mock implements CachingPolicy {}

void main() {
  CachingManager sut;
  MockCachingPolicy mockCachingPolicy;

  setUp(() {
    mockCachingPolicy = MockCachingPolicy();
    sut = CachingManager(policy: mockCachingPolicy);
  });

  group('window time frame not exceeded', () {
    test('should fetch fresh when state invalidated', () {
      sut.invalidateCache();
      expect(sut.shouldFetchFresh, true);
    });
  });

  test(
      'cache remains valid when invalidated and caching policy does not required update',
      () {
    when(mockCachingPolicy.shouldInvalidateCache(any)).thenReturn(false);
    sut.invalidateCache();
    sut.markRefreshDate(DateTime.now());
    expect(sut.shouldFetchFresh, true);
  });

  test('shouldFetchFresh returns true when no interaction is done on state',
      () {
    expect(sut.shouldFetchFresh, true);
  });
}
