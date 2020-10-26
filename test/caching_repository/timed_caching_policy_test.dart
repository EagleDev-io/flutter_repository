import 'package:repository/repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TimedCachingPolicy sut;
  CacheState mockState;

  setUp(() {
    sut = TimedCachingPolicy(outdatedAfter: Duration(minutes: 3));
    mockState = CacheState();
  });

  test('invalidates cache when markRefreshDate is called for first time', () {
    mockState.markRefreshDate(DateTime.now());
    final result = sut.shouldInvalidateCache(mockState);
    expect(result, true);
  });

  test(
      'returns false from shouldFetchFresh when elapsed time does not exceed policy threshold',
      () {
    //arrange
    mockState.markRefreshDate(DateTime.now().subtract(Duration(days: 1)));
    mockState.markRefreshDate(DateTime.now().subtract(Duration(minutes: 1)));
    // act

    final result = sut.shouldInvalidateCache(mockState);
    //assert
    expect(result, false);
  });

  test(
      'returns true from shouldFetchFresh when elapsed time exceeds policy threshold',
      () {
    mockState.markRefreshDate(DateTime.now().subtract(Duration(days: 1)));
    final result = sut.shouldInvalidateCache(mockState);
    expect(result, true);
  });
}
