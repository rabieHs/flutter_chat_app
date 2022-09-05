import 'dart:async';
import 'dart:io';

import 'package:chatify_app/models/chat_message_model.dart';
import 'package:chatify_app/services/cloude_storage_service.dart';
import 'package:chatify_app/services/media_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get_it/get_it.dart';

import '../services/database_service.dart';
import '../services/navigation_service.dart';
import 'authentication_provider.dart';

class ChatPageProvider extends ChangeNotifier {
  late DatabaseService _db;
  late NavigationService _navigation;
  late CloudStorageService _storage;
  late MediaService _media;

  late StreamSubscription _messagesStream;
  late StreamSubscription _keyboadVisibilityStream;

  late KeyboardVisibilityController _keyboardVisibilityController;

  AuthenticationProvider _auth;
  ScrollController _messagesListViewController;
  String _chatId;
  List<ChatMessage>? messages;
  String? _message;

  String get message {
    return message;
  }

  void set message(String _value) {
    _message = _value;
  }

  ChatPageProvider(this._chatId, this._auth, this._messagesListViewController) {
    _db = GetIt.instance.get<DatabaseService>();
    _storage = GetIt.instance.get<CloudStorageService>();
    _media = GetIt.instance.get<MediaService>();
    _navigation = GetIt.instance.get<NavigationService>();
    _keyboardVisibilityController = KeyboardVisibilityController();
    listenToMessages();
    listenToKeyboardChanges();
  }

  @override
  void dispose() {
    _messagesStream.cancel();

    super.dispose();
  }

  void listenToMessages() {
    try {
      _messagesStream = _db.streamMessagesForChat(_chatId).listen(
        (_snapshot) {
          List<ChatMessage> _messages = _snapshot.docs.map((_m) {
            Map<String, dynamic> _messagesData =
                _m.data() as Map<String, dynamic>;
            return ChatMessage.fromJSON(_messagesData);
          }).toList();
          messages = _messages;
          notifyListeners();
          WidgetsBinding.instance!.addPostFrameCallback(
            (_) {
              if (_messagesListViewController.hasClients) {
                _messagesListViewController.jumpTo(
                    _messagesListViewController.position.maxScrollExtent);
              }
            },
          );
        },
      );
    } catch (e) {
      print(e);
    }
  }

  void listenToKeyboardChanges() {
    _keyboadVisibilityStream = _keyboardVisibilityController.onChange.listen(
      (_event) {
        _db.updateChatData(_chatId, {"is_activity": _event});
      },
    );
  }

  void sendTextMessage() {
    if (_message != null) {
      ChatMessage _messageToSend = ChatMessage(
        senderID: _auth.user.uid,
        type: MessageType.TEXT,
        content: _message!,
        sentTime: DateTime.now(),
      );
      _db.addMessagtoChat(_chatId, _messageToSend);
    }
  }

  void deleteChat() {
    goBack();
    _db.deleteChat(_chatId);
  }

  void sendImageMessage() async {
    try {
      File? _file = await _media.pickImageFromLibrary();
      if (_file != null) {
        String? _downloadUrl = await _storage.SaveChatImagesToStorage(
          _chatId,
          _auth.user.uid,
          _file,
        );
        ChatMessage _messageToSend = ChatMessage(
          senderID: _auth.user.uid,
          type: MessageType.IMAGE,
          content: _downloadUrl!,
          sentTime: DateTime.now(),
        );
        _db.addMessagtoChat(_chatId, _messageToSend);
      }
    } catch (e) {
      print(e);
    }
  }

  void goBack() {
    _navigation.goBack();
  }
}
