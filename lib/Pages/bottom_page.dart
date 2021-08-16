// import 'package:flutter/material.dart';
// import 'package:instagram_clone/Pages/activity_feed.dart';
// import 'package:instagram_clone/Pages/profile_page.dart';
// import 'package:instagram_clone/Pages/search_page.dart';
// import 'package:instagram_clone/Pages/time_line_page.dart';
// import 'package:instagram_clone/Pages/upload_page.dart';
// import 'package:instagram_clone/authProvider/auth_provider.dart';
// import 'package:instagram_clone/models/user_models.dart';
// import 'package:provider/provider.dart';

// UserModels currentUser;

// class BottomPage extends StatefulWidget {
//   static String id = "bottomPage";
//   @override
//   _BottomPageState createState() => _BottomPageState();
// }

// class _BottomPageState extends State<BottomPage> {
//   int _selectedIndex = 0;
//   static List<Widget> _widgetOptions = <Widget>[
//     Timeline(),
//     ActivityFeed(),
//     UploadPage(),
//     SearchPage(),
//     ProfilePage(
//       currentUser: currentUser.userid,
//       userModels: currentUser,
//     ),
//   ];

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     AuthProvider authProvider = Provider.of<AuthProvider>(context);
//     currentUser = authProvider.userDetails;
//     return Scaffold(
//       body: Center(
//         child: _widgetOptions.elementAt(_selectedIndex),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         showSelectedLabels: false,
//         showUnselectedLabels: false,
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: Icon(Icons.whatshot),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.notifications_active),
//             label: 'Business',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.photo_camera),
//             label: 'School',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.search),
//             label: 'Business',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.account_circle),
//             label: 'School',
//           ),
//         ],
//         currentIndex: _selectedIndex,
//         selectedItemColor: Theme.of(context).primaryColor,
//         onTap: _onItemTapped,
//       ),
//     );
//   }
// }

// import 'package:curved_navigation_bar/curved_navigation_bar.dart';
// import 'package:flutter/material.dart';

// class BottomBar extends StatefulWidget {
//   BottomBar({Key key, this.title}) : super(key: key);

//   final String title;

//   @override
//   _BottomBarState createState() => _BottomBarState();
// }

// class _BottomBarState extends State<BottomBar> {
//   int _page = 0;
//   GlobalKey _bottomNavigationKey = GlobalKey();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       bottomNavigationBar: CurvedNavigationBar(
//         key: _bottomNavigationKey,
//         items: <Widget>[
//           Icon(Icons.whatshot, size: 30),
//           Icon(Icons.notifications_active, size: 30),
//           Icon(Icons.photo_camera, size: 30),
//           Icon(Icons.photo_camera, size: 30),
//         ],
//         onTap: (index) {
//           setState(() {
//             _page = index;
//           });
//         },
//       ),
//       body: Container(
//         color: Colors.blueAccent,
//         child: Center(
//           child: Column(
//             children: <Widget>[
//               Text(_page.toString(), textScaleFactor: 10.0),
//               MaterialButton(
//                 child: Text('Go To Page of index 1'),
//                 onPressed: () {
//                   //Page change using state does the same as clicking index 1 navigation button
//                   final CurvedNavigationBarState navBarState =
//                       _bottomNavigationKey.currentState;
//                   navBarState.setPage(1);
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:instagram_clone/Pages/activity_feed.dart';
import 'package:instagram_clone/Pages/profile_page.dart';
import 'package:instagram_clone/Pages/search_page.dart';
import 'package:instagram_clone/Pages/time_line_page.dart';
import 'package:instagram_clone/Pages/upload_page.dart';
import 'package:instagram_clone/authProvider/auth_provider.dart';
import 'package:instagram_clone/models/user_models.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

UserModels currentUser;

class BottomPage extends StatefulWidget {
  static String id = "bottomPage";

  @override
  _BottomPageState createState() => _BottomPageState();
}

class _BottomPageState extends State<BottomPage> {
  var _currentIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    Timeline(),
    ActivityFeed(),
    UploadPage(),
    SearchPage(),
    ProfilePage(
      currentUser: currentUser.userid,
      userModels: currentUser,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    currentUser = authProvider.userDetails;
    return Scaffold(
      body: Center(
        child: Center(
          child: _widgetOptions.elementAt(_currentIndex),
        ),
      ),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          /// Home

          SalomonBottomBarItem(
            icon: Icon(Icons.whatshot),
            title: Text("Timeline"),
            selectedColor: Colors.purple,
          ),

          /// Likes
          SalomonBottomBarItem(
            icon: Icon(Icons.notifications_active),
            title: Text("Activity Feed"),
            selectedColor: Colors.pink,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.photo_camera),
            title: Text("Upload"),
            selectedColor: Colors.pink,
          ),

          /// Search
          SalomonBottomBarItem(
            icon: Icon(Icons.search),
            title: Text("Search"),
            selectedColor: Colors.teal,
          ),

          /// Profile
          SalomonBottomBarItem(
            icon: Icon(Icons.person),
            title: Text("Profile"),
            selectedColor: Colors.teal,
          ),
        ],
      ),
    );
  }
}
