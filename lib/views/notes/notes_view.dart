import 'package:appy/constants/routes.dart';
import 'package:appy/enums/menu_action.dart';
import 'package:appy/services/auth/auth_service.dart';
import 'package:appy/services/crud/notes_service.dart';
import 'package:appy/utilities/dialogs/logout_dialog.dart';
import 'package:appy/views/notes/notes_list_view.dart';
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
                  if (snapshot.hasData){
                    final allNotes = snapshot.data as List<DatabaseNote>;
                    return NotesListView(
                      notes: allNotes,
                       onDeleteNote:(note) async { 
                        await _notesService.deleteNote(id: note.id);

                       },
                       );
                  
                  }else{

                    return const CircularProgressIndicator();
                  }
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

