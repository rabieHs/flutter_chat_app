import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
class MediaService{
  MediaService(){

  }
  Future<File?> pickImageFromLibrary()async{

FilePickerResult? _result = await FilePicker.platform.pickFiles(type: FileType.image);
if(_result != null){
  File image;
  image = File(_result.files[0].path!);
  return image;
}
return null;
print("null");
}
}