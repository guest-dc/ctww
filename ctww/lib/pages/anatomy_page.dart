import 'package:flutter/material.dart';

//import '../utils/colors.dart';
import '../utils/nav_bar.dart';

class AnatomyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NavBar(),
      body: Center(
        child: Text(
          'Anatomy stuff goes here',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}