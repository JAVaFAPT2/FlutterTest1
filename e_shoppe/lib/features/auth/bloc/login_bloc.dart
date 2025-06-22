import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:e_shoppe/data/repositories/auth_repository.dart';
import 'package:e_shoppe/features/auth/bloc/auth_bloc.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc(
      {required AuthRepository authRepository, required AuthBloc authBloc})
      : _authRepository = authRepository,
        _authBloc = authBloc,
        super(const LoginState.initial()) {
    on<LoginSubmitted>(_onSubmitted);
  }

  final AuthRepository _authRepository;
  final AuthBloc _authBloc;

  Future<void> _onSubmitted(
      LoginSubmitted event, Emitter<LoginState> emit) async {
    emit(const LoginState.loading());
    try {
      final user = await _authRepository.login(
          email: event.email, password: event.password);
      _authBloc.add(LoggedIn(user));
      emit(const LoginState.success());
    } catch (e) {
      emit(LoginState.failure(e.toString()));
    }
  }
}
