import './identifiable.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

enum SynchronizationStatus {
  synced,
  needsUpdate,
  needsDeletion,
  needsCreation,
}

class Synchronized<T extends WithIdAndPrimaryKey>
    with EquatableMixin
    implements WithId {
  final SynchronizationStatus status;
  final T entity;
  final String key;

  @override
  String get id {
    return key;
  }

  Synchronized({
    String key,
    @required this.status,
    @required this.entity,
  }) : this.key = key ?? entity?.stringedPrimaryKey ?? entity?.stringedId;

  factory Synchronized.newFrom(T entity) {
    return Synchronized(
        entity: entity, status: SynchronizationStatus.needsCreation);
  }

  factory Synchronized.markedForUpdate(T entity) {
    return Synchronized(
        entity: entity, status: SynchronizationStatus.needsCreation);
  }

  factory Synchronized.markedForDeletion(T entity) {
    return Synchronized(
        entity: entity, status: SynchronizationStatus.needsDeletion);
  }

  @override
  List<Object> get props =>
      [key, status, entity.stringedPrimaryKey, entity.stringedId];

  @override
  bool get stringify => true;
}
