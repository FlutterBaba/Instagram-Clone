import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/widgets/progress_widget.dart';

Widget cachedNetworkImage(String imageUrl) {
  // print(image);
  return CachedNetworkImage(
    imageUrl: imageUrl,
    fit: BoxFit.cover,
    placeholder: (context, url) => Center(
      child: circularProfress(),
    ),
    // placeholder: (context, url) => Padding(
    //   padding: EdgeInsets.all(20.0),
    //   child: circularProfress(),
    // ),
    errorWidget: (context, url, error) => Icon(
      Icons.error,
    ),
  );
}
