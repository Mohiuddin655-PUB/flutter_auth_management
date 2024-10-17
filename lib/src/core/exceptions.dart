class AuthDelegateException {
  final String name;

  const AuthDelegateException(this.name);

  String get message {
    return "$name currently not initialized\n"
        "You can initialize like this:\n\n"
        '''
        ...
        
        Step-1: Add dependencies
        ```yaml
        auth_management_apple_delegate: ^x.y.z
        auth_management_biometric_delegate: ^x.y.z
        auth_management_facebook_delegate: ^x.y.z
        auth_management_google_delegate: ^x.y.z
        ```
        
        Step-2: import necessary dependencies
        ```dart
        import 'package:auth_management_apple_delegate/auth_management_apple_delegate.dart';
        import 'package:auth_management_biometric_delegate/auth_management_biometric_delegate.dart';
        import 'package:auth_management_facebook_delegate/auth_management_facebook_delegate.dart';
        import 'package:auth_management_google_delegate/auth_management_google_delegate.dart';
        ```
        
        Step-3: Add delegate as you like in application root level
        ```dart
        AuthProvider<User>(
          initialCheck: true,
          authorizer: Authorizer(
            authRepository: AuthRepository.create(
              appleAuthDelegate: AppleAuthDelegate(),
              biometricAuthDelegate: BiometricAuthDelegate(),
              facebookAuthDelegate: FacebookAuthDelegate(),
              googleAuthDelegate: GoogleAuthDelegate(
                googleSignIn: GoogleSignIn(scopes: [
                  'email',
                ]),
              ),
            ),
            backupRepository: BackupRepository.create(
              key: "_local_user_key_",
              delegate: UserBackupDelegate(),
              reader: (key) async {
                final db = await SharedPreferences.getInstance();
                // get from any local db [Hive, SharedPreferences, etc]
                return db.getString(key);
              },
              writer: (key, value) async {
                final db = await SharedPreferences.getInstance();
                if (value == null) {
                  // remove from any local db [Hive, SharedPreferences, etc]
                  return db.remove(key);
                }  
                // save to any local db [Hive, SharedPreferences, etc]
                return db.setString(key, value);
              },
            ),
          ),
          child: MaterialApp(
            title: 'Auth Management',
            theme: ThemeData(
              primaryColor: Colors.deepOrange,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepOrange,
                primary: Colors.deepOrange,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                  border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              )),
            ),
            initialRoute: "startup",
            onGenerateRoute: routes,
          ),
        );
        ````
        ''';
  }
}
