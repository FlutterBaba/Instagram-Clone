import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_clone/Pages/edit_profile.dart';
import 'package:instagram_clone/Pages/post_page.dart';
import 'package:instagram_clone/Pages/time_line_page.dart';
import 'package:instagram_clone/Pages/upload_page.dart';
import 'package:instagram_clone/models/user_models.dart';
import 'package:instagram_clone/widgets/app_bar_widget.dart';
import 'package:instagram_clone/widgets/post_tile.dart';
import 'package:instagram_clone/widgets/progress_widget.dart';

class ProfilePage extends StatefulWidget {
  final String currentUser;
  final UserModels userModels;

  ProfilePage({@required this.currentUser, this.userModels});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String postOrientaion = "grid";
  DateTime timestamp = DateTime.now();
  bool isloading = false;
  bool isfollowing = false;
  int followerCount = 0;
  int followingCount = 0;
  int postCount = 0;

  List<Post> posts = [];

  QuerySnapshot snapshot;

  @override
  void initState() {
    super.initState();
    getProfilePosts();
    getFollowers();
    getFollowing();
    checkIfFollowing();
  }

  getFollowers() async {
    QuerySnapshot querySnapshot = await followerRef
        .doc(widget.currentUser)
        .collection('userFollowers')
        .get();
    setState(() {
      followerCount = querySnapshot.docs.length;
    });
  }

  getFollowing() async {
    QuerySnapshot querySnapshot = await followingRef
        .doc(widget.currentUser)
        .collection('userFollowing')
        .get();
    setState(() {
      followingCount = querySnapshot.docs.length;
    });
  }

  checkIfFollowing() async {
    DocumentSnapshot documentSnapshot = await followerRef
        .doc(widget.currentUser)
        .collection('userFollowers')
        .doc(currentUser.userid)
        .get();
    setState(() {
      isfollowing = documentSnapshot.exists;
    });
  }

  getProfilePosts() async {
    setState(() {
      isloading = true;
    });
    snapshot = await postRef
        .doc(widget.currentUser)
        .collection("userPost")
        .orderBy("timestamp", descending: true)
        .get();
    setState(() {
      isloading = false;
      postCount = snapshot.docs.length;
      // snapshot.docs.forEach((element) {
      //   print(element.data());
      // });
      posts = snapshot.docs.map((e) => Post.fromDocument(e)).toList();
    });
  }

