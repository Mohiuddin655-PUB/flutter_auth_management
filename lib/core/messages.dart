class AuthMessage {
  final String? done;
  final String? failure;

  const AuthMessage({
    this.done,
    this.failure,
  });
}

class AuthMessages {
  final String? authorization;
  final String? biometric;
  final String? email;
  final String? error;
  final String? otp;
  final String? phoneNumber;
  final String? password;
  final String? username;
  final String? token;

  final AuthMessage delete;

  final AuthMessage loggedIn;
  final AuthMessage loggedOut;

  final AuthMessage signInWithApple;
  final AuthMessage signInWithBiometric;
  final AuthMessage signInWithEmail;
  final AuthMessage signInWithFacebook;
  final AuthMessage signInWithGithub;
  final AuthMessage signInWithGoogle;
  final AuthMessage signInWithPhone;
  final AuthMessage signInWithUsername;

  final AuthMessage signUpWithEmail;
  final AuthMessage signUpWithUsername;

  final AuthMessage signOut;

  const AuthMessages({
    this.authorization = "Authorization data not found!",
    this.biometric = "Biometric not initialized yet!",
    this.email = "Email isn't valid!",
    this.error = "Something went wrong, please try again!",
    this.otp = "OTP Code isn't valid!",
    this.phoneNumber = "Phone number isn't valid!",
    this.password = "Password isn't valid!",
    this.username = "Username isn't valid!",
    this.token = "Token isn't valid!",
    this.delete = const AuthMessage(
      done: "User deleted!",
      failure: "User not deleted!",
    ),
    this.loggedIn = const AuthMessage(
      done: "User logged in!",
      failure: "You're not logged in!",
    ),
    this.loggedOut = const AuthMessage(
      done: "User logged out!",
    ),
    this.signInWithApple = const AuthMessage(
      done: "Apple sign in successful!",
    ),
    this.signInWithBiometric = const AuthMessage(
        done: "Biometric sign in successful!",
        failure: "Biometric not initialized yet!"),
    this.signInWithEmail = const AuthMessage(
      done: "Sign in successful!",
    ),
    this.signInWithFacebook = const AuthMessage(
      done: "Facebook sign in successful!",
    ),
    this.signInWithGithub = const AuthMessage(
      done: "Github sign in successful!",
    ),
    this.signInWithGoogle = const AuthMessage(
      done: "Google sign in successful!",
    ),
    this.signInWithPhone = const AuthMessage(
      done: "Phone sign in successful!",
    ),
    this.signInWithUsername = const AuthMessage(
      done: "Sign in successful!",
    ),
    this.signUpWithEmail = const AuthMessage(
      done: "Sign up successful!",
    ),
    this.signUpWithUsername = const AuthMessage(
      done: "Sign up successful!",
    ),
    this.signOut = const AuthMessage(
      done: "Sign out successful!",
    ),
  });
}
