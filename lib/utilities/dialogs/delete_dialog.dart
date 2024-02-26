import 'package:appy/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<bool> showDeleteDialog(BuildContext context){
  return showGenericDialog<bool>(
    context: context,
     title: 'delete', 
     content: 'Do you want to delete?',
     optionsBuilder: ()=>{
      'cancel': false,
      'yes': true,
     },
  ).then(
    (value)=>value ?? false,
  );
}
