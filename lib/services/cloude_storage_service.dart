import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

const String User_collection = "Users";

class CloudStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  CloudStorageService() {}
  Future<String?> saveUserImageToStorage(String _uid, File _file)async {
    try {
      Reference _ref =
          _storage.ref().child('images/users/${_uid}/profile.jpg}');
      UploadTask _task = _ref.putFile(_file);

      return _task.then(
        (_result) => _result.ref.getDownloadURL(),
      );
    } catch (e) {
      print(e);
    }
  }
  Future<String?>SaveChatImagesToStorage(String _chatID,_userID, File _file)async{

    try {
      Reference _ref =
      _storage.ref().child('images/chats/$_chatID/${_userID}_${Timestamp.now().millisecondsSinceEpoch}.jpg');
      UploadTask _task = _ref.putFile(_file);

      return _task.then(
            (_result) => _result.ref.getDownloadURL(),
      );
    }catch(e){
      print(e);
    }
  }
}
