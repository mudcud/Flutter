import 'package:appy/services/auth/auth_provider.dart';
import 'package:appy/services/auth/auth_user.dart';
import 'package:firebase_auth/firebase_auth.dart';

//auth service does not authentic only firebase, it takes a what you have in auth provider
//in this code it only exposes same provider firebase to the outside world


class AuthService implements AuthProvider{
  final AuthProvider provider;
  const AuthService(this.provider);
  
  @override
  Future<AuthUser> currentUser({  
    required String email,
    required String password
    }) => 
    provider.createUser(emailemail: email,
    password: password,
    ) ;

    @override
    AuthUser? get currentUser => provider.currentUser;

    @override
    Future<AuthUser> login({
      required String email,
      required String password,

    })=>
    provider.login(emailemail:email,
    password: password,
    );
    @override
    Future<void> logOut() => provider.logOut();

      @override
    Future<void> sendEmailVerification() => provider.sendEmailVerification();

    }



}

