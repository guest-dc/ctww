import 'package:flutter/material.dart';
import 'colors.dart';

import '../pages/lessons_page.dart';
import '../pages/story_walk_page.dart';
import '../pages/anatomy_page.dart';
import '../pages/matching_page.dart';

class NavBarButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  NavBarButton({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        title,
        style: TextStyle(
          color: colorGOLD,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }
}

class NavBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth > 850) {
      return AppBar(
        backgroundColor: colorRED,
        title: Text(
          '写 CtWW',
          style: TextStyle(
            color: colorGOLD,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        flexibleSpace: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NavBarButton(
                    title: 'Lessons',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LessonsPage()),
                      );
                    }),
                SizedBox(width: 20),
                NavBarButton(
                    title: 'Story Walkthrough',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => StoryWalkPage()),
                      );
                    }),
                SizedBox(width: 20),
                NavBarButton(
                    title: 'Anatomy Lab',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AnatomyPage()),
                      );
                    }),
                SizedBox(width: 20),
                NavBarButton(
                    title: 'Matching Game',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MatchingPage()),
                      );
                    }),
              ],
            ),
          ),
        ),
      );
    } else {
      return AppBar(
        backgroundColor: colorRED,
        title: Text(
          'CtWW',
          style: TextStyle(
            color: colorGOLD,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Lessons') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LessonsPage()),
                );
              } else if (value == 'Story Walkthrough') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StoryWalkPage()),
                );
              } else if (value == 'Anatomy Lab') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AnatomyPage()),
                );
              } else if (value == 'Matching Game') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MatchingPage()),
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'Lessons',
                  child: Text('Lessons',
                      style: TextStyle(
                          color: colorGOLD, fontWeight: FontWeight.bold)),
                ),
                PopupMenuItem<String>(
                  value: 'Story Walkthrough',
                  child: Text('Story Walkthrough',
                      style: TextStyle(
                          color: colorGOLD, fontWeight: FontWeight.bold)),
                ),
                PopupMenuItem<String>(
                  value: 'Anatomy Lab',
                  child: Text('Anatomy Lab',
                      style: TextStyle(
                          color: colorGOLD, fontWeight: FontWeight.bold)),
                ),
                PopupMenuItem<String>(
                  value: 'Matching Game',
                  child: Text('Matching Game',
                      style: TextStyle(
                          color: colorGOLD, fontWeight: FontWeight.bold)),
                ),
              ];
            },
            icon: Icon(
              Icons.menu,
              color: colorGOLD,
            ),
          ),
        ],
      );
    }
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
