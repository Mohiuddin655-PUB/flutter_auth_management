part 'credential.dart';
part 'password.dart';
part 'scopes.dart';
part 'state.dart';
part 'web_authentication_options.dart';

abstract class IAppleAuthDelegate {
  /// Returns whether Sign in with Apple is available on the current platform.
  ///
  /// If this returns `true`, [getAppleIDCredential] will not throw a [SignInWithAppleNotSupportedException] when called.
  ///
  /// Sign in with Apple is available on:
  /// - iOS 13 and higher
  /// - macOS 10.15 and higher
  /// - Android
  /// - Web
  ///
  /// In case Sign in with Apple is not available, the returned Future completes with `false`.
  Future<bool> isAvailable();

  /// Requests an Apple ID credential.
  ///
  /// Shows the native UI on Apple's platform, a Chrome Custom Tab on Android, and a popup on Websites.
  ///
  /// The returned [AuthorizationCredentialAppleID]'s `authorizationCode` should then be used to validate the token with Apple's servers and
  /// create a session in your system.
  ///
  /// Fields on the returned [AuthorizationCredentialAppleID] will be set based on the given scopes.
  ///
  /// User data fields (first name, last name, email) will only be set if this is the initial authentication between the current app and Apple ID.
  ///
  /// The returned Future will resolve in all cases on iOS and macOS, either with an exception if Sign in with Apple is not available,
  /// or as soon as the native UI goes away (either due cancellation or the completion of the authorization).
  ///
  /// On Android the returned Future will never resolve in case the user closes the Chrome Custom Tab without finishing the authentication flow.
  /// Any previous Future would be rejected if the [getAppleIDCredential] is called again, while an earlier one is still pending.
  ///
  /// Throws an [SignInWithAppleException] in case there was any error retrieving the credential.
  /// A specialized [SignInWithAppleAuthorizationException] is thrown in case of authorization errors, which contains
  /// further information about the failure.
  ///
  /// Throws an [SignInWithAppleNotSupportedException] in case Sign in with Apple is not available (e.g. iOS < 13, macOS < 10.15)
  Future<IAppleAuthorizationCredentialAppleID> getAppleIDCredential({
    required List<IAppleIDAuthorizationScopes> scopes,

    /// Optional parameters for web-based authentication flows on non-Apple platforms
    ///
    /// This parameter is required on Android and on the Web.
    IAppleWebAuthenticationOptions? webAuthenticationOptions,

    /// Optional string which, if set, will be be embedded in the resulting `identityToken` field on the [AuthorizationCredentialAppleID].
    ///
    /// This can be used to mitigate replay attacks by using a unique argument per sign-in attempt.
    ///
    /// Can be `null`, in which case no nonce will be passed to the request.
    String? nonce,

    /// Data that’s returned to you unmodified in the corresponding [AuthorizationCredentialAppleID.status] after a successful authentication.
    ///
    /// Can be `null`, in which case no state will be passed to the request.
    String? state,
  });

  /// Returns the credentials state for a given user.
  ///
  /// This method is only available on Apple platforms (which are also the only platforms where one retrieves a `userIdentifier` within [AuthorizationCredentialAppleID] instances).
  ///
  /// The [userIdentifier] argument should come from a previous call to [getAppleIDCredential] which returned an [AuthorizationCredentialAppleID].
  ///
  /// Throws a [SignInWithAppleException] in case of errors, and a specific [SignInWithAppleCredentialsException] in case there was an error
  /// while getting the credentials state.
  ///
  /// Throw a [SignInWithAppleNotSupportedException] on unsupported platforms.
  Future<IAppleCredentialState> getCredentialState(String userIdentifier);

  /// Returns the credentials stored in the Keychain for the website associated with the current app.
  ///
  /// Only available on Apple platforms.
  ///
  /// Throws a [SignInWithAppleException] exception when no credentials have been found in the Keychain.
  Future<IAppleAuthorizationCredentialPassword> getKeychainCredential();
}
