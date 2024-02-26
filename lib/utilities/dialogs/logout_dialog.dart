import 'package:appy/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<bool> showLogOutDialog(BuildContext context){
  return showGenericDialog<bool>(
    context: context,
     title: 'Logout', 
     content: 'Do you want to logout?',
     optionsBuilder: ()=>{
      'cancel': false,
      'log out': true,
     },
  ).then(
    (value)=>value ?? false,
  );
}
