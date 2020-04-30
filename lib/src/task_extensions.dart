import 'package:dartz/dartz.dart';
import './repository_failure.dart';

extension TaskEitherAlternative<T> on Task<Either<Failure, T>> {
  Task<Either<Failure, T>> orDefault(Task<Either<Failure, T>> task) {
    return bind((eitherT) => Task(() {
          return eitherT.fold(
            (failure) => task.run(),
            (valueT) => Future.value(Right(valueT)),
          );
        }));
  }
}

extension TaskEitherMonad<T> on Task<Either<Failure, T>> {
  Task<Either<Failure, A>> bindEither<A>(
      Function1<T, Task<Either<Failure, A>>> f) {
    return bind((eitherT) => Task(() {
          return eitherT.fold(
            (failure) => Future.value(Left(failure)),
            (valueT) => f(valueT).run(),
          );
        }));
  }

  Task<Either<Failure, A>> mapEither<A>(Function1<T, A> f) {
    return map((eitherT) => eitherT.map(f));
  }
}

extension FutureEitherAlternative<T> on Future<Either<Failure, T>> {
  Future<Either<Failure, T>> orDefault(Future<Either<Failure, T>> task) {
    return then((eitherT) {
      return eitherT.fold(
        (failure) => task,
        (valueT) => Future.value(Right(valueT)),
      );
    });
  }
}

extension EitherDefault<T> on Either<Failure, T> {
  T withDefault(T value) {
    return fold((failure) => value, (success) => success);
  }

  Failure failure() {
    return fold((failure) => failure, (success) => null);
  }
}
