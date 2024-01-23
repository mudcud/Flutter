import 'package:appy/services/auth/auth_provider.dart';
import 'package:appy/services/auth/auth_user.dart';
import 'package:appy/services/auth/firebase_auth_provider.dart';


//auth service does not authentic only firebase, it takes a what you have in auth provider
//in this code it only exposes same provider firebase to the outside world

class AuthService implements AuthProvider{
  final AuthProvider provider;

  const AuthService(this.provider);

  factory AuthService.firebase()=> AuthService(FirebaseAuthProvider());
  // return instance of auth service which config with firebase provider
  
  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
     })  => 
    provider.createUser(email: email,
    password: password,
    );

  @override

  AuthUser? get currentUser => provider.currentUser;
  
  @override
 Future<void> logOut() => provider.logOut();
  
  @override
  Future<AuthUser> login({
    required String email, 
    required String password,
    }) => provider.login(
      email:email,
      password: password,
    );
  
  @override
   Future<void> sendEmailVerification() => provider.sendEmailVerification();
   
     @override
     Future<void> initialize() => provider.initialize();

     
}