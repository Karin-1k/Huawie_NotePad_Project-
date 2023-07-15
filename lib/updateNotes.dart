import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:huawie_notepad_project/main.dart';
import 'package:http/http.dart' as http;
import 'package:huawie_notepad_project/notes.dart';
import 'package:share_plus/share_plus.dart';

class UpdateNotes extends StatefulWidget {
  const UpdateNotes(
      {super.key, required this.title, required this.body, required this.id});

  final String title;
  final String body;
  final int id;
  @override
  State<UpdateNotes> createState() => _UpdateNotesState();
}

class _UpdateNotesState extends State<UpdateNotes> {
// this is update method
  Future<void> updateData() async {
    try {
      final data = await http.put(Uri.parse(url(route: 'update')), body: {
        'id': '${_id}',
        'Title': _titleController,
        'Content': _contextController,
      });
    } catch (e) {
      print(e.toString());
      print('kaka naekam xo bazora ');
    }
  }

// deleting notes from DB
  Future<void> deleteNotes() async {
    try {
      final data = await http
          .delete(Uri.parse(url(route: 'delete')), body: {'id': '$_id'});
    } catch (e) {
      print('the err is in deleting notes');
      print(e);
    }
  }

  String? _titleController;
  String? _contextController;
  int? _id;
  bool _visibilityIcons = true;
  double _opacity = 1;
  Color OpacityIcons(_opacity) {
    return Colors.grey.withOpacity(_opacity);
  }

  bool _change_bottm_icons = true;
  FocusNode _focusNode = FocusNode();
  bool _isDescardChanged = false;
  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    _titleController = widget.title;
    _contextController = widget.body;
    _id = widget.id;
  }

  Widget build(BuildContext context) {
    MediaQueryData _mediaQueryData = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 255, 255, 1),
      appBar: AppBar(
        leading: IconButton(
            onPressed: () async {
              if (_titleController!.isEmpty && _contextController!.isEmpty) {
                await deleteNotes();
                Navigator.pop(context);
              } else {
                if (_isDescardChanged) {
                  Navigator.pop(context);
                } else {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            actions: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Color.fromARGB(
                                                      255, 168, 35, 7))),
                                      onPressed: () async {
                                        // Dismiss the keyboard
                                        FocusScope.of(context).unfocus();
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      },
                                      child: Text('Cancel')),
                                  ElevatedButton(
                                    onPressed: () async {
                                      // Dismiss the keyboard
                                      FocusScope.of(context).unfocus();
                                      await updateData();
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      '    ok    ',
                                    ),
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Color.fromARGB(
                                                    255, 31, 71, 232))),
                                  ),
                                ],
                              )
                            ],
                            title: Text('  Save Changed?'),
                            contentPadding: EdgeInsets.all(20.0),
                          ));
                }
              }
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
                icon: Icon(Icons.undo_sharp, color: Colors.black87)),
            visible: _visibilityIcons,
          ),
          Visibility(
            child: IconButton(
                onPressed: () {},
                icon: Icon(Icons.redo_outlined, color: Colors.black87)),
            visible: _visibilityIcons,
          ),
          Visibility(
              child: IconButton(
                  onPressed: () async {
                    if (_titleController!.isEmpty &&
                        _contextController!.isEmpty) {
                      await deleteNotes();
                      Navigator.pop(context);
                    } else {
                      setState(() => _isDescardChanged = true);

                      _change_bottm_icons = false;
                      // Dismiss the keyboard
                      FocusScope.of(context).unfocus();
                      await updateData();

                      _visibilityIcons = !_visibilityIcons;
                    }
                  },
                  icon: Icon(Icons.check, color: Colors.black87)),
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
                initialValue: widget.title,
                onTap: () {
                  setState(() {
                    _change_bottm_icons = true;
                    _visibilityIcons = true;
                    _opacity = 0.3;
                  });
                },
                onChanged: (value) => setState(() {
                  _titleController = value;
                }),
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
                // initialValue: 'karin',
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
                initialValue: widget.body,
                onChanged: (value) => setState(() {
                  _contextController = value;
                }),
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
                            Icons.check_circle_outline,
                            size: 25,
                          ),
                        ),
                        Opacity(
                          opacity: _opacity,
                          child: Text('Cheaklist'),
                        )
                      ],
                    ),
                    Column(
                      children: [
                        Opacity(
                          opacity: _opacity,
                          child: Icon(
                            Icons.text_format_outlined,
                            size: 25,
                          ),
                        ),
                        Opacity(
                          opacity: _opacity,
                          child: Text('Style'),
                        )
                      ],
                    ),
                    Column(
                      children: [
                        Opacity(
                            opacity: _opacity,
                            child: Icon(Icons.image_outlined, size: 25)),
                        Opacity(
                          opacity: _opacity,
                          child: Text('Gallery'),
                        )
                      ],
                    ),
                    Column(
                      children: [
                        Opacity(
                          opacity: _opacity,
                          child: Icon(
                            Icons.draw_outlined,
                            size: 25,
                          ),
                        ),
                        Opacity(
                          opacity: _opacity,
                          child: Text('HandWrite'),
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
                    InkWell(
                      child: const Column(
                        children: [
                          Icon(Icons.share_outlined, size: 25),
                          Text('Share')
                        ],
                      ),
                      onTap: () async {
                        if (_titleController!.isNotEmpty ||
                            _contextController!.isNotEmpty ||
                            (_titleController!.isNotEmpty &&
                                _contextController!.isNotEmpty)) {
                          try {
                            await Share.share(
                                '${_titleController}\n${_contextController}');
                          } catch (e) {
                            print('keshaka la share button daya!');
                            print(e.toString());
                          }
                        }
                      },
                    ),
                    const Column(
                      children: [
                        Icon(Icons.favorite_outline, size: 25),
                        Text('Favorite')
                      ],
                    ),
                    InkWell(
                      child: const Column(
                        children: [
                          Icon(
                            Icons.delete_outlined,
                            size: 25,
                            color: Color.fromARGB(255, 168, 35, 7),
                          ),
                          Text(
                            'Delete',
                            style: TextStyle(
                                color: Color.fromARGB(255, 168, 35, 7)),
                          )
                        ],
                      ),
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  actions: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        ElevatedButton(
                                            style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        Color.fromARGB(
                                                            255, 31, 71, 232))),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text('Cancel ')),
                                        ElevatedButton(
                                          onPressed: () async {
                                            await deleteNotes();
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            ' delete  ',
                                          ),
                                          style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      Color.fromARGB(
                                                          255, 168, 35, 7))),
                                        ),
                                      ],
                                    )
                                  ],
                                  title: Text(' you want to delete it?'),
                                  contentPadding: EdgeInsets.all(20.0),
                                ));
                      },
                    ),
                    const Column(
                      children: [Icon(Icons.more_vert, size: 25), Text('More')],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
