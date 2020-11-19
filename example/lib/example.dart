library example;

import 'package:repository/repository.dart';

import 'todo_item.dart';
import 'todo_item.dart';
import 'package:http/http.dart';

import 'package:data_connection_checker/data_connection_checker.dart';

class NetworkInfoImpl implements NetworkInfo {
  final DataConnectionChecker connectionChecker = DataConnectionChecker();
  @override
  Future<bool> get isConnected => this.connectionChecker.hasConnection;
}

final client = Client();

final ReadOnlyRepository<TodoItem> todoRepo = HttpRepository<TodoItem>(
  toJson: (task, op) => task.toJson(),
  operationUrl: (op, item, id) =>
      'https://jsonplaceholder.typicode.com/todos/${id ?? ''}',
  fromJson: (jsonMap, op) => TodoItem.fromJson(jsonMap),
  process: client.httpRepositoryProccesingFunction(),
).cachingWith(
  repository: InMemoryRepository.blank(),
  networkChecker: NetworkInfoImpl(),
  policy: TimedCachingPolicy(
    outdatedAfter: Duration(minutes: 3),
  ),
);

void main() async {
  final items = await todoRepo.getAll();
  print(items);
  final items2 = await todoRepo.getAll();
  print(items2);
}
