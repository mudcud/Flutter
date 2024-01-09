import 'package:appy/firebase_options.dart';
import 'package:appy/views/login_view.dart';
import 'package:appy/views/register_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';


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
        '/login/': (context) => const LoginView(),
        '/register/': (context) => const RegisterView(),
      }
    ),
    );
}
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
                options: DefaultFirebaseOptions.currentPlatform,
              ),
      builder: (context,snapshot){
        switch (snapshot.connectionState){
          case ConnectionState.done:
          //final user = FirebaseAuth.instance.currentUser;

         // if(user?.emailVerified ?? false) {
         // }else {
         //  return const VerifyEmailView();
         // }
         // return Text('Done');
        return  const LoginView();
      default:
       return const CircularProgressIndicator();
       }
       },
      );
    
  }

}
