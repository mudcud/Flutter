//we need abstract class that return instance of auth _user
//an abstract class is a class that cannot be instantiated on its own and is typically meant to be subclassed by other classes
import 'package:appy/services/auth/auth_user.dart';
// using abstract, you can extend more and mpore auth provider
abstract class AuthProvider {
Future <void> initialize();// Future goes to auth service, not firbase directly from main.dart  Firebase.initialize App


  AuthUser? get currentUser;
  //login
  Future<AuthUser> login({
    required String email,
    required String password,
  });
  //create /register/sign up
    Future<AuthUser>createUser({
    required String email,
    required String password,
  });
  //logout
Future<void> logOut();
Future<void> sendEmailVerification();
}

//in future you caan add more auth provider, here we only use firebase auth