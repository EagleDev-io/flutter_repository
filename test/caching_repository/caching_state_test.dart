import 'package:repository/repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  CacheState sut;

  setUp(() {
    sut = CacheState();
  });

  test('calling markRefreshDate leaves previousRefresh date null', () {
    sut.markRefreshDate(DateTime.now());
    expect(sut.previousRefresh, null);
  });
}
