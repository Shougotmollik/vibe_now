import 'package:flutter/material.dart';
import 'package:vibe_now/views/profile/widget/post_item.dart';

class PostsTab extends StatefulWidget {
  const PostsTab({super.key});

  @override
  State<PostsTab> createState() => _PostsTabState();
}

class _PostsTabState extends State<PostsTab> {
  final List<Map<String, dynamic>> _posts = [
    {"is_liked": true},
    {"is_liked": false},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _posts.map((item) {
        return PostItem(
          isLiked: item["is_liked"],
          onLikeTap: () {
            setState(() => item["is_liked"] = !item["is_liked"]);
          },
        );
      }).toList(),
    );
  }
}