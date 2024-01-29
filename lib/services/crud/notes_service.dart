import 'dart:async';

import 'package:appy/services/crud/crud_exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join; //getting particular function

class NotesService {
  Database? _db;
  
  List<DatabaseNote> _notes =[];//our cache,where we keep all the notes   //Notes list contains all notes
  //control list of stream of database



 static final NotesService _shared =NotesService._sharedInstance();//singleton
  NotesService._sharedInstance();
  factory NotesService()=> _shared;
 
  final _notesStreamController =  //Stream controller is our interface to the outside
  StreamController<List<  DatabaseNote>>.broadcast();
  //broadcast allow one to create new listners that listens to changes. i.e when is not used,when hot restart,it will saay stream has already listned
 
 Stream<List<DatabaseNote>> get allNotes => _notesStreamController.stream;//will be used by notes view to return future and use StreamBuilder to display all notes

 Future<DatabaseUser> getOrCreateUser({required String email}) async{
  try{
  final user = await  getUser (email: email);
  return user; 
  } on CouldNotFindUser{
    final createdUser = await createUser(email:email);
    return createdUser;
    } catch(e){
      rethrow;
    }

 }

//read notes in BD and place in  stramcontroller externally and List<DatabaseNote internally
Future <void> _cacheNotes() async{
  final allNotes = await getAllNotes();
_notes = allNotes.toList();
_notesStreamController.add(_notes);

}

  // update notes
  Future<DatabaseNote> updateNote(
      {required DatabaseNote  note, required String text}) async {
        await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    //Make sure the note exist
    await getNote(id: note.id);
    //update DB

    final updatesCount = await db.update(noteTable, {
      textColumn: text,
      isSyncedWithCloudColumn: 0,
    });
    if (updatesCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      final updatedNote =  await getNote(id: note.id);//get new obbject from the database
      _notes.removeWhere((note) => note.id == updatedNote.id);// remove note from local cache
      _notes.add(updatedNote);//update it next
      _notesStreamController.add(_notes);

      return updatedNote;
    }
  }

  // get all notes
  Future<Iterable<DatabaseNote>> getAllNotes() async {
    await _ensureDbIsOpen();
    

    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable);

    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  // fetching specific notes
  Future<DatabaseNote> getNote({required int id}) async {
    await _ensureDbIsOpen();
     await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
      limit: 1,
      where: 'id =?',
      whereArgs: [id],
    );

    if (notes.isEmpty) {
      throw CouldNotFindNote();
    } else {
      final note=  DatabaseNote.fromRow(notes.first);
      _notes.removeWhere((note)=>note.id ==id);// remove existing notes from the note and add new 
      _notes.add(note);
      _notesStreamController.add(_notes);

      return note;
    }
  }

  // delete all note
  Future<int> deleteAllNotes() async {
    await _ensureDbIsOpen();
    
    final db = _getDatabaseOrThrow();
    final numberOfDeletions = await db.delete(noteTable);

    _notes =[];// ensure local cache is updated
    _notesStreamController.add(_notes);// User interface is updated with lates information 
    return numberOfDeletions;

  }

  Future<void> deleteNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    ); // if not did not exist, we throw error could not delete

    if (deletedCount == 0) {
      throw CouldNotDeleteNote();

    } else{
      _notes.removeWhere((note)=> note.id ==id);// we remove also the deleted note in local cache
      _notesStreamController.add(_notes);
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    // make sure database user is inside the database
    final dbUser = await getUser(email: owner.email);
    // check database user is the owner with correct id
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }
    const text = '';
    // create notes
    final noteId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      textColumn: text,
      isSyncedWithCloudColumn: 1,
    });
    final note = DatabaseNote(
        id: noteId, 
        userId: owner.id, 
        text: text, 
        isSyncedWithCloud: true);

        _notes.add(note);//after creating notes,we add it to array of notes
        _notesStreamController.add(_notes);//also add to stream controller. Stream controller reflect values in _notes to the ouside world


    return note;

  }

  Future<DatabaseUser> getUser({required String email}) async {
     await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1, // either zero or one row
      where: 'email =?',
      whereArgs: [email.toLowerCase()],
    ); // opposite of create use, there it was itwasnot empty, here we use isEmpty

    if (results.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
     await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    // Check user with existing name exists in the user table, we are not inserting anything. It will return a list of rows. empty if no entity match

    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email =?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }

    // if user does not exist, insert him
    final userId = await db.insert(
      userTable,
      {emailColumn: email.toLowerCase()},
    );
    return DatabaseUser(id: userId, email: email);
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(userTable,
        where: 'email =?', // where email is equal to something
        whereArgs: [email.toLowerCase()]);

    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Database _getDatabaseOrThrow() {
    // Private function reading and writing internal function in this class. To get the current class to avoid doing the same if statement every time

    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen(); // ask sqflite to close the database for us
    } else {
      await db.close();
      _db = null;
    }
  }
  //Before any operation,the database should be open
  Future<void> _ensureDbIsOpen()async{
   //cache so as when hot reload,the database not to open everytime.
   // Incase it does,open function  open() will throw an exceptipon and ensureBdIsOpen will catche it and let it go.we ensure we are not opening DB over and over again
    try{
await open();

    }on DatabaseAlreadyOpenException {
    
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath); // opendatabase comes from sqflite
      _db = db;
      // create user table

      await db.execute(createUserTable);

      await db.execute(createNoteTable);
      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }
}


// creating database user class
@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id,
    required this.email,
  });

  // talking with the database, we read like a hash table. Every user in the user table will be represented with Map of string, and optional objects
  // Notes services read users from the DB, pass it the database user class and the database user class should create an instance of itself

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID = $id,email=$email';

  // covariant is a keyword that allows changing the behavior of input parameters so that they are not necessarily required to conform to the signature of the superclass
  // compare our class with another user of the same class
  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// class for our notes
class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudColumn] as int?) == 1 ? true : false;

  @override
  String toString() =>
      'Note, ID=$id, userId= $userId, isSyncedWithCloud = $isSyncedWithCloud, text =$text';

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'appy.db';
const userTable = 'Users';
const noteTable = 'Notes';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'is_synced';

const createUserTable = '''
      CREATE TABLE IF NOT EXISTS "user" (
      "id"	INTEGER NOT NULL,
      "email"	TEXT NOT NULL UNIQUE,
      PRIMARY KEY("id" AUTOINCREMENT)
);
      ''';

const createNoteTable = '''
      CREATE TABLE IF NOT EXISTS "note" (
      "id"	INTEGER NOT NULL,
      "user_id"	INTEGER NOT NULL,
      "text"	TEXT,
      "sync_cloud"	INTEGER NOT NULL,
      FOREIGN KEY("user_id") REFERENCES "user"("id"),
      PRIMARY KEY("id" AUTOINCREMENT)
);
    ''';
