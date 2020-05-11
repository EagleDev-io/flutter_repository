import '../repository_failure.dart';

class SynchronizationBatchResult {
  final int proccessed;

  int get completed {
    return proccessed - remaining;
  }

  int get remaining {
    return failures.length;
  }

  final List<RepositoryBaseFailure> failures;

  @override
  String toString() {
    final p = proccessed;
    final r = remaining;
    return '''SynchronizationBatchResult: 
    Processed: $p,
    Remaining: $r,
    Falilures: $failures
    ''';
  }

  SynchronizationBatchResult({
    this.failures,
    this.proccessed,
  });
}
