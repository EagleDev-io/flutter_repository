import 'dart:convert';

import 'package:mockito/mockito.dart';

class JsonCodecSpy extends Mock implements JsonCodec {
  final jsonCodec = JsonCodec();

  JsonCodecSpy() {
    configure();
  }

  void configure() {
    when(decode(any))
        .thenAnswer((inv) => jsonCodec.decode(inv.positionalArguments.first));
    when(encode(any))
        .thenAnswer((inv) => jsonCodec.encode(inv.positionalArguments.first));
  }
}
