 import 'package:flutter/material.dart';
 typedef DialogOptionBuilder<T> = Map<String,T?> Function();// when we use map,it returns iterable, now we return .toList to be a list
//button shud optional have a value T
//map matches title with values. Map<String,T?>make value unique.cannot have two button of same values
Future<T?> showGenericDialog <T>({
  required BuildContext context,
  required String title,
  required String content,
  required DialogOptionBuilder optionsBuilder,
  
}){
  final options = optionsBuilder();
  //call data type T
  return showDialog<T>(
    context: context,
    builder: (context){
      return AlertDialog(
        title: Text(title), 
        content: Text(content),
        actions: options.keys.map((optionTitle){
          final value = options[optionTitle];
          return TextButton(
          onPressed: (){
            if (value!= null){
              Navigator.of(context).pop(value);

            }else{
              Navigator.of(context).pop();//where buton does not have value .ie OK button
            }
          },
          child:Text(optionTitle),
          ); 

        }).toList(),

      );
    },
  );
}