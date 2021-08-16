import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/Pages/comment_page.dart';
import 'package:instagram_clone/Pages/time_line_page.dart';
import 'package:instagram_clone/Pages/upload_page.dart';
import 'package:instagram_clone/models/user_models.dart';
import 'package:instagram_clone/widgets/cahed_network_image.dart';
import 'package:instagram_clone/widgets/progress_widget.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String name;
  final String location;
  final String description;
  final String mediaUrl;
  final Map like;
  final int likeCount;
  Post({
    this.postId,
    this.ownerId,
    this.name,
    this.location,
    this.description,
    this.mediaUrl,
    this.like,
    this.likeCount,
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc["psotId"],
      ownerId: doc["ownerId"],
      name: doc["name"],
      location: doc["location"],
      description: doc["description"],
      mediaUrl: doc["MediaUrl"],
      like: doc["like"],
    );
  }

  int getLikeCount(likes) {
    // if no likes, return 0
    if (likes == null) {
      return 0;
    }
    int count = 0;
    // if the key is explicitly set to true, add a like
    likes.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }

  @override
  _PostState createState() => _PostState(
        postId: this.postId,
        ownerId: this.ownerId,
        name: this.name,
        location: this.location,
        description: this.description,
        mediaUrl: this.mediaUrl,
        likes: this.like,
        likeCount: getLikeCount(this.like),
      );
}

class _PostState extends State<Post> {
  final String currentUserId = currentUser?.userid;

  DateTime timestamp = DateTime.now();

  final String postId;
  final String ownerId;
  final String name;
  final String location;
  final String description;
  final String mediaUrl;

  int likeCount;
  Map likes;
  bool isliked = false;
  bool showheart = false;
  _PostState({
    this.postId,
    this.ownerId,
    this.name,
    this.location,
    this.description,
    this.mediaUrl,
    this.likes,
    this.likeCount,
  });
  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = MaterialButton(
      color: Colors.purple,
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = MaterialButton(
      child: Text("Continue"),
      color: Colors.purple,
      onPressed: () async {
        print("dele");
        postRef
            .doc(ownerId)
            .collection("userPost")
            .doc(postId)
            .get()
            .then((value) {
          if (value.exists) {
            value.reference.delete();
          }
        });
        timeLineRef.doc(postId).get().then((value) {
          if (value.exists) {
            value.reference.delete();
          }
        });
        activityFeedRef
            .doc(ownerId)
            .collection("feedItems")
            .doc(postId)
            .get()
            .then((value) {
          if (value.exists) {
            value.reference.delete();
          }
        }).then(
          (value) => Navigator.pop(context),
        );
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("Delete Product ?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  buildPostHeader() {
    //yh future tha
    return StreamBuilder(
      stream: userRef.doc(ownerId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProfress();
        }
        UserModels user = UserModels.fromDocument(snapshot.data);
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(user.photo),
            backgroundColor: Colors.grey,
          ),
          title: GestureDetector(
            onTap: () => print('showing profile'),
            child: Text(
              user.username,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          subtitle: Text(location),
          trailing: currentUserId != ownerId
              ? MaterialButton(
                  onPressed: null,
                )
              : IconButton(
                  onPressed: () => showAlertDialog(context),
                  icon: Icon(Icons.more_vert),
                ),
        );
      },
    );
  }

  addLikeToActivityFeed() {
    activityFeedRef.doc(ownerId).collection("feedItems").doc(postId).set(
      {
        "type": "like",
        "commentData": '',
        "userId": currentUser.userid,
        "username": currentUser.username,
        "userProfileImage": currentUser.photo,
        "postId": postId,
        "mediaUrl": mediaUrl,
        "timestamp": timestamp,
      },
    );
  }

  deleteLikeToActivityFeed() {
    // bool isNotPostOwner = currentUserId != ownerId;
    // if (isNotPostOwner) {
    activityFeedRef
        .doc(ownerId)
        .collection("feedItems")
        .doc(postId)
        .get()
        .then((value) {
      if (value.exists) {
        value.reference.delete();
      }
    });
    // }
  }

  buildHandleLikePost() {
    bool _isliked = likes[currentUserId] == true;

    if (_isliked) {
      postRef
          .doc(ownerId)
          .collection("userPost")
          .doc(postId)
          .update({"like.$currentUserId": false});
      timlineRef.doc(postId).update({
        "like.$currentUserId": false,
      });
      deleteLikeToActivityFeed();
      setState(() {
        if (likeCount > 0) {
          likeCount -= 1;
        }
        isliked = false;
        isliked = likes[currentUserId] == false;
      });
    } else if (!_isliked) {
      postRef.doc(ownerId).collection("userPost").doc(postId).update({
        "like.$currentUserId": true,
      });
      timlineRef.doc(postId).update({
        "like.$currentUserId": true,
      });
      addLikeToActivityFeed();
      setState(() {
        if (likeCount < 1) {
          likeCount += 1;
        }
        isliked = true;
        showheart = true;
        isliked = likes[ownerId] == true;
      });
      Timer(
        Duration(milliseconds: 500),
        () {
          setState(
            () {
              showheart = false;
            },
          );
        },
      );
    }
  }

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: () => buildHandleLikePost(),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          cachedNetworkImage(mediaUrl),
          showheart
              ? Icon(
                  Icons.favorite,
                  size: 200,
                  color: Colors.red,
                )
              : Text(""),
        ],
      ),
    );
  }

  buildShowComments({String postId, String ownerId, String mediaUrl}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CommentPage(
          mediaUrl: mediaUrl,
          ownerId: ownerId,
          postId: postId,
        ),
      ),
    );
  }

  buildPostFooter() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top: 40.0, left: 20.0)),
            GestureDetector(
              onTap: buildHandleLikePost,
              child: Icon(
                isliked ? Icons.favorite : Icons.favorite_border,
                size: 28.0,
                color: Colors.pink,
              ),
            ),
            Padding(padding: EdgeInsets.only(right: 20.0)),
            GestureDetector(
              onTap: () => buildShowComments(
                mediaUrl: mediaUrl,
                ownerId: ownerId,
                postId: postId,
              ),
              child: Icon(
                Icons.chat,
                size: 28.0,
                color: Colors.blue[900],
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                "$likeCount likes",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                "$name",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(child: Text(description))
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    isliked = (likes[currentUserId] == true);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter(),
      ],
    );
  }
}
