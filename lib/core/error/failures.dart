import 'package:equatable/equatable.dart';

class Failure extends Equatable implements Exception {
  const Failure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
