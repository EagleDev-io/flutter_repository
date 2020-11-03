abstract class WithIdAndPrimaryKey<T, K>
    implements WithId<T>, WithPrimaryKey<K> {
  @override
  T get id;

  @override
  K get primaryKey;
}

abstract class WithId<T> {
  T get id;
}

abstract class WithPrimaryKey<T> {
  T get primaryKey;
}

extension IdExtensions on WithId<dynamic> {
  String get stringedId {
    if (id == null) return null;
    return '$id';
  }
}

extension PrimaryKeyExtensions on WithPrimaryKey<dynamic> {
  String get stringedPrimaryKey {
    if (primaryKey == null) return null;
    return '$primaryKey';
  }
}

extension IdAndPrimaryKeyExtensions on WithIdAndPrimaryKey {
  String get stringedId {
    if (id == null) return null;
    return '$id';
  }

  String get stringedPrimaryKey {
    if (primaryKey == null) return null;
    return '$primaryKey';
  }
}

class UniqueId {
  final String value;

  UniqueId(this.value);

  const UniqueId._(this.value);
}
