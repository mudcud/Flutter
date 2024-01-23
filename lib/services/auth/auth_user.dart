import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

 
 @immutable //internal willnever be changed upon utilization
 class AuthUser{
  final bool isEmailVerified;
//This class has a single member variable called isEmailVerified, which is a boolean (true/false) value.
  const AuthUser({required this.isEmailVerified});
//a constructor is a special method within a class that is automatically called when an object of the class is created
//This is a constructor for the AuthUser class
//It takes a boolean parameter named isEmailVerified and assigns it to the class member with the same name
  factory AuthUser.fromFirebase(User user)=> 
  AuthUser(isEmailVerified: user.emailVerified);
  

//AuthUser goes into the constractor line 9 and takes email verified value of firebase user and place in the class line 6
//A factory constructor is used to create instances of the class.
//an instance is a unique copy of a class, and it represents a particular object with its own set of attributes and behaviors.
//It's named fromFirebase and takes a User object from Firebase as a parameter.
//It creates and returns a new instance of the AuthUser class using the AuthUser constructor.

//here we copied firebase user and made copy of it into our of user so thatwe are not exposing firebase user with all ot its property to our user interface


 }