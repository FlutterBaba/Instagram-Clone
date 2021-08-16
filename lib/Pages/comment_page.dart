import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/Pages/time_line_page.dart';
import 'package:instagram_clone/widgets/app_bar_widget.dart';
import 'package:instagram_clone/widgets/progress_widget.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentPage extends StatefulWidget {
  final String mediaUrl;
  final String postId;
  final String ownerId;
  CommentPage({this.mediaUrl, this.postId, this.ownerId});
  @override
  _CommentPageState createState() => _CommentPageState(
        mediaUrl: this.mediaUrl,
        ownerId: this.ownerId,
        postId: this.postId,
      );
}

class _CommentPageState extends State<CommentPage> {
  DateTime timestamp = DateTime.now();

  TextEditingController commentController = TextEditingController();
  String postId;
  String ownerId;
  String mediaUrl;

  _CommentPageState({
    this.postId,
    this.mediaUrl,
    this.ownerId,
  });

  buildComments() {
    return StreamBuilder(
      stream: commentsRef
          .doc(postId)
          .collection("comments")
          .orderBy("timestamp", descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProfress();
        }
        List<CommentModel> commentsModels = [];
        snapshot.data.docs.forEach((doc) {
          commentsModels.add(CommentModel.fromDocument(doc));
        });
        return Column(
          children: commentsModels,
        );
      },
    );
  }

  buildAddComment() {
    commentsRef.doc(postId).collection('comments').add({
      "username": currentUser.name,
      "comment": commentController.text,
      "timestamp": timestamp,
      "userImage": currentUser.photo,
      "userId": currentUser.userid,
    });

    activityFeedRef.doc(ownerId).collection("feedItems").doc(postId).set(
      {
        "type": "comment",
        "commentData": commentController.text,
        "username": currentUser.username,
        "userProfileImage": currentUser.photo,
        "postId": postId,
        "mediaUrl": mediaUrl,
        "timestamp": timestamp,
      },
    );

    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: TextFormField(
              controller: commentController,
              decoration: InputDecoration(
                labelText: "Write a comment..",
              ),
            ),
          ),
          MaterialButton(
            shape: RoundedRectangleBorder(
              side: BorderSide.none,
            ),
            child: Text("Post"),
            onPressed: buildAddComment,
          ),
        ],
      ),
      appBar: appBar(context, title: "Comments", appTitle: true),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          buildComments(),
          Divider(),
        ],
      ),
    );
  }
}

class CommentModel extends StatelessWidget {
  final String comment;
  final Timestamp timestamp;
  final String userId;
  final String userImage;
  final String userName;
  CommentModel({
    this.comment,
    this.timestamp,
    this.userId,
    this.userImage,
    this.userName,
  });

  factory CommentModel.fromDocument(DocumentSnapshot doc) {
    return CommentModel(
      comment: doc["comment"],
      timestamp: doc["timestamp"],
      userId: doc["userId"],
      userImage: doc["userImage"],
      userName: doc["userImage"],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(comment),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(
              userImage,
            ),
          ),
          subtitle: Text(timeago.format(timestamp.toDate())),
        ),
        Divider(),
      ],
    );
  }
}
