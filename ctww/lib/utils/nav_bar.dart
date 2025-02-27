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

    if (screenWidth > 960) {
      return AppBar(
        backgroundColor: colorRED,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image widget for the logo
            Container(
              padding: EdgeInsets.only(right: 5.0),
              child: Image.asset(
                'assets/images/ctww_icon_char.png',
                height: 60,
              ),
            ),

            // Text widget for the title
            Text(
              'CtWW',
              style: TextStyle(
                color: colorGOLD,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
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
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  LessonsPage(),
                          transitionDuration: Duration(seconds: 0),
                        ),
                      );
                    }),
                SizedBox(width: 20),
                NavBarButton(
                    title: 'Story Walkthrough',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  StoryWalkPage(),
                          transitionDuration: Duration(seconds: 0),
                        ),
                      );
                    }),
                SizedBox(width: 20),
                NavBarButton(
                    title: 'Anatomy Lab',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  AnatomyPage(),
                          transitionDuration: Duration(seconds: 0),
                        ),
                      );
                    }),
                SizedBox(width: 20),
                NavBarButton(
                    title: 'Matching Game',
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    MatchingPage(),
                            transitionDuration: Duration(seconds: 0),
                          ));
                    }),
              ],
            ),
          ),
        ),
      );
    } else {
      return AppBar(
        backgroundColor: colorRED,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image widget for the logo
            Container(
              padding: EdgeInsets.only(right: 5.0),
              child: Image.asset(
                'assets/images/ctww_icon_char.png',
                height: 60,
              ),
            ),

            // Text widget for the title
            Text(
              'CtWW',
              style: TextStyle(
                color: colorGOLD,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Lessons') {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        LessonsPage(),
                    transitionDuration: Duration(seconds: 0),
                  ),
                );
              } else if (value == 'Story Walkthrough') {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        StoryWalkPage(),
                    transitionDuration: Duration(seconds: 0),
                  ),
                );
              } else if (value == 'Anatomy Lab') {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        AnatomyPage(),
                    transitionDuration: Duration(seconds: 0),
                  ),
                );
              } else if (value == 'Matching Game') {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        MatchingPage(),
                    transitionDuration: Duration(seconds: 0),
                  ),
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
