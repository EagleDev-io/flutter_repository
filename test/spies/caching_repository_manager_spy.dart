import 'package:mockito/mockito.dart';
import 'package:repository/repository.dart';

class CachingRespositoryStateManagerSpy extends Mock implements CachingManager {
  final CachingManager manager;

  CachingRespositoryStateManagerSpy(this.manager) {
    configure();
  }

  void configure() {
    when(isValidCache).thenAnswer((_) => manager.isValidCache);
    when(shouldFetchFresh).thenAnswer((_) => manager.shouldFetchFresh);

    when(markRefreshDate(any)).thenAnswer((inv) {
      final argument = inv.positionalArguments.first;
      manager.markRefreshDate(argument);
      return;
    });

    when(process()).thenAnswer((_) {
      manager.process();
    });

    when(setHasInternetConnection(any)).thenAnswer((inv) {
      final argument = inv.positionalArguments.first;
      manager.setHasInternetConnection(argument);
      return;
    });
  }
}
