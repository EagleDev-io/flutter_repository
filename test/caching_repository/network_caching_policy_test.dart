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
}
