import 'package:flutter/material.dart';
import 'package:huawie_notepad_project/notes.dart';

int api = 13;
void main() async {
  // bo am projecta hamesh ka west git bakar benet bnwsa
  // git add .
  // git commit -m "a text"
  // git push origin HEAD:main
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'notePad Application',
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
