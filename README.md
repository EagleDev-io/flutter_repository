# Repository

![Run unit tests](https://github.com/EagleDev-io/flutter_repository/workflows/Run%20unit%20tests/badge.svg)
[![codecov](https://codecov.io/gh/EagleDev-io/flutter_repository/branch/master/graph/badge.svg)](https://codecov.io/gh/EagleDev-io/flutter_repository)

A data fetching and persistence abstraction.

A repository is a generic abstract class that expresses CRUD operations.
This is already a common abstraction that allows for instance swapping a networking repository for
a local database repository.

Very often you will need to coordinate between two repositories for instance caching networked
results or having offline support.

This project offers classes for coordinating between 2 repositories (user provided or ones that
come out of the box) like an `OfflineFirstRepository`, which can be thought as
(Higher order repositories). As well as concrete implementations like a `RestfulRepository` or an
`InMemoryRepository`.

Repository facilitates different data fetching strategies by providing generic class that can coordinate other repositories

## Example

**Add caching**

In this case we will have a source repository which will fetch todo items from a remote API
using an HttpRepository.

We would also like to cache results to avoid calling repeating the same network calls, so lets use an InMemoryRepository
for this (although a persisting respository would also work).

```dart
final remoteRespository = HttpRepository<TodoItem>(..); // Source repository
final inMemoryRespository = HttpRepository<TodoItem>(..); // Repository used to cache data
final networkChecker = NetworkInfo(); //Some way of checking internet access
final cachePolicy = CachingPolicy(outdatedAfter: Duration(minutes: 20)); //Determine how often cache is invalidated


final cachingRepository = CachingRepository<TodoItem>(
  policy: cachePolicy,
  cache: inMemoryRespository,
  source: remoteRespository,
  networkChecker: networkChecker,
);

final result = cachingRepository.getAll(); // Will fetch and write to cache

```

> Note: Even though a caching policy is supplied we can style do manual pull
> to refresh to update items.

## Usage

**Define a Failure type**

Make sure you extend the Failure type defined in this package.

```dart
abstract MyAppFailures extends Failure { }
```

**Satisfy repository entity constraints**

Some concrete repositories will define a type constraint on their generic variable.
You will need to satisfy these constraints in your entity.

InMemoryRepository being backed by a Map (key-value storage) requires its underlying entity
to define some kind of id.

```dart
class InMemoryRepository<E extends WithId> implements Repository<E> { ... }
```

## Features

**Out of the box repositories**

- OfflineFirstRepository (plug in your custom repositories)
- RestfulRepository (DRY on boilerplate CRUD implementations)
- HiveRepository
- InMemoryRepository
- FirebaseRepository

## Custom repositories

There are a few rules that have to be guaranteed for avoiding undefined behavior.
As can be seen in the type signatures of each CRUD operation in the `Repository` spec,
return values are of type `Either<Failure, T>`. With this in mind:

- If a Right value is returned we expect it not to be null. So absence of an entity in the repository should be express as a failure.

TODO:

- [] Document examples
- [] Add charts showing data flow and synchronization
- [] HttpRepository work with http or Dio
- [] Make private and testable CachingState in CachingRepository
- [] CachingRepository add caching policy time base, network based strategies and no strategy
