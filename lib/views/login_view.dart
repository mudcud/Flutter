//import 'package:appy/firebase_options.dart';
import 'package:appy/constants/routes.dart';
import 'package:appy/utilities/show_error_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
//import 'dart:developer' as devtools show log;
class LoginView extends StatefulWidget {

  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

@override
  void initState() {
    _email = TextEditingController();
    _password =TextEditingController();
    // TODO: implement initState
    super.initState();
  }


@override
  void dispose() {
    _email.dispose();
    _password.dispose(); 
    // TODO: implement dispose
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text ('Login'),
      ),
      body: Column(
          children: [
            TextField(
              controller: _email,
              enableSuggestions: false,
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Enter email'
              ),
            ),
            TextField(
              controller: _password,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: const InputDecoration(
                hintText:'Enter password'
              ),
              
            ),
            TextButton(
              onPressed: () async {
            
                final email = _email.text;
                final password = _password.text;
                try{
                 await FirebaseAuth.instance.signInWithEmailAndPassword(
                  email: email,
                  password: password,
                  );
                  final user = FirebaseAuth.instance.currentUser;
                  if(user?.emailVerified ?? false){
                    // user's email is verified
                    Navigator.of(context).pushNamedAndRemoveUntil(
                    notesRoute, (route) => false,
                  );
                  } else{
                    // user's email is not verified
                     Navigator.of(context).pushNamedAndRemoveUntil(
                    verifyEmailRoute, (route) => false,
                  );
                  }
                  Navigator.of(context)
                  .pushNamedAndRemoveUntil(
                    notesRoute, (route) => false,
                  );
                   
                } on FirebaseAuthException catch (e){
                  if (e.code == 'user-not-found'){
                  await showErrorDialog(
                    context, 
                    'user not found',
                    );
                  }
                  else if (e.code == 'wrong-password')
                  {
                    await showErrorDialog(
                    context, 
                    'wrong credentials',
                    );
                  } else{
                    await showErrorDialog(
                      context,
                      'Error: ${e.code}',
                    );
                  }
                } catch (e) {
                  await showErrorDialog(
                      context,
                      e.toString(),
                  );

                }   
              },
              child: const Text('Login Here')
            ),
            TextButton(onPressed: (){
              Navigator.of(context).pushNamedAndRemoveUntil(
                registerRoute, 
                (route) => false);
            },
             child: const Text('Not registered? Register here'),
            )
          ],
        ),
    );
  }
}   

