import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show immutable;

const Map<String, AuthError> authErrorMaping = {
  'user-not-found': AuthErrorUserNotFound(),
  'week-password': AuthErrorWeekPassword(),
  'invalid-emali': AuthErrorInvalidEmail(),
  'operation-not-allowed': AuthErrorOperationNotAllowed(),
  'email-already-in-use': AuthErrorEmailAlreadyInUse(),
  'requires-recent-login': AuthErrorRequiresRecentLogin(),
  'no-current-user': AuthErrorNoCurrentUser(),
};

@immutable
abstract class AuthError {
  final String dialogTitle;
  final String dialogText;
  const AuthError({
    required this.dialogTitle,
    required this.dialogText,
  });

  factory AuthError.from(FirebaseAuthException exception) =>
      authErrorMaping[exception.code.toLowerCase().trim()] ??
      const AuthErrorNoCurrentUser();
}

@immutable
class AuthErrorUnknown extends AuthError {
  const AuthErrorUnknown()
      : super(
          dialogTitle: 'Authentication error',
          dialogText: 'Unknown authentication error',
        );
}

//auth/no-current-user
@immutable
class AuthErrorNoCurrentUser extends AuthError {
  const AuthErrorNoCurrentUser()
      : super(
          dialogTitle: 'No current user!',
          dialogText: 'No current user with this information was found!',
        );
}

//auth/requires-recent-login
@immutable
class AuthErrorRequiresRecentLogin extends AuthError {
  const AuthErrorRequiresRecentLogin()
      : super(
          dialogTitle: 'Required recent login!',
          dialogText:
              'You need to log out and log back in again to pereform this operation',
        );
}

//auth/operation-not-allowed
@immutable
class AuthErrorOperationNotAllowed extends AuthError {
  const AuthErrorOperationNotAllowed()
      : super(
          dialogTitle: 'Operation not allowed!',
          dialogText: 'You can not register using this method at this moment',
        );
}

//auth/user-not-found
@immutable
class AuthErrorUserNotFound extends AuthError {
  const AuthErrorUserNotFound()
      : super(
          dialogTitle: 'User not found',
          dialogText: 'The given user was not found on the server!',
        );
}

//auth/week-password
@immutable
class AuthErrorWeekPassword extends AuthError {
  const AuthErrorWeekPassword()
      : super(
          dialogTitle: 'Week password',
          dialogText:
              'Please chose a stronger password consisting of more characters!',
        );
}

//auth/invalid-email
@immutable
class AuthErrorInvalidEmail extends AuthError {
  const AuthErrorInvalidEmail()
      : super(
          dialogTitle: 'Invalid email',
          dialogText: 'Please double check your email and try again!',
        );
}

//auth/email-already-in-use
@immutable
class AuthErrorEmailAlreadyInUse extends AuthError {
  const AuthErrorEmailAlreadyInUse()
      : super(
          dialogTitle: 'Email already in use',
          dialogText: 'Please choose another email to register with!',
        );
}
