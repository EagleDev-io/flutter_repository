import 'package:dartz/dartz.dart';
import './repository_failure.dart';

extension TaskEitherAlternative<T> on Task<Either<RepositoryBaseFailure, T>> {
  Task<Either<RepositoryBaseFailure, T>> orDefault(
      Task<Either<RepositoryBaseFailure, T>> task) {
    return bind((eitherT) => Task(() {
          return eitherT.fold(
            (failure) => task.run(),
            (valueT) => Future.value(Right(valueT)),
          );
        }));
  }
}

extension TaskEitherMonad<T> on Task<Either<RepositoryBaseFailure, T>> {
  Task<Either<RepositoryBaseFailure, A>> bindEither<A>(
      Function1<T, Task<Either<RepositoryBaseFailure, A>>> f) {
    return bind((eitherT) => Task(() {
          return eitherT.fold(
            (failure) => Future.value(Left(failure)),
            (valueT) => f(valueT).run(),
          );
        }));
  }

  Task<Either<RepositoryBaseFailure, A>> mapEither<A>(Function1<T, A> f) {
    return map((eitherT) => eitherT.map(f));
  }
}

extension FutureEitherAlternative<T>
    on Future<Either<RepositoryBaseFailure, T>> {
  Future<Either<RepositoryBaseFailure, T>> orDefault(
      Future<Either<RepositoryBaseFailure, T>> task) {
    return then((eitherT) {
      return eitherT.fold(
        (failure) => task,
        (valueT) => Future.value(Right(valueT)),
      );
    });
  }
}

extension EitherDefault<T> on Either<RepositoryBaseFailure, T> {
  T withDefault(T value) {
    return fold((failure) => value, (success) => success);
  }

  RepositoryBaseFailure failure() {
    return fold((failure) => failure, (success) => null);
  }
}
