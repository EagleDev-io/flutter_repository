import 'package:equatable/equatable.dart';

class HttpException with EquatableMixin implements Exception {
  final int statusCode; // 400 < code
  final String body;

  HttpException({this.statusCode, this.body});

  @override
  List<Object> get props => [statusCode, body];
}
