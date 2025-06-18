import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../data/repositories/auth_repository.dart';
import 'auth_bloc.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc(
      {required AuthRepository authRepository, required AuthBloc authBloc})
      : _authRepository = authRepository,
        _authBloc = authBloc,
        super(const RegisterState.initial()) {
    on<RegisterSubmitted>(_onSubmitted);
  }

  final AuthRepository _authRepository;
  final AuthBloc _authBloc;

  Future<void> _onSubmitted(
      RegisterSubmitted event, Emitter<RegisterState> emit) async {
    emit(const RegisterState.loading());
    try {
      final user = await _authRepository.register(
        name: event.name,
        email: event.email,
        password: event.password,
      );
      _authBloc.add(LoggedIn(user));
      emit(const RegisterState.success());
    } catch (e) {
      emit(RegisterState.failure(e.toString()));
    }
  }
}
