import 'package:datapersistence/dbmanaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  runApp(ChangeNotifierProvider(
    create: (_) => DbModel(),
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    var manager = context.read<DbModel>();
    if (manager.entries.isEmpty) {
      manager.init();
    }
    return Scaffold(
      appBar: AppBar(title: const Text("Notes Demo")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              width: double.infinity,
              child: Text(
                "My Notes",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30),
              ),
            ),
            Column(children: context.watch<DbModel>().entries)
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.create),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Writing(),
              maintainState: false,
            ),
          );
        },
      ),
    );
  }
}

class Writing extends StatelessWidget {
  Writing({super.key});
  final titlecontroller = TextEditingController();
  final textcontroller = TextEditingController();
  void dispose() {
    titlecontroller.dispose();
    textcontroller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Write an Entry"),
      ),
      body: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              hintText: 'Title',
            ),
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
            controller: titlecontroller,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: TextField(
              decoration: const InputDecoration(
                  hintText: 'Text', border: OutlineInputBorder()),
              maxLines: 8,
              controller: textcontroller,
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.check),
        onPressed: () {
          context.read<DbModel>().addEntry(Entry(
                text: textcontroller.text,
                title: titlecontroller.text,
              ));
          context.read<DbModel>().init();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Row(
            children: [
              Icon(
                Icons.check,
                color: Colors.white,
              ),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text("Entry added successfully!"),
              )
            ],
          )));
          Navigator.pop(context);
        },
      ),
    );
  }
}

class ViewNote extends StatelessWidget {
  final String title;
  final String text;
  const ViewNote({super.key, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Read Note")),
      body: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Text(
              title,
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              text,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class EditNote extends StatelessWidget {
  final int id;
  const EditNote({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    var editedentry = context.read<DbModel>().getEntry(id);
    TextEditingController titlecontroller =
        TextEditingController(text: editedentry.title);
    TextEditingController textcontroller =
        TextEditingController(text: editedentry.text);
    void dispose() {
      titlecontroller.dispose();
      textcontroller.dispose();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Entry"),
      ),
      body: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              hintText: 'Title',
            ),
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
            controller: titlecontroller,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: TextFormField(
              decoration: const InputDecoration(
                  hintText: 'Text', border: OutlineInputBorder()),
              maxLines: 8,
              controller: textcontroller,
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.save),
        onPressed: () {
          context.read<DbModel>().modifyEntry(
                id,
                Entry(
                  id: id,
                  title: titlecontroller.text,
                  text: textcontroller.text,
                ),
              );
          context.read<DbModel>().init();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Row(
            children: [
              Icon(
                Icons.check,
                color: Colors.white,
              ),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text("Entry modified successfully!"),
              )
            ],
          )));
          dispose();
          Navigator.pop(context);
        },
      ),
    );
  }
}
