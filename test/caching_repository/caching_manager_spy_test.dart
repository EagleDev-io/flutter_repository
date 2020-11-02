import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:repository/repository.dart';

import '../spies/caching_repository_manager_spy.dart';

class MockCachingManager extends Mock implements CachingManager {}

void main() {
  final tCachingPolicy =
      TimedCachingPolicy(outdatedAfter: Duration(minutes: 3));
  MockCachingManager mockCachingManager;
  CachingRespositoryStateManagerSpy sut;

  setUp(() {
    mockCachingManager = MockCachingManager();
    sut = CachingRespositoryStateManagerSpy(mockCachingManager);
  });

  test('markRefreshDate does forward to real caching manager', () {
    final tDate = DateTime.now().subtract(Duration(milliseconds: 500));
    sut.markRefreshDate(tDate);
    verify(mockCachingManager.markRefreshDate(tDate));
  });

  test('setHasInternetConnection does forward to real caching manager', () {
    final tBool = false;
    sut.setHasInternetConnection(tBool);
    verify(mockCachingManager.setHasInternetConnection(tBool));
  });

  test('when shouldFetchFresh is forwarded to real manager', () {
    sut.shouldFetchFresh;
    verify(mockCachingManager.shouldFetchFresh);
  });

  test('ManagerSpy returns same value for shouldFetchFresh as real manager',
      () {
    final tBool = false;
    when(mockCachingManager.shouldFetchFresh).thenReturn(tBool);
    assert(sut.shouldFetchFresh == tBool);
  });
}
