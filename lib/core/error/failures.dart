import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final StackTrace? stackTrace;

  const Failure(this.message, {this.stackTrace});

  @override
  List<Object?> get props => [message, stackTrace];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.stackTrace});
}

class DatasourceFailure extends Failure {
  const DatasourceFailure(super.message, {super.stackTrace});
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, {super.stackTrace});
}

class DuplicateEntryFailure extends Failure {
  const DuplicateEntryFailure(super.message, {super.stackTrace});
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.stackTrace});
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message, {super.stackTrace});
}
