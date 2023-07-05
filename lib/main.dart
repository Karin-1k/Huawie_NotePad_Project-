import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:huawie_notepad_project/addNotes.dart';
import 'package:huawie_notepad_project/notes.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

int api = 6;
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Notes());
  }
}

// url method
String url({required String route}) {
  return 'http://192.168.33.$api:5000/api/$route';
}

class Instans extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class Note {
  final String title;
  final String content;

  Note({required this.title, required this.content});
}

class _MyAppState extends State<Instans> {
  late IO.Socket socket;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  List<Note> notes = [];

  @override
  void initState() {
    super.initState();
    socket = IO.io('http://192.168.33.4:5000', <String, dynamic>{
      'transports': ['websocket'],
    });

    socket.on('new-note', (data) {
      setState(() {
        notes.add(Note(
          title: data['Title'],
          content: data['Content'],
        ));
      });
    });

    // socket.on('notes-updated', (data) {
    //   setState(() {
    //     notes.clear();
    //     for (var noteData in data) {
    //       notes.add(Note(
    //         title: noteData['Title'],
    //         content: noteData['Content'],
    //       ));
    //     }
    //   });
    // });
  }

  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
  }

  // Future<void> fetchData() async {
  //   final url = Uri.parse('http://192.168.33.4:5000/api/fetch');
  //   final response = await http.get(url);

  //   if (response.statusCode == 200) {
  //     setState(() {
  //       notes.clear();
  //       final List<dynamic> data = jsonDecode(response.body);
  //       for (var noteData in data) {
  //         notes.add(Note(
  //           title: noteData['Title'],
  //           content: noteData['Content'],
  //         ));
  //       }
  //     });
  //   } else {
  //     print('Failed to fetch data: ${response.statusCode}');
  //   }
  // }

  // Future<void> insertData() async {
  //   final url = Uri.parse('http://192.168.33.4:5000/api/insert');
  //   final response = await http.post(
  //     url,
  //     body: {
  //       'Title': _titleController.text,
  //       'Content': _contentController.text,
  //     },
  //   );

  //   if (response.statusCode == 200) {
  //     _titleController.clear();
  //     _contentController.clear();
  //   } else {
  //     print('Failed to insert data: ${response.statusCode}');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Socket.IO Flutter Demo'),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return ListTile(
                    title: Text(note.title),
                    subtitle: Text(note.content),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(hintText: 'Title'),
                  ),
                  TextField(
                    controller: _contentController,
                    decoration: InputDecoration(hintText: 'Content'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    // insertData,
                    child: Text('Insert Note'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    //  fetchData,
                    child: Text('Fetch Data'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

