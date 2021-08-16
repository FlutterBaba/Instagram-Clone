import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:instagram_clone/Pages/post_page.dart';
import 'package:instagram_clone/authProvider/auth_provider.dart';
import 'package:instagram_clone/models/user_models.dart';
import 'package:instagram_clone/widgets/app_bar_widget.dart';
import 'package:instagram_clone/widgets/progress_widget.dart';
import 'package:provider/provider.dart';

var userRef = FirebaseFirestore.instance.collection('users');
var commentsRef = FirebaseFirestore.instance.collection('comments');
var activityFeedRef = FirebaseFirestore.instance.collection('feed');
var followerRef = FirebaseFirestore.instance.collection('followers');
var followingRef = FirebaseFirestore.instance.collection('following');
var timeLineRef = FirebaseFirestore.instance.collection('timeline');
var postLineRef = FirebaseFirestore.instance.collection('post');
UserModels currentUser;

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List<Post> posts;

  @override
  void initState() {
    super.initState();
    getTimeline();
  }

  getTimeline() async {
    QuerySnapshot snapshot = await timeLineRef.get();
    List<Post> posts =
        snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    setState(() {
      this.posts = posts;
    });
  }

  buildTimeline() {
    if (posts == null) {
      return circularProfress();
    } else if (posts.isEmpty) {
      return Center(
        child: SvgPicture.asset(
          'images/no-photo.svg',
        ),
      );
    } else {
      return ListView(
        physics: BouncingScrollPhysics(),
        children: posts,
      );
    }
  }

  @override
  Widget build(context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    currentUser = authProvider.userDetails;
    return Scaffold(
      appBar: appBar(context),
      body: RefreshIndicator(
        onRefresh: () => getTimeline(),
        child: buildTimeline(),
      ),
    );
  }
}
