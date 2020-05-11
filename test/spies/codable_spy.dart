import 'package:mockito/mockito.dart';
import 'package:repository/src/repository_operation.dart';

abstract class Encoder<T> {
  Map<String, dynamic> encode(T object, RepositoryOperation operation);
}

abstract class Decoder<T> {
  T decode(Map<String, dynamic> json, RepositoryOperation operation);
}

class EncoderSpy<T> extends Mock implements Encoder<T> {
  final Map<String, dynamic> Function(T, RepositoryOperation) encoder;

  EncoderSpy(this.encoder) {
    configure();
  }

  void configure() {
    when(this.encode(any, any)).thenAnswer((inv) => encoder(
        inv.positionalArguments.first as T,
        inv.positionalArguments[1] as RepositoryOperation));
  }

  Map<String, dynamic> call(T object, RepositoryOperation operation) {
    return encode(object, operation);
  }
}

class DecoderSpy<T> extends Mock implements Decoder<T> {
  final T Function(Map<String, dynamic>, RepositoryOperation) decoder;

  DecoderSpy(this.decoder) {
    configure();
  }

  void configure() {
    when(this.decode(any, any)).thenAnswer((inv) => decoder(
        inv.positionalArguments.first as Map<String, dynamic>,
        inv.positionalArguments[1] as RepositoryOperation));
  }

  T call(Map<String, dynamic> jsonMap, RepositoryOperation operation) {
    return decode(jsonMap, operation);
  }
}
