import 'dart:io';

import 'package:chatify_app/providers/authentication_provider.dart';
import 'package:chatify_app/services/cloude_storage_service.dart';
import 'package:chatify_app/services/database_service.dart';
import 'package:chatify_app/services/media_service.dart';
import 'package:chatify_app/services/navigation_service.dart';
import 'package:chatify_app/widgets/custom_input_field.dart';
import 'package:chatify_app/widgets/rounded_button.dart';
import 'package:chatify_app/widgets/rounded_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;
  late DatabaseService _db;
  late CloudStorageService _cloudStorageService;
  late NavigationService _navigationService;

  final _registerFormKey = GlobalKey<FormState>();

  File? _profileImage;

  String? _email;
  String? _password;
  String? _name;

  @override
  Widget build(BuildContext context) {
    _auth = Provider.of<AuthenticationProvider>(context);
    _db = GetIt.instance.get<DatabaseService>();
    _cloudStorageService = GetIt.instance.get<CloudStorageService>();
    _navigationService = GetIt.instance.get<NavigationService>();
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return _buildUI();
  }

  Widget _buildUI() {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: _deviceWidth * 0.03,
          vertical: _deviceHeight * 0.02,
        ),
        height: _deviceHeight * 0.98,
        width: _deviceWidth * 0.97,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _profileImageField(),
            SizedBox(
              height: _deviceHeight * 0.05,
            ),
            _registerForm(),
            _registerButton(),
          ],
        ),
      ),
    );
  }

  Widget _profileImageField() {
    return GestureDetector(onTap: () {
      GetIt.instance.get<MediaService>().pickImageFromLibrary().then(
        (_file) {
          setState(() {
            _profileImage = _file;
          });
        },
      );
    }, child: () {
      if (_profileImage != null) {
        return RoundedSelectImage(
          key: UniqueKey(),
          image: _profileImage!,
          size: _deviceHeight * 0.15,
        );
      } else {
        return RoundedImage(
          key: UniqueKey(),
          imagePath: "https://i.pravatar.cc/1000?img=65",
          size: _deviceHeight * 0.15,
        );
        print("null2");
      }
    }());
  }

  Widget _registerForm() {
    return Container(
      height: _deviceHeight * 0.35,
      child: Form(
        key: _registerFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomInputTextField(
              onSaved: (value) {
                setState(() {
                  _name = value;
                });
              },
              regEX: r".{6,}",
              hintText: "name",
              obscureText: false,
            ),
            CustomInputTextField(
              onSaved: (_value) {
                setState(() {
                  _email = _value;
                });
              },
              regEX:
                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
              hintText: "Email",
              obscureText: false,
            ),
            CustomInputTextField(
              onSaved: (_value) {
                setState(() {
                  _password = _value;
                });
              },
              regEX: r".{6,}",
              hintText: "Password!",
              obscureText: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _registerButton() {
    return RoundedButton(
      name: "register",
      height: _deviceHeight * 0.065,
      width: _deviceWidth * 0.65,
      onPressed: () async {
        if(_registerFormKey.currentState!.validate() && _profileImage != null){
          _registerFormKey.currentState!.save();
          String? _uid  = await _auth.registerUserUsingEmailAndPassword(_email!, _password!);
          String? _imageUrl = await _cloudStorageService.saveUserImageToStorage(_uid!, _profileImage!);
          await _db.createUser(_uid, _email!, _name!, _imageUrl!);
          await _auth.logOut();
          await _auth.loginUsingEmailAndPassword(_email!, _password!);

        }
      },
    );
  }
}
