import 'dart:ffi';
import 'dart:io';

import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:huawie_notepad_project/main.dart';
import 'package:huawie_notepad_project/notes.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as co;

class AddNotes extends StatefulWidget {
  const AddNotes({super.key});

  @override
  State<AddNotes> createState() => _AddNotesState();
}

class _AddNotesState extends State<AddNotes> {
  @override
  Future<void> insertData() async {
    try {
      if ((_titleController.text.isNotEmpty &&
              _contextController.text.isNotEmpty) ||
          _titleController.text.isNotEmpty ||
          _contextController.text.isNotEmpty) {
        final data = await http.post(Uri.parse(url(route: 'insert')), body: {
          'Title': _titleController.text,
          'Content': _contextController.text,
        });
      } else {}
    } catch (e) {
      print(e.toString());
    }
  }

  bool _visibilityIcons = true;

  double _opacity = 1;
  Color OpacityIcons(_opacity) {
    return Colors.grey.withOpacity(_opacity);
  }

  bool _change_bottm_icons = true;

  FocusNode _focusNode = FocusNode();
  int _currentIndex_NavigationBar = 0;
  final _titleController = TextEditingController();
  final _contextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  Widget build(BuildContext context) {
    MediaQueryData _mediaQueryData = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 255, 255, 1),
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            )),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Visibility(
            child: IconButton(
                onPressed: () async {},
                icon: Icon(Icons.undo, color: Colors.black)),
            visible: _visibilityIcons,
          ),
          Visibility(
            child: IconButton(
                onPressed: () {}, icon: Icon(Icons.redo, color: Colors.black)),
            visible: _visibilityIcons,
          ),
          Visibility(
              child: IconButton(
                  onPressed: () async {
                    _change_bottm_icons = false;
                    await insertData();
                    // Dismiss the keyboard
                    FocusScope.of(context).unfocus();
                    _visibilityIcons = !_visibilityIcons;
                  },
                  icon: Icon(Icons.check, color: Colors.black)),
              visible: _visibilityIcons),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: TextFormField(
                cursorHeight: 34,
                style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
                decoration: const InputDecoration(
                    enabledBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    hintText: 'Title',
                    hintStyle: TextStyle(
                        fontSize: 30,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500),
                    border: InputBorder.none),
                controller: _titleController,
                onTap: () {
                  setState(() {
                    _change_bottm_icons = true;
                    _visibilityIcons = true;
                    _opacity = 0.3;
                  });
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Row(
                children: [Text('today 3:10 AM'), Text(' No category ^')],
              ),
            ),
            const SizedBox(height: 10),
            // bo ya flexible da anden bo awae katek bo nmona
            // widgete ke treshman dana la xwar flxible widget
            // error man nadate je nosrawakane xoe katawa asan
            Flexible(
                child: SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: TextFormField(
                focusNode: _focusNode,
                style: TextStyle(fontSize: 22, color: Colors.black),
                maxLines: null,
                expands: true,
                onTap: () {
                  // Select the text field when it is clicked.
                  setState(() {
                    _change_bottm_icons = true;
                    _visibilityIcons = true;
                    _opacity = 1;
                  });
                },
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(borderSide: BorderSide.none),
                ),
                controller: _contextController,
              ),
            )),
          ],
        ),
      ),
      // bottom page
      bottomNavigationBar: _change_bottm_icons
          ? Padding(
              padding: _mediaQueryData.viewInsets,
              child: Container(
                width: 50,
                height: 70,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Opacity(
                          opacity: _opacity,
                          child: Icon(
                            Icons.check_circle,
                            size: 25,
                          ),
                        ),
                        Opacity(
                          opacity: _opacity,
                          child: Text(
                            'Cheaklist',
                          ),
                        )
                      ],
                    ),
                    Column(
                      children: [
                        Opacity(
                          opacity: _opacity,
                          child: Icon(
                            Icons.text_format,
                            size: 25,
                          ),
                        ),
                        Opacity(
                          opacity: _opacity,
                          child: Text(
                            'Style',
                          ),
                        )
                      ],
                    ),
                    Column(
                      children: [
                        Opacity(
                            opacity: _opacity,
                            child: Icon(Icons.image, size: 25)),
                        Opacity(
                          opacity: _opacity,
                          child: Text(
                            'Gallery',
                          ),
                        )
                      ],
                    ),
                    Column(
                      children: [
                        Opacity(
                          opacity: _opacity,
                          child: Icon(
                            Icons.draw,
                            size: 25,
                          ),
                        ),
                        Opacity(
                          opacity: _opacity,
                          child: Text(
                            'HandWrite',
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            )
          : Padding(
              padding: _mediaQueryData.viewInsets,
              child: Container(
                width: 50,
                height: 70,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [Icon(Icons.share, size: 25), Text('Share')],
                    ),
                    Column(
                      children: [
                        Icon(Icons.favorite, size: 25),
                        Text('Favorite')
                      ],
                    ),
                    Column(
                      children: [Icon(Icons.delete, size: 25), Text('Delete')],
                    ),
                    Column(
                      children: [Icon(Icons.more_vert, size: 25), Text('More')],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
