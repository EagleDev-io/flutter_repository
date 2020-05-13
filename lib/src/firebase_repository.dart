import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:repository/src/repository_operation.dart';
import 'dart:async';

import '../repository.dart';

class FirebaseRepositoryConfiguration {
  final String collectionName;
  final dynamic orderedBy;
  final bool orderedAscending;

  FirebaseRepositoryConfiguration({
    @required this.collectionName,
    this.orderedBy,
    this.orderedAscending,
  });
}

class FirebaseRepository<Entity extends WithId>
    implements ReadOnlyRepository<Entity>, WriteOnlyRepository<Entity> {
  final FirebaseRepositoryConfiguration configuration;
  final Firestore firestore;
  final Map<String, dynamic> Function(Entity, RepositoryOperation) toJson;
  final FutureOr<Entity> Function(DocumentReference, RepositoryOperation)
      fromFirestoreDocument;

  FirebaseRepository({
    @required this.configuration,
    @required this.firestore,
    @required this.toJson,
    @required this.fromFirestoreDocument,
  });

  CollectionReference get _collection {
    return firestore.collection(configuration.collectionName);
  }

  @override
  Future<Either<RepositoryBaseFailure, List<Entity>>> getAll() async {
    Future<QuerySnapshot> snapshots;
    if (configuration.orderedBy != null) {
      snapshots = _collection
          .orderBy(
            configuration.orderedBy,
            descending: !configuration.orderedAscending,
          )
          .getDocuments();
    } else {
      snapshots = _collection.getDocuments();
    }

    final entities = await snapshots.then((snapshot) {
      return snapshot.documents
          .map((e) async =>
              fromFirestoreDocument(e.reference, RepositoryOperation.getAll))
          .toList();
    });

    final result = await Future.wait(entities);

    return Right(result);
  }

  @override
  Future<Either<RepositoryBaseFailure, Entity>> getById(UniqueId id) async {
    final document = await firestore
        .collection(configuration.collectionName)
        .document(id.value)
        .get();
    final entity =
        fromFirestoreDocument(document.reference, RepositoryOperation.getById);

    if (entity == null) {
      return Left(RepositoryFailure.server('Item with ${id.value} not found'));
    }

    return Right(entity);
  }

  @override
  Future<Either<RepositoryBaseFailure, Entity>> add(Entity entity) async {
    final jsonMap = toJson(entity, RepositoryOperation.add);
    final documentReference =
        await firestore.collection(configuration.collectionName).add(jsonMap);

    final document = await documentReference.get();
    // final document = await documentReference.snapshots().first;
    final updatedEntity =
        fromFirestoreDocument(document.reference, RepositoryOperation.add);
    return Right(updatedEntity);
  }

  @override
  Future<Either<RepositoryBaseFailure, void>> delete(Entity entity) async {
    await firestore
        .collection(configuration.collectionName)
        .document(entity.id)
        .delete();
    return Right(null);
  }

  @override
  Future<Either<RepositoryBaseFailure, void>> update(Entity entity) async {
    await firestore
        .collection(configuration.collectionName)
        .document(entity.id)
        .updateData(toJson(entity, RepositoryOperation.update));
    return Right(null);
  }
}