  Widget buildButton({String text, Function function}) {
    return Expanded(
      child: Container(
        height: 30,
        padding: EdgeInsets.only(top: 2.0),
        child: MaterialButton(
          color: isfollowing ? Colors.white : Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          onPressed: function,
          child: Text(
            text,
            style: TextStyle(
              color: isfollowing ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  buildProfileButtton() {
    if (FirebaseAuth.instance.currentUser.uid == widget.currentUser) {
      return buildButton(
        text: "Edit Profile",
        function: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditProfile(
              editCurrent: data,
            ),
          ),
        ),
      );
    } else if (isfollowing) {
      return buildButton(
        text: "unFollow",
        function: handleUnfollowerUser,
      );
    } else if (!isfollowing) {
      return buildButton(
        text: "follow",
        function: handleFollowerUser,
      );
    }
  }

  handleUnfollowerUser() {
    setState(() {
      isfollowing = false;
    });

    followerRef
        .doc(widget.currentUser)
        .collection("userFollowers")
        .doc(currentUser.userid)
        .get()
        .then(
      (value) {
        if (value.exists) {
          value.reference.delete();
        }
      },
    );
    followingRef
        .doc(currentUser.userid)
        .collection("userFollowing")
        .doc(widget.currentUser)
        .get()
        .then(
      (value) {
        if (value.exists) {
          value.reference.delete();
        }
      },
    );

    activityFeedRef
        .doc(widget.currentUser)
        .collection("feedItems")
        .doc(currentUser.userid)
        .get()
        .then(
      (value) {
        if (value.exists) {
          value.reference.delete();
        }
      },
    );
  }

  handleFollowerUser() {
    setState(() {
      isfollowing = true;
    });

    followerRef
        .doc(widget.currentUser)
        .collection("userFollowers")
        .doc(currentUser.userid)
        .set({});

    followingRef
        .doc(currentUser.userid)
        .collection("userFollowing")
        .doc(widget.currentUser)
        .set({});

    activityFeedRef.doc(widget.currentUser).collection("feedItems")
        // .doc(currentUser.userid)
        .add(
      // "type": "follow",
      // "ownerId": widget.currentUser,
      // "username": currentUser.name,
      // "userId": currentUser.userid,
      // "userPrfile": currentUser.photo,
      // "timestamp": timestamp,
      {
        "type": "follow",
        "commentData": "Following you",
        "username": currentUser.username,
        "userProfileImage": currentUser.photo,
        "postId": "",
        "mediaUrl": currentUser.photo,
        "timestamp": timestamp,
      },
    );

    // activityFeedRef.doc(ownerId).collection("feedItems").add(
    //   {
    //     "type": "comment",
    //     "commentData": commentController.text,
    //     "username": currentUser.username,
    //     "userProfileImage": currentUser.photo,
    //     "postId": postId,
    //     "mediaUrl": mediaUrl,
    //     "timestamp": timestamp,
    //   },
    // );
  }

  Widget buildCountColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          count.toString(),
          style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 4.0),
          child: Text(
            label,
            style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  UserModels data;
  Widget buildProfileHandle() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(widget.currentUser)
          .snapshots(),
      builder: (context, snapshort) {
        if (!snapshort.hasData) {
          return Center(
            child: circularProfress(),
          );
        }
        data = UserModels.fromDocument(snapshort.data);

        print(data.photo);
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    // backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(data.photo),
                    // backgroundImage: NetworkImage(data.photo),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            buildCountColumn("Post", postCount),
                            buildCountColumn("Followers", followerCount),
                            buildCountColumn("Following", followingCount),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildProfileButtton(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 12.0),
                child: Text(
                  data.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    postOrientaion = "list";
                  });
                },
                // onTap: (){
                //   setState(() {
                //     postOrientaion="list";
                //   });

                // onTap: () => Navigator.of(context).push(
                //   MaterialPageRoute(
                //     builder: (context) => ProfilePage(),
                //   ),

                child: Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 4.0),
                  child: Text(
                    data.username,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 4.0),
                child: Text(
                  data.bio,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  buildProfilePost() {
    if (isloading) {
      return circularProfress();
    } else if (posts.isEmpty) {
      return SvgPicture.asset(
        'images/no-photo.svg',
      );
    } else if (postOrientaion == "grid") {
      List<GridTile> gridTiles = [];
      posts.forEach((element) {
        gridTiles.add(GridTile(
          child: PostTile(element),
        ));
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTiles,
      );
    } else if (postOrientaion == "list") {
      return Column(
        children: posts,
      );
    }
  }

  setPostOrientaion(String postOrientaion) {
    setState(() {
      this.postOrientaion = postOrientaion;
    });
  }

  buildTogglePostOrientaion() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Icon(
            Icons.grid_on,
            color: this.postOrientaion == "grid"
                ? Theme.of(context).primaryColor
                : Colors.grey,
          ),
          onPressed: () => setPostOrientaion("grid"),
        ),
        IconButton(
          icon: Icon(
            Icons.list,
            color: this.postOrientaion == "list"
                ? Theme.of(context).primaryColor
                : Colors.grey,
          ),
          onPressed: () => setPostOrientaion("list"),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    print(widget.currentUser);
    return Scaffold(
      appBar: appBar(
        context,
        appTitle: true,
        title: "Profile",
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          buildProfileHandle(),
          Divider(),
          buildTogglePostOrientaion(),
          Divider(
            height: 0.0,
          ),
          buildProfilePost(),
        ],
      ),
    );
  }
}
