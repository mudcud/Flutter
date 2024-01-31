import 'package:appy/services/auth/auth_service.dart';
import 'package:appy/services/crud/notes_service.dart';
import 'package:flutter/material.dart';

class NewNoteView extends StatefulWidget {
  const NewNoteView({super.key});

  @override
  State<NewNoteView> createState() => _NewNoteViewState();
}

class _NewNoteViewState extends State<NewNoteView> {
  // Every time we hot reload, it will build again & new note every time, we need to take care of that

  // Variable to keep off
  // We keep hold of a variable called note so to prevent it for being recreated every time when build function is called
  DatabaseNote? _note;
  // Keep hold of note service note to call it over and over again and also text editing controller
  late final NotesService _notesService;
  late final TextEditingController _textController;

  @override
  void initState() {
    _notesService = NotesService();
    _textController = TextEditingController();

    super.initState();
  }

  // Update current note upon text changes
  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textController.text;
    await _notesService.updateNote(
      note: note,
      text: text,
    );
  }

  // Hook text field changes  to the listener
  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    // Removes listener from controller if it is already added
    _textController.addListener(_textControllerListener);
    // Adds it again
  }

  Future<DatabaseNote> createNewNote() async {
    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    // Create new note if it does not exist
    // Current user!, we unwrap where we expect the user to be there if you end up in the newnoteview
    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _notesService.getUser(email: email);
    return await _notesService.createNote(owner: owner);
  }

  // Delete empty text
  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      _notesService.deleteNote(id: note.id);
    }
  }

  // Save text automatically if text note empty
  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    if (note != null && text.isNotEmpty) {
      await _notesService.updateNote(
        note: note,
        text: text,
      );
    }
  }

  // Take care of disposal, that is when the user presses back arrow without writing any note
  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New notes'),
      ),
      // Creating future builder that creates the note & assigns it to note variable
      body: FutureBuilder(
        future: createNewNote(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _note = snapshot.data as DatabaseNote;
              // Start listening
              _setupTextControllerListener();
              return TextField(
                // Proxy to text field
                controller: _textController,
                // Text field sends messages to text editing controller that my text has changed
                // Allow user to enter multiple lines of text field since they are not by default
                keyboardType: TextInputType.multiline,
                // Key to go to the next line
                maxLines: null,
                // To allow text field to expand when you enter text, use null
                decoration: const InputDecoration(
                  // For hint
                  hintText: 'Type your notes here',
                ),
              );

            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
