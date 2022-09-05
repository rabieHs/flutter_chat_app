import 'dart:async';
import 'package:chatify_app/models/chat_message_model.dart';
import 'package:chatify_app/models/chat_user.dart';
import 'package:chatify_app/models/chats_model.dart';
import 'package:chatify_app/providers/authentication_provider.dart';
import 'package:chatify_app/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ChatPageProvider extends ChangeNotifier {
  AuthenticationProvider _auth;
  late DatabaseService _db;
  List<ChatModel>? chats;
  late StreamSubscription _chatsStream;
  ChatPageProvider(this._auth) {
    _db = GetIt.instance.get<DatabaseService>();
    getChats();
  }
  @override
  void dispose() {
    _chatsStream.cancel();
    super.dispose();
  }

  void getChats() async {
    try {
      _chatsStream =
          _db.getChatsForUser(_auth.user.uid).listen((_snapshot) async {
        chats = await Future.wait(
          _snapshot.docs.map(
            (_d) async {
              Map<String, dynamic> _chatData =
                  _d.data() as Map<String, dynamic>;
              ///get users in chat
              List<ChatUser> _members = [];
              for (var _uid in _chatData["members"]) {
                DocumentSnapshot _userSnapshot = await _db.getUser(_uid);
                Map<String, dynamic> _userData =
                    _userSnapshot.data() as Map<String, dynamic>;
                _userData['uid']=_userSnapshot.id;
                _members.add(
                  ChatUser.fromJson(_userData),
                );
              }

              //get last message
              List<ChatMessage> _messages = [];
              QuerySnapshot _chatMessage = await _db.getLastMessageForChat(_d.id);
              if(_chatMessage.docs.isNotEmpty){
                Map<String, dynamic> _messageData = _chatMessage.docs.first.data()! as Map<String, dynamic>;
                ChatMessage _message = ChatMessage.fromJSON(_messageData);
                _messages.add(_message);
              }

              ///return chat instance
              return ChatModel(
                  messages: _messages,
                  uid: _d.id,
                  currentUserUid: _auth.user.uid,
                  activity: _chatData["is_activity"],
                  group: _chatData["is_group"],
                  members: _members);
            },
          ).toList(),
        );
        notifyListeners();
      });
    } catch (e) {
      print("error getting chats");
      print(e);
    }
  }
}
