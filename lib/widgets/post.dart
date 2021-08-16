import 'package:flutter/material.dart';

buildPost(
    {@required String mediaUrl,
    @required String userName,
    @required String location,
    @required String description,
    @required String userProfile}) {
  return Container(
    height: 400,
    color: Colors.red,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(userProfile),
            backgroundColor: Colors.grey,
          ),
          title: GestureDetector(
            onTap: () {},
            child: Text(
              userName,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          subtitle: Text(
            location,
          ),
          trailing: IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () => print(""),
          ),
        ),
        Expanded(
          child: Image.network(mediaUrl),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => print("Likeing post"),
              child: Icon(
                Icons.favorite_border,
                size: 28.0,
                color: Colors.purple,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            GestureDetector(
              onTap: () => print("Showing comment"),
              child: Icon(
                Icons.chat,
                size: 28.0,
                color: Colors.blue,
              ),
            )
          ],
        ),
        Row(
          children: [
            Container(
              margin: EdgeInsets.only(left: 5.0),
              child: Text(
                "likeCount likes",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Text(description),
            )
          ],
        ),
      ],
    ),
  );
}
