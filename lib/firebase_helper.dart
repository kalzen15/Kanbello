import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseHelper {
  DocumentSnapshot data;
  List _boardData,
      _lists = [],
      _cards = [],
      _cardDetails = [],
      _teamData,
      _boards;

  Future<void> getBoardData(String boardPath) async {
    DocumentReference reference = Firestore.instance.document(boardPath);
    data = await reference.get();
    _boardData = data.data['lists'];
    _teamData = data.data['users'];
    getLists();
    getCards();
  }

  getLists() {
    _boardData.forEach((element) {
      _lists.add(element['name']);
    });
  }

  getCards() {
    _boardData.forEach((element) {
      _cardDetails.add(element['cards']);
    });
    List _cardNames = [];
    for (int i = 0; i < _cardDetails.length; i++) {
      for (int j = 0; j < _cardDetails[i].length; j++) {
        _cardNames.add(_cardDetails[i][j]['cardName']);
      }
      _cards.add(_cardNames);
      _cardNames = [];
    }
  }

  List get cardDetails {
    return _cardDetails;
  }

  List get teamData {
    return _teamData;
  }

  List get lists {
    return _lists;
  }

  List get cards {
    return _cards;
  }

  Future<void> addCard(String boardPath, int index, String cardName) async {
    DocumentReference reference = Firestore.instance.document(boardPath);
    Map<String, dynamic> card = {'cardName': cardName, 'image': null,'timestamp':null};
    List<Map<String, dynamic>> array = [];
    _boardData[index]['cards'].forEach((element) {
      Map<String, dynamic> cards = element.cast<String, dynamic>();
      array.add(cards);
    });
    array.add(card);
    var boardData = _boardData;
    boardData[index]['cards'] = array;
    await reference.updateData({
      'lists': boardData,
    });
    _boardData = boardData;
  }

  Future<void> addList(String boardPath, String listName) async {
    DocumentReference reference = Firestore.instance.document(boardPath);
    Map<String, dynamic> list = {'cards': [], 'name': listName};
    List<Map<String, dynamic>> array = [];
    _boardData.forEach((element) {
      Map<String, dynamic> lists = element.cast<String, dynamic>();
      array.add(lists);
    });
    array.add(list);
    var boardData = array;
    await reference.updateData({
      'lists': boardData,
    });
    _boardData = boardData;
  }

  addTeamMember(String boardPath, String email, String boardId) async {
    DocumentReference reference = Firestore.instance.document(boardPath);
    var users = new List<String>.from(_teamData);
    users.add(email);
    await reference.updateData({'users': users});
    _teamData = users;
    DocumentReference documentReference =
        Firestore.instance.document('users/' + email);
    var data = await documentReference.get();
    _boards = data.data['boards'];
    var boards = new List<String>.from(_boards);
    boards.add(boardId);
    await documentReference.updateData({
      'boards': boards,
    });
    _boards = boards;
  }

  addImage(String boardPath, String url, int index, int innerIndex) async {
    DocumentReference reference = Firestore.instance.document(boardPath);
    cardDetails[index][innerIndex]['image'] = url;
    var boardData = _boardData;
    boardData[index]['cards'][innerIndex] = cardDetails[index][innerIndex];
    await reference.updateData({
      'lists': boardData,
    });
    _boardData = boardData;
  }
}
