import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';

import '../repository.dart';
import 'offline_first/synchronized.dart';

class HiveJsonTypeAdapter<T> extends TypeAdapter<T> {
  final int typeIdentifier;
  final Function1<T, Map<String, dynamic>> toJson;
  final Function1<Map<String, dynamic>, T> fromJson;

  HiveJsonTypeAdapter({
    @required this.toJson,
    @required this.fromJson,
    @required this.typeIdentifier,
  });

  @override
  T read(BinaryReader reader) {
    final jsonString = reader.readString();
    final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
    final object = fromJson(jsonMap);
    return object;
  }

  @override
  int get typeId => typeIdentifier;

  @override
  void write(BinaryWriter writer, T obj) {
    final jsonMap = toJson(obj);
    final jsonString = json.encode(jsonMap);
    writer.writeString(jsonString);
  }
}

class HiveSynchronizedTypeAdapter<T extends WithIdAndPrimaryKey>
    extends TypeAdapter<Synchronized<T>> {
  final int typeIdentifier;
  final Function1<T, Map<String, dynamic>> toJson;
  final Function1<Map<String, dynamic>, T> fromJson;

  HiveSynchronizedTypeAdapter({
    @required this.typeIdentifier,
    @required this.toJson,
    @required this.fromJson,
  });

  @override
  Synchronized<T> read(BinaryReader reader) {
    final jsonString = reader.readString();
    final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
    final entity = fromJson(jsonMap['entity'] as Map<String, dynamic>);
    final statusString = jsonMap['status'] as String;
    final keyString = jsonMap['key'] as String;
    List<SynchronizationStatus> status = SynchronizationStatus.values
        .where((e) => e.toString() == statusString)
        .toList();

    final value = Synchronized(
      key: keyString,
      entity: entity,
      status: status.isEmpty ? null : status.first,
    );

    return value;
  }

  @override
  int get typeId => typeIdentifier;

  @override
  void write(BinaryWriter writer, Synchronized<T> obj) {
    final entityMap = toJson(obj.entity);
    final Map<String, dynamic> jsonMap = {
      'key': obj.id,
      'entity': entityMap,
      'status': obj.status.toString(),
    };

    final jsonString = json.encode(jsonMap);
    writer.writeString(jsonString);
  }
}
