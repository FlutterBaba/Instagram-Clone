import 'package:cloud_firestore/cloud_firestore.dart';

class PostModels {
  final String postId;
  final String ownerId;
  final String location;
  final String description;
  final String mediaUrl;
  final Map like;
  final int likeCount;

  PostModels({
    this.postId,
    this.ownerId,
    this.location,
    this.description,
    this.mediaUrl,
    this.like,
    this.likeCount,
  });
  factory PostModels.froDocument(DocumentSnapshot doc) {
    return PostModels(
      postId: doc["psotId"],
      ownerId: doc["ownerId"],
      location: doc["location"],
      description: doc["description"],
      mediaUrl: doc["mediaUrl"],
      like: doc["like"],
    );
  }

  int getLikeCOunt() {
    if (like == null) {
      return 0;
    }
    int count = 0;
    like.values.forEach(
      (val) {
        if (val == true) {
          count += 1;
        }
      },
    );
    return count;
  }
}
