import 'dart:io';
import 'dart:ui';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:fliprkanban/firebase_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class TodoPage extends StatefulWidget {
  static const String id = 'todo';
  final String boardId, boardName;

  TodoPage({this.boardId, this.boardName});

  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final FirebaseHelper _firebaseHelper = FirebaseHelper();
  List cards = [];
  List children = [];
  List teamData = [];
  List cardDetails = [];

  @override
  void initState() {
    _firebaseHelper.getBoardData('boards/' + widget.boardId).then((result) {
      _getData();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.boardName),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: GestureDetector(
              child: Icon(
                Icons.face,
                size: 30.0,
              ),
              onTap: _showTeam,
            ),
          )
        ],
      ),
      body: _buildBody(),
    );
  }

  TextEditingController _teamTextController = TextEditingController();
  TextEditingController _cardTextController = TextEditingController();
  TextEditingController _taskTextController = TextEditingController();

  _getData() async {
    cards = _firebaseHelper.lists;
    children = _firebaseHelper.cards;
    teamData = _firebaseHelper.teamData;
    cardDetails = _firebaseHelper.cardDetails;
    setState(() {});
  }

  _showTeam() {
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
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Team Members",
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                        physics: BouncingScrollPhysics(),
                        itemCount: teamData.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            title: Text(teamData[index]),
                          );
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: InputDecoration(hintText: "Add Member Email"),
                      controller: _teamTextController,
                    ),
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  Center(
                    child: RaisedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _addTeamMember(_teamTextController.text.trim());
                      },
                      child: Text("Add Member"),
                    ),
                  )
                ],
              ),
            ),
          );
        });
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
                      "Add Card",
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: InputDecoration(hintText: "Card Title"),
                      controller: _cardTextController,
                    ),
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  Center(
                    child: RaisedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _addCard(_cardTextController.text.trim());
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

  _addTeamMember(String text) async {
    await _firebaseHelper.addTeamMember(
        'boards/' + widget.boardId, text, widget.boardId);
    teamData.add(text);
    _teamTextController.text = "";
    setState(() {});
  }

  _addCard(String text) async {
    await _firebaseHelper.addList('boards/' + widget.boardId, text);
    cards.add(text);
    children.add([]);
    _cardTextController.text = "";
    setState(() {});
  }

  _showAddCardTask(int index) {
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
                      "Add Card task",
                      style:
                          TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: InputDecoration(hintText: "Task Title"),
                      controller: _taskTextController,
                    ),
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  Center(
                    child: RaisedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _addCardTask(index, _taskTextController.text.trim());
                      },
                      child: Text("Add Task"),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  _addCardTask(int index, String text) async {
    await _firebaseHelper.addCard('boards/' + widget.boardId, index, text);
    children[index].add(text);
    _taskTextController.text = "";
    setState(() {});
  }

  _buildBody() {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemCount: cards.length + 1,
      itemBuilder: (context, index) {
        if (index == cards.length) {
          return _buildAddCardWidget(context);
        } else
          return _buildCard(context, index);
      },
    );
  }

  Widget _buildAddCardWidget(context) {
    return Column(
      children: <Widget>[
        InkWell(
          onTap: () {
            _showAddCard();
          },
          child: Container(
            width: 300.0,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    blurRadius: 8,
                    offset: Offset(2, 7),
                    color: Color.fromRGBO(127, 140, 141, 0.5),
                    spreadRadius: 2)
              ],
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.white,
            ),
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.add,
                ),
                SizedBox(
                  width: 16.0,
                ),
                Text("Add Card"),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddCardTaskWidget(context, index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: InkWell(
        onTap: () {
          _showAddCardTask(index);
        },
        child: Column(
          children: <Widget>[
            Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.add,
                  ),
                  SizedBox(
                    width: 16.0,
                  ),
                  Text(
                    "Add Card Task",
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, int index) {
    // return Container(
    //         width: 300.0,
    //   child: ,
    // );
    return Container(
      child: Stack(
        children: <Widget>[
          Container(
            width: 300.0,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    blurRadius: 8,
                    offset: Offset(0, 0),
                    color: Color.fromRGBO(127, 140, 141, 0.5),
                    spreadRadius: 1)
              ],
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.white,
            ),
            margin: const EdgeInsets.all(16.0),
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          cards[index],
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          physics: BouncingScrollPhysics(),
                          itemCount: children[index].length,
                          itemBuilder: (BuildContext context, int innerIndex) {
                            return Container(
                              margin: EdgeInsets.only(right: 15.0),
                              child: _buildCardTask(index, innerIndex),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                _buildAddCardTaskWidget(context, index),
              ],
            ),
          ),
          Positioned.fill(
            child: DragTarget<dynamic>(
              onWillAccept: (data) {
                print(data);
                return true;
              },
              onLeave: (data) {},
              onAccept: (data) {
                if (data['from'] == index) {
                  return;
                }
                children[data['from']].remove(data['string']);
                children[index].add(data['string']);
                print(data);
                setState(() {});
              },
              builder: (context, accept, reject) {
                print("--- > $accept");
                print(reject);
                return Container();
              },
            ),
          ),
        ],
      ),
    );
  }

  Container _buildCardTask(int index, int innerIndex) {
    return Container(
      width: 300.0,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Draggable<dynamic>(
        feedback: Material(
          color: Colors.transparent,
          elevation: 5.0,
          child: Container(
            width: 274.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              color: Colors.greenAccent,
            ),
            padding: const EdgeInsets.all(16.0),
            child: Text(children[index][innerIndex]),
          ),
        ),
        childWhenDragging: Container(),
        child: GestureDetector(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              color: Colors.greenAccent,
            ),
            padding: const EdgeInsets.all(16.0),
            child: Text(children[index][innerIndex]),
          ),
          onDoubleTap: () {
            print("hello");
            _showEdit(index, innerIndex);
          },
        ),
        data: {"from": index, "string": children[index][innerIndex]},
      ),
    );
  }

  _showEdit(int index, int innerIndex) {
    String _date;
    File _image;
    String _uploadedFileURL;
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return Dialog(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                "Card Details",
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image(
                      width: 120,
                      height: 120,
                      image: cardDetails[index][innerIndex]['image'] != null
                          ? NetworkImage(cardDetails[index][innerIndex]['image'])
                          : AssetImage(
                              "assets/logo_background.png",
                            ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await ImagePicker.pickImage(source: ImageSource.gallery)
                            .then((image) {
                          setState(() {
                            _image = image;
                          });
                        });
                        StorageReference storageReference = FirebaseStorage
                            .instance
                            .ref()
                            .child('images/${_image.path}');
                        StorageUploadTask uploadTask =
                            storageReference.putFile(_image);
                        await uploadTask.onComplete;
                        print('File Uploaded');
                        storageReference.getDownloadURL().then((fileURL) {
                          _firebaseHelper.addImage('boards/' + widget.boardId,
                              fileURL, index, innerIndex);
                        });
                      },
                      child: Icon(
                        Icons.attach_file,
                        size: 30.0,
                      ),
                    )
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (cardDetails[index][innerIndex]['image'] != null)
                    launch(cardDetails[index][innerIndex]['image']);
                  else
                    Toast.show("No image", context,
                        duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
                },
                child: Text(
                  "View Image",
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 18.0,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
                elevation: 4.0,
                onPressed: () {
                  DatePicker.showDateTimePicker(context,
                      theme: DatePickerTheme(
                        containerHeight: 210.0,
                      ),
                      showTitleActions: true,
                      minTime: DateTime(2000, 1, 1),
                      maxTime: DateTime(2022, 12, 31), onConfirm: (date) {
                    print(date.runtimeType);

                    _date = '${date.month} - ${date.day}';
                    setState(() {});
                  }, currentTime: DateTime.now(), locale: LocaleType.en);
                },
                child: Container(
                  alignment: Alignment.center,
                  height: 50.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.date_range,
                                  size: 18.0,
                                  color: Colors.teal,
                                ),
                                Text(
                                  " $_date",
                                  style: TextStyle(
                                      color: Colors.teal,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ));
        });
  }
}
