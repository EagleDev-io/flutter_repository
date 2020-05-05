import 'package:repository/repository.dart';

extension RepositoryTestingExtensions<T> on Repository<T> {
  Future<int> get entityCount async {
    final result = await getAll();
    return result.fold((_) => 0, (ls) => ls.length);
  }

  Future<T> get getFirst async {
    final result = await getAll();
    return result.fold((_) => null, (ls) => ls.first);
  }
}
