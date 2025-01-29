import 'package:flutter/material.dart';

//import '../utils/colors.dart';
import '../utils/nav_bar.dart';

class StoryWalkPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NavBar(),
      body: Center(
        child: Text(
          'Story Walkthrough stuff goes here',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}