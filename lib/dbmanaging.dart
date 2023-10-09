import 'package:datapersistence/main.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';

class EntriesDatabase {
  Database? dbase;
  Future<Database> get database async {
    if (dbase != null) {
      return dbase!;
    } else {
      dbase = await openDatabase(
        '${getDatabasesPath()}entries.db',
        version: 1,
        onCreate: (db, version) {
          db.execute(
            'CREATE TABLE notes(id INTEGER PRIMARY KEY, title TEXT, text TEXT)',
          );
        },
      );
      return dbase!;
    }
  }

  Future<void> modifyEntry(int id, Entry entry) async {
    await (await database).update('notes', where: "id=$id", entry.toMap());
  }

  Future<List<Entry>> getEntries() async {
    final maps = await (await database).query('notes');
    return List.generate(
      maps.length,
      (index) => Entry(
        text: maps[index]["text"] as String,
        title: maps[index]["title"] as String,
        id: maps[index]["id"] as int,
      ),
    );
  }

  Future<void> deleteEntry(int id) async {
    (await database).delete('notes', where: 'id=?', whereArgs: [id]);
  }

  Future<void> addEntry(Entry entry) async {
    (await database).insert('notes', entry.toMap());
  }
}

class Entry extends StatelessWidget {
  final int? id;
  final String title;
  final String text;
  const Entry({
    super.key,
    this.id,
    required this.title,
    required this.text,
  });
  Map<String, dynamic> toMap() {
    if (id != null) {
      return {
        'id': id,
        'title': title,
        'text': text,
      };
    } else {
      return {
        'title': title,
        'text': text,
      };
    }
  }

  Future<void> selfDelete(BuildContext context) async {
    if (id != null) {
      context.read<DbModel>().removeEntry(id!);
    }
  }

  Future<void> readThis(BuildContext context) async {
    if (id != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ViewNote(title: title, text: text),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenwidth = MediaQuery.of(context).size.width;
    return Card(
      color: const Color.fromARGB(255, 185, 216, 231),
      child: SizedBox(
          width: screenwidth * 0.8,
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton.small(
                    onPressed: () {
                      readThis(context);
                    },
                    child: const Icon(Icons.remove_red_eye),
                  ),
                  FloatingActionButton.small(
                    onPressed: () {
                      selfDelete(context);
                    },
                    child: const Icon(Icons.delete),
                  ),
                  FloatingActionButton.small(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return EditNote(id: id!);
                        },
                      ));
                    },
                    child: const Icon(Icons.edit),
                  )
                ],
              )
            ],
          )),
    );
  }
}

class DbModel extends ChangeNotifier {
  final EntriesDatabase _db = EntriesDatabase();
  List<Entry> _entries = [];

  void init() async {
    _entries = await _db.getEntries();
    notifyListeners();
  }

  List<Entry> get entries {
    return _entries;
  }

  void addEntry(Entry ent) async {
    _db.addEntry(ent);
    notifyListeners();
  }

  void removeEntry(int id) async {
    for (var i = 0; i < _entries.length; i++) {
      if (_entries[i].id == id) {
        _entries.removeAt(i);
        _db.deleteEntry(id);
        notifyListeners();
        break;
      }
    }
  }

  Entry getEntry(int id) {
    for (var i = 0; i < _entries.length; i++) {
      if (_entries[i].id == id) {
        return _entries[i];
      }
    }
    throw Exception("oh shit");
  }

  void modifyEntry(int id, Entry entry) async {
    for (var i = 0; i < _entries.length; i++) {
      if (_entries[i].id == id) {
        _entries[i] = entry;
        _db.modifyEntry(id, entry);
        notifyListeners();
      }
    }
  }
}
