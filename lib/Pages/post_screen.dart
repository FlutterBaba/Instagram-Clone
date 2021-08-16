import 'package:flutter/material.dart';
import 'package:instagram_clone/Pages/upload_page.dart';
import 'package:instagram_clone/widgets/app_bar_widget.dart';
import 'package:instagram_clone/widgets/progress_widget.dart';
import './post_page.dart';

class PostScreen extends StatefulWidget {
  final String userId;
  final String postId;
  PostScreen({this.userId, this.postId});
  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  @override
  Widget build(BuildContext context) {

    //yh future tha 
    return StreamBuilder(
      stream: postRef
          .doc(widget.userId)
          .collection("userPost")
          .doc(widget.postId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProfress();
        }
        Post postModels = Post.fromDocument(snapshot.data);

        return Center(
          child: Scaffold(
            appBar: appBar(
              context,
              appTitle: true,
              title: "PostScreen",
            ),
            body: ListView(
                physics: BouncingScrollPhysics(),
              children: [
                Container(
                  child: postModels,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
