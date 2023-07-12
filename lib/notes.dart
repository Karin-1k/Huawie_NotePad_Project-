
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:huawie_notepad_project/addNotes.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:huawie_notepad_project/main.dart';
import 'package:huawie_notepad_project/updateNotes.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class Notes extends StatefulWidget {
  const Notes({super.key});

  @override
  State<Notes> createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  late IO.Socket socket;
  List<dynamic> _data = [];
  int length_notes = 0;
  int _currentIndex_NavigationBar = 0;

  //geting data method from DB
  Future<void> getNotes() async {
    try {
      final response = await http.get(Uri.parse(url(route: 'fetch')));

      if (response.statusCode == 200) {
        final data = convert.json.decode(response.body);

        setState(() {
          _data = List.from(data);
          length_notes = _data.length;
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
                  _data.add(data);
                  length_notes = _data.length;
                  _indexLastNote = _data.indexOf(data);
                  print('this is new note datas: $data');
                }),
                print(_data),
              });

      //listining for update last note
      socket.on(
          'update_lastNote',
          (data) => {
                setState(() {
                  _data[_indexLastNote] = data;
                })
              });

      //listining for update all note
      socket.on(
          'update',
          (data) => {
                setState(() {
                  _data[_individualIndex] = data;
                })
              });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
                  child: Text('$length_notes note(s)')),
              const SizedBox(
                height: 30,
              ),
              ksearch,
              const SizedBox(height: 12),
              Expanded(
                flex: 1,
                child: ListView.builder(
                  itemCount: _data.length,
                  itemBuilder: (context, index) => Container(
                    height: 80,
                    width: 380,
                    child: Card(
                      color: Colors.amber,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: InkWell(
                        child: ListTile(
                          title: Text(_data[index]['Title']),
                          subtitle: Text(_data[index]['Content']),
                        ),
                        onTap: () {
                          setState(() {
                            _individualIndex = index;
                            print('individual id is :$_individualIndex');
                          });
dynamic id   =_data[index]['id'];
print(id);
if (id.runtimeType == int) {
  
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UpdateNotes(
                                        title: _data[index]['Title'],
                                        body: _data[index]['Content'],
                                        id: id,
                                      )));
} else {
       Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UpdateNotes(
                                        title: _data[index]['Title'],
                                        body: _data[index]['Content'],
                                        id:int.parse(id),
                                      )));
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
          selectedItemColor: Colors.blue,
          selectedIconTheme: IconThemeData(color: Colors.blue),
          currentIndex: _currentIndex_NavigationBar,
          onTap: (newIndex) {
            setState(() {
              _currentIndex_NavigationBar = newIndex;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.notes), label: 'Notes'),
            BottomNavigationBarItem(icon: Icon(Icons.check), label: 'To-dos'),
          ],
        ),
        floatingActionButton: floatingAB(),
      ),
    );
  }
}

// _________________________________________

Padding ksearch = Padding(
  padding: const EdgeInsets.only(left: 5),
  child: Container(
    width: 360,
    height: 40,
    decoration: BoxDecoration(
        color: Colors.amber, borderRadius: BorderRadius.circular(20)),
    child: const TextField(
      enabled: true,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.search,
          color: Colors.black,
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
    ),
  ),
);

AppBar kappbar = AppBar(
  backgroundColor: Colors.white,
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
      child: Icon(Icons.add, size: 35),
      backgroundColor: Colors.blue,
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
          title: const Text('Share'),
          trailingIcon: Icon(Icons.share),
          onPressed: () {},
        ),
        FocusedMenuItem(
          title: const Text(
            'Delete',
            style: TextStyle(color: Colors.white),
          ),
          trailingIcon: const Icon(
            Icons.delete_forever,
            color: Colors.white,
          ),
          backgroundColor: Colors.red,
          onPressed: () {},
        ),
        FocusedMenuItem(
          title: const Text(
              '______________________________________________________'),
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
        child: const Text('All notes^',
            style: TextStyle(fontSize: 30, color: Colors.black)),
      ),
    ),
  ],
);
