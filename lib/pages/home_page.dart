import 'package:chatify_app/pages/chats_page.dart';
import 'package:chatify_app/pages/users_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  int _currentPage = 0;
  final List<Widget> _pages = [
    ChatsPage(),

      UsersPage(),
  ];
  Widget build(BuildContext context) {
    return _buildUI();
  }

  Widget _buildUI() {
    return Scaffold(
      body: _pages[_currentPage],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPage,
        onTap: (_inex) {
          setState(() {
            _currentPage = _inex;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_sharp),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.supervised_user_circle_sharp),
            label: 'Users',
          ),
        ],
      ),
    );
  }
}
