import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class LocalStorageFailure extends Failure {
  const LocalStorageFailure(super.message);
}
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}
class WallpaperUserCaseFailure extends Failure{
  const WallpaperUserCaseFailure(super.message);
}