import 'package:mockito/mockito.dart';
import 'package:meta/meta.dart';
import 'package:repository/src/identifiable.dart';
import 'package:repository/src/repository.dart';

class RepositorySpy<Entity> extends Mock implements Repository<Entity> {
  Repository<Entity> realRepository;
  void Function(Repository<Entity>) clearAction;

  RepositorySpy({@required this.realRepository, this.clearAction}) {
    configure();
  }

  /// Call this on tearDown configuration of tests
  void tearDown() {
    if (clearAction != null) {
      clearAction(realRepository);
    } else {
      realRepository.clear();
    }
  }

  void configure() {
    when(add(any)).thenAnswer((invocation) =>
        realRepository.add(invocation.positionalArguments.first as Entity));

    when(update(any)).thenAnswer((invocation) =>
        realRepository.update(invocation.positionalArguments.first as Entity));

    when(delete(any)).thenAnswer((invocation) =>
        realRepository.delete(invocation.positionalArguments.first as Entity));

    when(getAll()).thenAnswer((_) => realRepository.getAll());

    when(getById(any)).thenAnswer((invocation) => realRepository
        .getById(invocation.positionalArguments.first as UniqueId));
  }
}
