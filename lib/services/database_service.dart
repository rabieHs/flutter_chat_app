import 'package:chatify_app/models/chat_message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const String UserCollection = "Users";
const String ChatCollection = "Chats";
const String MessagesCollection = "messages";

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  DatabaseService() {}

  Future<DocumentSnapshot> getUser(String _uid) {
    return _db.collection(UserCollection).doc(_uid).get();
  }

  Future<void> createUser(
      String _uid, String _email, String _name, String _imageUrl) async {
    try {
      await _db.collection(UserCollection).doc(_uid).set({
        "email": _email,
        "image": _imageUrl,
        "name": _name,
        "last_active": DateTime.now().toUtc(),
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateUserLastSeenTime(String _uid) async {
    try {
      await _db.collection(UserCollection).doc(_uid).update(
        {
          "last_active": DateTime.now().toUtc(),
        },
      );
    } catch (e) {
      print(e);
    }
  }

  Stream<QuerySnapshot> getChatsForUser(String _uid) {
    return _db
        .collection(ChatCollection)
        .where('members', arrayContains: _uid)
        .snapshots();
  }

  Future<QuerySnapshot> getLastMessageForChat(String _chatID) {
    return _db
        .collection(ChatCollection)
        .doc(_chatID)
        .collection(MessagesCollection)
        .orderBy("sent_time", descending: true)
        .limit(1)
        .get();
  }

  Stream<QuerySnapshot> streamMessagesForChat(String _chatId) {
    return _db
        .collection(ChatCollection)
        .doc(_chatId)
        .collection(MessagesCollection)
        .orderBy("sent_time", descending: false)
        .snapshots();
  }

  Future<void> deleteChat(String _chatId) async {
    try {
      await _db.collection(ChatCollection).doc(_chatId).delete();
    } catch (e) {
      print(e);
    }
  }
  Future<DocumentReference?> createChat(Map<String , dynamic> _data)async{
    try {
      DocumentReference _chat = await _db.collection(ChatCollection).add(_data);
      return _chat;
    } catch (e) {
      print(e);
    }
  }
  Future<void> addMessagtoChat(String _chatId, ChatMessage _message) async {
    try {
      _db
          .collection(ChatCollection)
          .doc(_chatId)
          .collection(MessagesCollection)
          .add(
            _message.toJson(),
          );
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateChatData(
      String _chatId, Map<String, dynamic> _data) async {
    try {
      _db.collection(ChatCollection).doc(_chatId).update(_data);
    } catch (e) {
      print(e);
    }
  }
  Future<QuerySnapshot> getUsers({String? name} ){
    Query _query = _db.collection(UserCollection);
    if(name != null){
      _query = _query.where('name',isGreaterThanOrEqualTo: name).where('name',isLessThanOrEqualTo: name+"z");
    }
    return _query.get();
  }
}
