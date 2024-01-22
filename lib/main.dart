import 'package:appy/constants/routes.dart';
import 'package:appy/services/auth/auth_service.dart';
import 'package:appy/views/login_view.dart';
import 'package:appy/views/notes_view.dart';
import 'package:appy/views/register_view.dart';
import 'package:flutter/material.dart';
import 'package:appy/views/verify_email_view.dart';
//import 'dart:developer' as devtools show log;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 95, 89, 165)),
        useMaterial3: true,
      ),
      home: const HomePage(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        notesRoute:(context)=> const NotesView(),
        verifyEmailRoute:(context)=> const VerifyEmailView(),
      }
    ),
    );
}
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context,snapshot){
        switch (snapshot.connectionState){
          case ConnectionState.done:
          final user = AuthService.firebase().currentUser;
          if (user !=null ) {
            if(user.isEmailVerified){  //Boolean flag to use is 
             return const NotesView();
            } else {
              
              return const VerifyEmailView();
          }
          }else{
            return const LoginView();
          }
    
      default:
       return const CircularProgressIndicator();
       }
       },
      );
  }
}


