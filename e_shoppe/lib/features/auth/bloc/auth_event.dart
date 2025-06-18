part of 'auth_bloc.dart';

sealed class AuthEvent {
  const AuthEvent();
}

class AppStarted extends AuthEvent {
  const AppStarted();
}

class LoggedIn extends AuthEvent {
  const LoggedIn(this.user);

  final User user;
}

class LoggedOut extends AuthEvent {
  const LoggedOut();
}
