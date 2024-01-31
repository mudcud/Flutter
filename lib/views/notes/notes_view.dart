import 'package:appy/constants/routes.dart';
import 'package:appy/enums/menu_action.dart';
import 'package:appy/services/auth/auth_service.dart';
import 'package:appy/services/crud/notes_service.dart';
import 'package:flutter/material.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});
  // stateful so as to open our database upon creation of notesview ,and close it upon disposed

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {


late final NotesService _notesService;//notes view grabbing instance on  notes service to work with it
String get userEmail => AuthService.firebase().currentUser!.email!;//Grab user email
// cureent user at was optional in firebase and now we use ! to force unwrap

//Opening the database
@override
void initState()  {
  _notesService =NotesService();
  super.initState();
}

//CLosing the database
@override
void dispose()  {
  _notesService.close();
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your'),
        actions: 
        [// list of actions to be performed

          IconButton(onPressed: (){
            Navigator.of(context).pushNamed(newNoteRoute); 
          },
          icon:const Icon(Icons.add), 
          ),
          PopupMenuButton<MenuAction>(
          onSelected: (value) async {
            switch(value){
              case MenuAction.logout :
              final shouldLogout = await showLogOutDialog(context);
              if (shouldLogout){
                await AuthService.firebase().logOut();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  loginRoute,
                  (_)=>false,
                  );
              }
            }
          }, 

          itemBuilder: (context) {
           return const[
            PopupMenuItem<MenuAction>
            (
              value: MenuAction.logout,
              child:Text('Log out'),

            ),
           ];   
          },)
        ]

      ),
      
      body :FutureBuilder(
        future: _notesService.getOrCreateUser(email: userEmail) ,
        builder: (context,snapshot){
          switch (snapshot.connectionState){

            case ConnectionState.done:
            return  StreamBuilder(
              stream:_notesService.allNotes,// getting from note_service
              builder:(context, snapshot) {
                switch(snapshot.connectionState){

                  case ConnectionState.waiting://fall thru,case has no logic,it flow to next logic
                  case ConnectionState.active:
                    return const Text ('Waiting fo notes');
                  default:
                    return const CircularProgressIndicator();         
                }
              },
               );
            
            default:
            return const CircularProgressIndicator();    
          }
        },
        
      
        ),
    );
  }
}

Future<bool> showLogOutDialog(BuildContext context){
 return showDialog<bool> (
  context:context,
    builder: (context){
      return AlertDialog(
        title: const Text ('Sign out'),
        content: const Text('Are you sure you want to sign out'),
        actions: [
TextButton(onPressed: (){
  Navigator.of(context).pop(false);
}, child: const Text ('Cancel'),
),
TextButton(onPressed: (){
  Navigator.of(context).pop(true);
}, child: const Text ('Log out'),
),
        ],
      );
   
},
).then((value) => value ?? false);
}