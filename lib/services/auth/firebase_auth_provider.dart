import 'package:appy/firebase_options.dart';
import 'package:appy/services/auth/auth_user.dart';
import 'package:appy/services/auth/auth_provider.dart';
import 'package:appy/services/auth/auth_exceptions.dart';

import 'package:firebase_auth/firebase_auth.dart'
  show FirebaseAuth, FirebaseAuthException;
import 'package:firebase_core/firebase_core.dart';

class FirebaseAuthProvider implements AuthProvider{
  @override
  Future<AuthUser> createUser({
    required String email,
   required String password
   })async
    {
      try{
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email, 
          password: password,
          );
          final user = currentUser;//gets user from fire base
          // if user is there,we reutrn current user or  has created account without exception is not still vailable 
          //we return user not logged in
          if (user != null){//user not null !=
            return user;
            }else{
              throw  UserNotLoggedInAuthException();
          }

      } on FirebaseAuthException catch (e){
        if (e.code == 'weak-password') {
          throw WeakPasswordAuthException();
                } else if (e.code == 'email-already-in-use') {
                  throw EmailAlreadyInUseAuthException();
                } else if (e.code == 'invalid-email') {
                  throw InvalidEmailAuthException();
                } else {
                  throw GenericAuthException();// if exist an error that we do not know
                }

      }catch (_){
throw GenericAuthException(); //catching any exception other than firebase
      }//generic catch
    }

  @override
   //@Override annotation or keyword is used to indicate that a method in a subclass is intended to override a method in its superclass. 
  //turn firebase user to an authuser. Our factory constractor had authuser
AuthUser? get currentUser{
//the possibility that there might not be a current user (hence the nullable type).
    final user = FirebaseAuth.instance.currentUser; //we call factory constructor
    if (user != null){
      return AuthUser.fromFirebase(user);
}else{
  return null;
}
}

  @override
  Future<void> logOut() 
  async {
    final user = FirebaseAuth.instance.currentUser;
    if (user !=null){
      await FirebaseAuth.instance.signOut();
    }else{
      throw UserNotLoggedInAuthException();
    }
    }

  @override
  Future<AuthUser> login({
    required String email,
     required String password
     }) 
     async{
      try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
        );
        final user = currentUser;//gets user from fire base
          // if user is there,we reutrn current user or  has created account without exception is not still vailable 
          //we return user not logged in
          if (user != null){//user not null !=
            return user;
            }else{
              throw  UserNotLoggedInAuthException();
          }
  } on FirebaseAuthException catch (e){
    if (e.code == 'user-not-found'){
      throw  UserNotFoundAuthException();
      }else if (e.code == 'wrong-password'){
        throw WrongPasswordAuthException();
      }else{
      throw GenericAuthException();
      }
  }catch (_) { //in dart ,you cannot ignore variable, use (_) or you can use e , we are not interested in e here
  //where we have (e) in dart,we have to patter match and the name is e
    throw GenericAuthException();
  }
     }


  @override
  Future<void> sendEmailVerification()
   async {
    final user = FirebaseAuth.instance.currentUser;
    if (user !=null)
    {
      await user.sendEmailVerification();
    }else{
     throw UserNotLoggedInAuthException(); 
    }}
    
      @override
      Future<void> initialize() async {
       await Firebase.initializeApp(
                options: DefaultFirebaseOptions.currentPlatform,
              );
 
      }
  }