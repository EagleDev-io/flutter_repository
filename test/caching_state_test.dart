import 'package:flutter_test/flutter_test.dart';
import 'package:repository/repository.dart';

void main() {
  CacheState sut;
  CachingPolicy policy = CachingPolicy(outdatedAfter: Duration(minutes: 2));

  setUp(() {
    sut = CacheState(policy: policy);
  });

  group('window time frame not exceeded', () {
    test('returns true from shouldFetchFresh when state invalidated', () {
      sut.invalidate();
      expect(sut.shouldFetchFresh, true);
    });
  });

  test(
      'shouldFetchFresh returns false when calling invalidate and then setLastRefresh in order',
      () {
    sut.invalidate();
    sut.setLastRefresh(DateTime.now());
    expect(sut.shouldFetchFresh, false);
  });

  test('shouldFetchFresh returns true when no interaction is done on state',
      () {
    expect(sut.shouldFetchFresh, true);
  });

  group('window time frame exceeded', () {
    test(
        'resturns true from shouldFetchFresh when elapsed time exceeds policy threshold',
        () {
      sut.setLastRefresh(DateTime.now().subtract(Duration(minutes: 3)));
      expect(sut.shouldFetchFresh, true);
    });

    test(
        'calling setLastRefresh for first time date makes _isValidCache property true',
        () {
      sut.setLastRefresh(DateTime.now());
      expect(sut.isValidCache, true);
    });

    test(
        'resturns false from shouldFetchFresh when elapsed time does not exceed policy threshold',
        () {
      //arrange
      sut.setLastRefresh(DateTime.now().subtract(Duration(days: 1)));
      sut.setLastRefresh(DateTime.now().subtract(Duration(minutes: 1)));
      //assert
      expect(sut.shouldFetchFresh, false);
    });
    test(
        'returns true from shouldFetchFresh when state invalidated and setLastRefresh date called',
        () {});
  });
}
