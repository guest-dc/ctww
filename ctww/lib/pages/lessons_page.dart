import 'package:flutter/material.dart';

//import '../utils/colors.dart';
import '../utils/nav_bar.dart';

class LessonsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NavBar(),
      body: Center(
        child: Text(
          'Lessons go here',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}