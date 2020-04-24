# Repository

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

## Usage

**Define a Failure type**

**Satisfy repository entity constraints**


## Features

- OfflineFirstRepository (plug in your custom repositories)
- RestfulRepository (DRY on boilerplate CRUD implementations)

## Custom repositories

There are a few rules that have to be guaranteed for avoiding undefined behavior.
As can be seen in the type signatures of each CRUD operation in the `Repository` spec,
return values are of type `Either<Failure, T>`.  With this in mind:

- If a Right value is returned we expect it not to be null. So absence of an entity in the repository should be express as a failure.

TODO:  finish docs here

