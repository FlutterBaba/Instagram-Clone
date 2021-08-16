import 'package:flutter/material.dart';
import 'package:instagram_clone/widgets/cahed_network_image.dart';
import '../Pages/post_page.dart';

class PostTile extends StatelessWidget {
  final Post post;
  PostTile(this.post);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: cachedNetworkImage(
        post.mediaUrl,
      ),
    );
  }
}
