import 'package:appy/services/crud/notes_service.dart';
import 'package:flutter/material.dart';
import 'package:appy/utilities/dialogs/delete_dialog.dart';

typedef DeleteNoteCallback = void Function(DatabaseNote note);

class NotesListView extends StatelessWidget {
final List<DatabaseNote> notes;
final DeleteNoteCallback onDeleteNote;

  const NotesListView({super.key, 
  required this.notes, 
  required this.onDeleteNote});

  @override
  Widget build(BuildContext context) {
     return ListView.builder(
                    itemCount: notes.length,
                    itemBuilder: (context,index){//current notes INDEX is provided with itembuilder(index)
                      final note = notes[index]; 
                      return ListTile(
                        title: Text(
                          note.text,
                          maxLines: 1,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis, // have ellipis to text that do not have enoughspace to render
                          ),
                          
                          //choose widget to be displayed at the end of every list
                       trailing: IconButton(
                        onPressed: () async {
                          final shouldDelete = await showDeleteDialog(context);
                          if (shouldDelete){
                            onDeleteNote(note);
                          }

                        },
                        icon: const Icon(Icons.delete),

                       ),
                        );
                  },
                  );

    
  }
} 