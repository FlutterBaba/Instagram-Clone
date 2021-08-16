import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_clone/Pages/profile_page.dart';
import 'package:instagram_clone/Pages/time_line_page.dart';
import 'package:instagram_clone/models/user_models.dart';

import 'package:instagram_clone/widgets/progress_widget.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // Future<QuerySnapshot> searchResultRuture;
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> searchResultsFuture;

  handleSearch(String query) {
    Future<QuerySnapshot> users =
        userRef.where("username", isGreaterThanOrEqualTo: query).get();
    setState(() {
      searchResultsFuture = users;
    });
  }

  inpety(String a) {
    return Container();
  }

  Widget buildSearchField() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: searchController,
        decoration: InputDecoration(
          filled: true,
          hintText: "search for a user...",
          suffixIcon: Icon(Icons.clear),
          prefixIcon: Icon(Icons.account_box),
        ),
        // onEditingComplete: handleSearch,
        onFieldSubmitted: handleSearch,
      ),
    );
  }

  buildNoContent() {
    // final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          physics: BouncingScrollPhysics(),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: SvgPicture.asset(
                "images/search.svg",
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildSearchResult() {
    //yh future tha
    //
    return FutureBuilder(
      future: searchResultsFuture,
      builder: (context, snapshort) {
        if (!snapshort.hasData) {
          return circularProfress();
        }
        List<UserResult> searchResult = [];
        snapshort.data.docs.forEach((doc) {
          UserModels userModels = UserModels.fromDocument(doc);
          UserResult userSult = UserResult(userModels);
          searchResult.add(userSult);
        });
        return ListView(
          physics: BouncingScrollPhysics(),
          children: searchResult,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
      appBar: buildSearchField(),
      body:
          searchResultsFuture == null ? buildNoContent() : buildSearchResult(),
    );
  }
}

class UserResult extends StatelessWidget {
  final UserModels userModels;
  UserResult(this.userModels);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Column(
        children: <Widget>[
          ListTile(
            leading: GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      ProfilePage(currentUser: userModels.userid),
                ),
              ),
              child: CircleAvatar(
                backgroundColor: Theme.of(context).accentColor,
                backgroundImage: NetworkImage(userModels.photo),
              ),
            ),
            title: Text(
              userModels.name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            subtitle: Text(
              userModels.username,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
