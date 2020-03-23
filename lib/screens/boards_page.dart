import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fliprkanban/firebase_helper.dart';
import 'package:fliprkanban/screens/todo_page.dart';
import 'package:fliprkanban/screens/welcome_screen.dart';

import 'package:flutter/material.dart';

class BoardsPage extends StatefulWidget {
  static const String id = 'boards';

  @override
  _BoardsPageState createState() => _BoardsPageState();
}

class _BoardsPageState extends State<BoardsPage> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser _user;
  String email;
  FirebaseHelper _firebaseHelper = FirebaseHelper();
  List _boards = [];
  List _boardsNames = [];
  TextEditingController _boardTextController = TextEditingController();
  DocumentReference token;

  _signOut() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, WelcomeScreen.id);
  }

  Future<void> currentUser() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    setState(() {
      _user = user;
    });
    email = _user.email;
    await getBoardsId(_user);
  }

  getBoardsId(FirebaseUser _user) async {
    DocumentReference reference =
        Firestore.instance.document('users/' + _user.email);
    var boards = await reference.get();
    setState(() {
      _boards = boards.data['boards'];
    });
    print(_boards);
    await getBoardNames();
  }

  getBoardNames() async {
    await _boards.forEach((element) async {
      DocumentReference reference =
          Firestore.instance.document('boards/' + element);

      var boards = await reference.get();
      setState(() {
        _boardsNames.add(boards.data['boardName']);
      });
    });
  }

  addBoard(String userPath, String boardName) async {
    CollectionReference collectionReference =
        Firestore.instance.collection('boards');
    token = await collectionReference.add({
      'boardName': boardName,
      'lists': [],
      'users': [email]
    });
    DocumentReference reference = Firestore.instance.document(userPath);
    var boards = new List<String>.from(_boards);
    boards.add(token.documentID);
    await reference.updateData({
      'boards': boards,
    });
    _boards = boards;
  }

  @override
  void initState() {
    currentUser();
    super.initState();
  }

  _showAddCard() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 15,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Add Board",
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: InputDecoration(hintText: "Board Title"),
                      controller: _boardTextController,
                    ),
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  Center(
                    child: RaisedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _addBoard(_boardTextController.text.trim());
                      },
                      child: Text("Add Card"),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  _addBoard(String text) async {
    await addBoard('users/' + _user.email, text);
    _boardsNames.add(text);
    _boardTextController.text = "";
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddCard,
          child: Icon(
            Icons.add,
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(color: Colors.greenAccent, boxShadow: [
                BoxShadow(color: Colors.black38, offset: Offset(0, 3), blurRadius: 3.0)
              ]),
              padding: EdgeInsets.only(right: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Image(
                        image: AssetImage("assets/no_task.png"),
                        width: 70,
                        height: 70,
                      ),
                      Text(
                        "Kanbello",
                        style: TextStyle(
                            fontSize: 23.0, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  GestureDetector(
                      onTap: _signOut,
                      child: Icon(
                        Icons.exit_to_app,
                        size: 30,
                      ))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25.0, top: 20.0),
              child: Text(
                "Boards",
                style: TextStyle(
                    fontSize: 29.0,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _boardsNames.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    child: Card(
                      elevation: 5.0,
                      margin: EdgeInsets.symmetric(
                          horizontal: 25.0, vertical: 10.0),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.line_style,
                              size: 30.0,
                              color: Colors.black38,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              _boardsNames[index],
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TodoPage(
                          boardId: _boards[index],
                          boardName: _boardsNames[index],
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
