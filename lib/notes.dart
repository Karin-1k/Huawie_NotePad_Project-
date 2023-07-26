import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:huawie_notepad_project/addNotes.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:huawie_notepad_project/main.dart';
import 'package:huawie_notepad_project/updateNotes.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

List<dynamic> data1 = [];

class Notes extends StatefulWidget {
  const Notes({super.key});

  @override
  State<Notes> createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  late IO.Socket socket;
  int length_notes = 0;
  int _currentIndex_NavigationBar = 0;

  //geting data method from DB
  Future<void> getNotes() async {
    try {
      final response = await http.get(Uri.parse(url(route: 'fetch')));

      if (response.statusCode == 200) {
        final data = convert.json.decode(response.body);

        setState(() {
          data1 = List.from(data);
          _searchList = data1;

          length_notes = data1.length;
        });
      } else {
        print('the data could not get correctly ${response.statusCode}');
      }
    } catch (e) {
      print("data got err during fetching :${e}");
    }
  }

  late int _indexLastNote;
  late int _individualIndex;
  List<dynamic> _searchList = [];
  @override
  void initState() {
    super.initState();
    // FocusScope.of(context).unfocus();

    try {
      getNotes();
      socket = IO.io('http://192.168.33.$api:5000', <String, dynamic>{
        'transports': ['websocket']
      });
// listinging for new notes
      socket.on(
          'new-note',
          (data) => {
                setState(() {
                  data1.add(data);
                  length_notes = data1.length;
                  _indexLastNote = data1.indexOf(data);
                  _individualIndex = _indexLastNote;
                  print('this is new note datas: $data');
                }),
                print(data1),
              });

      //listining for update last note
      socket.on(
          'update_lastNote',
          (data) => {
                setState(() {
                  data1[_indexLastNote] = data;
                })
              });

      //listining for update all note
      socket.on(
          'update',
          (data) => {
                setState(() {
                  data1[_individualIndex] = data;
                })
              });

      //  deleting notes
      socket.on(
          'delete',
          (data) => {
                setState(() {
                  data1.removeAt(_individualIndex);
                  length_notes = data1.length;
                })
              });
    } catch (e) {
      print(e);
    }
  }

// searching for notes
  void searchNote(String query) {
    final suggestions = _searchList.where((note) {
      final title = note['Title'];
      final content = note['Content'];
      final input = query.toLowerCase();
      return title.toString().toLowerCase().contains(input) ||
          content.toString().toLowerCase().contains(input);
    });
    print(suggestions);
    setState(() => data1 = suggestions.toList());
  }

// deleting notes from DB
  Future<void> deleteNotes(int ID) async {
    try {
      final data = await http
          .delete(Uri.parse(url(route: 'delete')), body: {'id': '$ID'});
    } catch (e) {
      print('the err is in deleting notes');
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 241, 240, 240),
        appBar: kappbar,
        body: Padding(
          padding: const EdgeInsets.only(left: 11, right: 11),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                child: FilterNotes,
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text('${length_notes} note(s)')),
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Container(
                  width: 360,
                  height: 40,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20)),
                  child: TextField(
                    enabled: true,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.black54,
                      ),
                      hintText: 'Search notes',
                      enabledBorder: InputBorder.none,
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                    ),
                    onChanged: searchNote,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                flex: 1,
                child: ListView.builder(
                  itemCount: data1.length,
                  itemBuilder: (context, index) => Container(
                    height: 95,
                    width: 380,
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: InkWell(
                        child: Padding(
                          padding: EdgeInsets.only(left: 8, top: 12),
                          child: ListTile(
                            title: Text(
                              data1[index]['Title'],
                              style: TextStyle(
                                  fontSize: 24,
                                  overflow: TextOverflow.ellipsis,
                                  letterSpacing: 0.3),
                            ),
                            subtitle: Text(
                              data1[index]['Content'],
                              style: TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  letterSpacing: 0.3,
                                  fontSize: 20),
                              maxLines: 1,
                            ),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _individualIndex = index;
                            print('individual id is :$_individualIndex');
                          });
                          dynamic id = data1[index]['id'];
                          print('the id for entering is :$id');
                          if (id.runtimeType == int) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => UpdateNotes(
                                          title: data1[index]['Title'],
                                          body: data1[index]['Content'],
                                          id: id,
                                        )));
                          } else {
                            print('the whole datas in _data List $data1');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UpdateNotes(
                                  title: data1[index]['Title'],
                                  body: data1[index]['Content'],
                                  id: int.parse(id),
                                ),
                              ),
                            );
                          }
                        },
                        onLongPress: () async {
                          setState(() {
                            _individualIndex = index;
                            print('individual id is :$_individualIndex');
                          });
                          dynamic id = data1[index]['id'];

                          if (id.runtimeType == int) {
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
                                                        MaterialStateProperty
                                                            .all(Color.fromARGB(
                                                                255,
                                                                31,
                                                                71,
                                                                232))),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text('Cancel  ')),
                                            ElevatedButton(
                                              onPressed: () async {
                                                await deleteNotes(id);
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                ' delete  ',
                                              ),
                                              style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all(
                                                          Color.fromARGB(255,
                                                              168, 35, 7))),
                                            ),
                                          ],
                                        )
                                      ],
                                      title: Text(' you want to delete it?'),
                                      contentPadding: EdgeInsets.all(20.0),
                                    ));
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
                                                        MaterialStateProperty
                                                            .all(Color.fromARGB(
                                                                255,
                                                                31,
                                                                71,
                                                                232))),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text('Cancel  ')),
                                            ElevatedButton(
                                              onPressed: () async {
                                                await deleteNotes(
                                                    int.parse(id));
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                ' delete  ',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all(
                                                          Color.fromARGB(255,
                                                              168, 35, 7))),
                                            ),
                                          ],
                                        )
                                      ],
                                      title: Text(' you want to delete it?'),
                                      contentPadding: EdgeInsets.all(20.0),
                                    ));
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Color.fromARGB(255, 31, 71, 232),
          selectedIconTheme: IconThemeData(
            color: Color.fromARGB(255, 31, 71, 232),
          ),
          currentIndex: _currentIndex_NavigationBar,
          onTap: (newIndex) {
            setState(() {
              _currentIndex_NavigationBar = newIndex;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.notes),
              label: 'Notes',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.check,
              ),
              label: 'To-dos',
            ),
          ],
        ),
        floatingActionButton: floatingAB(),
      ),
    );
  }
}

