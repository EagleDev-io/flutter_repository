import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' show Client, Response;
import 'package:mockito/mockito.dart';
import 'package:repository/repository.dart';

import './spies/codable_spy.dart';
import './spies/json_codec_spy.dart';
import 'todo_item.dart';

class MockHttpClient extends Mock implements Client {}

void main() {
  MockHttpClient mockHttpClient;
  JsonCodecSpy mockJsonCodec;
  RestfulRepository<TodoItem> sut;
  EncoderSpy<TodoItem> toJsonSpy;
  DecoderSpy<TodoItem> fromJsonSpy;

  final tTodoItem = TodoItem.newItem('Test task');
  final tTodoItemWithId = tTodoItem.copyWith(id: '1');

  setUp(() {
    mockJsonCodec = JsonCodecSpy();
    mockHttpClient = MockHttpClient();
    toJsonSpy = EncoderSpy((item, _) => item.toJson());
    fromJsonSpy = DecoderSpy((jsonMap, _) => TodoItem.fromJson(jsonMap));

    sut = RestfulRepository(
      client: mockHttpClient,
      jsonCodec: mockJsonCodec,
      resourceUrl: '',
      toJson: toJsonSpy,
      fromJson: fromJsonSpy,
    );
  });

  tearDown(() {});

  test(
      'Test throws exception on response with status code outside the 200 range',
      () async {
    when(mockHttpClient.post(any,
            body: anyNamed('body'), headers: anyNamed('headers')))
        .thenAnswer((_) async => Response('test body', 400));

    final result = await sut.add(tTodoItem);
    final error = result.fold((err) => err, (_) => null);
    expect(error, isA<HttpFailure>());
  });

  test('''attepts to parse list of entities even if response is enveloped
  by inspecting first value which is a list.
  ''', () {});

  test('Returns non null entity when creating', () {});

  test('Strips off null properties when serializing for create', () async {
    when(mockHttpClient.post(any,
            body: anyNamed('body'), headers: anyNamed('headers')))
        .thenAnswer(
            (_) async => Response(json.encode(tTodoItemWithId.toJson()), 201));

    final result = await sut.add(tTodoItem);
    final matcher =
        (Map<String, dynamic> map) => !map.values.any((v) => v == null);

    verify(mockJsonCodec.encode(argThat(predicate(matcher))));
  });

  test('Strips off null properties when serializing for edit', () async {
    when(mockHttpClient.patch(any,
            body: anyNamed('body'), headers: anyNamed('headers')))
        .thenAnswer(
            (_) async => Response(json.encode(tTodoItemWithId.toJson()), 200));

    final result =
        await sut.edit(UniqueId('1'), TodoItemEdit(completed: false));

    final matcher =
        (Map<String, dynamic> map) => !map.values.any((v) => v == null);

    verify(mockJsonCodec.encode(argThat(predicate(matcher))));
  });

  test('Sends correct content-type header when performing a write operation',
      () async {
    when(mockHttpClient.post(any,
            body: anyNamed('body'), headers: anyNamed('headers')))
        .thenAnswer(
            (_) async => Response(json.encode(tTodoItemWithId.toJson()), 201));

    final result = await sut.add(tTodoItem);

    bool hasCorrectHeaders(Map<String, String> headers) {
      return headers['Content-Type'] == 'application/json';
    }

    verify(mockHttpClient.post(
      any,
      body: anyNamed('body'),
      headers: argThat(predicate(hasCorrectHeaders), named: 'headers'),
    ));
  });

  test('SocketException is not handled as an HttpException', () {});

  /// This enables custom envelopes support
  test('Can strip off envelope from response.', () async {
    Map<String, dynamic> envelope(Map<String, dynamic> jsonMap) =>
        {'data': jsonMap};

    when(mockHttpClient.post(any,
            body: anyNamed('body'), headers: anyNamed('headers')))
        .thenAnswer((_) async {
      return Response(json.encode(envelope(tTodoItemWithId.toJson())), 201);
    });

    when(fromJsonSpy.decode(any, any)).thenAnswer((inv) {
      final jsonMap = inv.positionalArguments.first as Map<String, dynamic>;
      final payloadMap = jsonMap['data'];
      return TodoItem.fromJson(payloadMap);
    });

    final result = await sut.add(tTodoItem);
    assert(result.isRight());
  });
}
