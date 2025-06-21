part of 'register_bloc.dart';

enum RegisterStatus { initial, loading, success, failure }

class RegisterState extends Equatable {
  const RegisterState._({required this.status, this.error});

  const RegisterState.initial() : this._(status: RegisterStatus.initial);
  const RegisterState.loading() : this._(status: RegisterStatus.loading);
  const RegisterState.success() : this._(status: RegisterStatus.success);
  const RegisterState.failure(String message)
      : this._(status: RegisterStatus.failure, error: message);

  final RegisterStatus status;
  final String? error;

  @override
  List<Object?> get props => [status, error];
}
