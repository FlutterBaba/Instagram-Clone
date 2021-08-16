import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/Pages/post_screen.dart';
import 'package:instagram_clone/Pages/profile_page.dart';
import 'package:instagram_clone/Pages/time_line_page.dart';
import 'package:instagram_clone/widgets/app_bar_widget.dart';
import 'package:instagram_clone/widgets/progress_widget.dart';
import 'package:timeago/timeago.dart' as timeago;

class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  getActivityFeed() async {
    QuerySnapshot querySnapshot = await activityFeedRef
        .doc(currentUser.userid)
        .collection("feedItems")
        .orderBy("timestamp", descending: true)
        .limit(50)
        .get();
    List<ActiviryFeedItem> feedItems = [];
    querySnapshot.docs.forEach((element) {
      feedItems.add(ActiviryFeedItem.froDocument(element));
    });
    return feedItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, appTitle: true, title: "ActivityFeed"),
      body: FutureBuilder(
        future: getActivityFeed(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProfress();
          }
          return ListView(
            physics: BouncingScrollPhysics(),
            children: snapshot.data,
          );
        },
      ),
    );
  }
}

Widget mediaPreview;
String activityItemText;

class ActiviryFeedItem extends StatelessWidget {
  final String mediaUrl;
  final String postId;
  final String username;
  final Timestamp timestamp;
  final String type;
  final String userProfileImage;
  final String commentData;

  ActiviryFeedItem({
    this.timestamp,
    this.mediaUrl,
    this.postId,
    this.username,
    this.type,
    this.userProfileImage,
    this.commentData,
  });
  factory ActiviryFeedItem.froDocument(DocumentSnapshot doc) {
    return ActiviryFeedItem(
      mediaUrl: doc["mediaUrl"],
      postId: doc["postId"],
      timestamp: doc["timestamp"],
      type: doc["type"],
      userProfileImage: doc["userProfileImage"],
      username: doc["username"],
      commentData: doc["commentData"],
    );
  }
  configurationMediaPreview(BuildContext context) {
    if (type == "like" || type == "comment" || type == "follow") {
      mediaPreview = GestureDetector(
        onTap: () {
          if (type == "follow") {
            print("follow");
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PostScreen(
                  postId: postId,
                  userId: currentUser.userid,
                ),
              ),
            );
          }
        },
        child: Container(
          width: 50,
          height: 50,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: CachedNetworkImageProvider(mediaUrl),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      mediaPreview = Text('');
    }
    if (type == "like") {
      activityItemText = "Liked your Post";
    } else if (type == "follow") {
      activityItemText = "is following You";
    } else if (type == "comment") {
      activityItemText = "replied:$commentData";
    }
  }

  @override
  Widget build(BuildContext context) {
    configurationMediaPreview(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 2.0),
      child: Container(
        color: Colors.white54,
        child: ListTile(
          title: GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ProfilePage(
                  currentUser: currentUser.userid,
                ),
              ),
            ),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: "$username\t\t",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: "$activityItemText",
                  )
                ],
              ),
            ),
          ),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(userProfileImage),
          ),
          subtitle: Text(
            timeago.format(timestamp.toDate()),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: mediaPreview,
        ),
      ),
    );
  }
}