// _________________________________________

AppBar kappbar = AppBar(
  backgroundColor: Color.fromARGB(255, 241, 240, 240),
  elevation: 0.0,
  actions: [
    Padding(
      padding: const EdgeInsets.only(right: 25, top: 15),
      child: InkWell(
        onTap: () {},
        child: const Icon(
          Icons.more_vert,
          size: 40,
          color: Colors.black54,
        ),
      ),
    )
  ],
);

class floatingAB extends StatefulWidget {
  const floatingAB({super.key});

  @override
  State<floatingAB> createState() => _floatingABState();
}

class _floatingABState extends State<floatingAB> {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: ((context) => const AddNotes(
                  title: '',
                  body: '',
                  id: 0,
                )),
          ),
        );
      },
      child: Icon(Icons.add, size: 40),
      backgroundColor: Color.fromARGB(255, 31, 71, 232),
    );
  }
}

Widget FilterNotes = Column(
  children: [
    FocusedMenuHolder(
      bottomOffsetHeight: 400.0,
      menuItems: [
        FocusedMenuItem(
          title: const Text('Favourite'),
          trailingIcon: Icon(Icons.favorite_border),
          onPressed: () {},
        ),
        FocusedMenuItem(
          title: const Text('Bookmark'),
          trailingIcon: Icon(Icons.bookmark_border),
          onPressed: () {},
        ),
        FocusedMenuItem(
          title: const Text('My favourites'),
          trailingIcon: Icon(Icons.share_outlined),
          onPressed: () {},
        ),
        FocusedMenuItem(
          title: const Text(
            'Recently Delete',
            style: TextStyle(color: Colors.white),
          ),
          trailingIcon: const Icon(
            Icons.delete_forever,
            color: Colors.white,
          ),
          backgroundColor: Colors.red,
          onPressed: () {},
        ),
      ],
      blurSize: 1,
      blurBackgroundColor: Colors.transparent,
      //  menuWidth: MediaQuery.of(context).size.width * 0.5,
      menuWidth: 370,

      menuItemExtent: 50,
      duration: Duration(seconds: 0),
      animateMenuItems: false,
      menuOffset: 12,
      openWithTap: true,
      onPressed: () {},
      child: Container(
        decoration: BoxDecoration(
          //  border: Border.all(color: Colors.red),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: 8),
          child: const Text('All notes',
              style: TextStyle(
                  fontSize: 30,
                  color: Colors.black,
                  fontWeight: FontWeight.w500)),
        ),
      ),
    ),
  ],
);
