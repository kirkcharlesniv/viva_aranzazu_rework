import 'package:flutter/material.dart';
import 'package:viva_aranzazu_rework/bloc/models/post.dart';
import 'package:viva_aranzazu_rework/widgets/dashboard/post_detail.dart';

class PostWidget extends StatelessWidget {
  final Post post;

  const PostWidget({Key key, @required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(
        '${post.id}',
        style: TextStyle(fontSize: 10.0),
      ),
      onTap: () {
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => new PostDetail(post)));
      },
      title: Text(post.title),
      isThreeLine: true,
      subtitle: Text(post.excerpt),
      dense: true,
    );
  }
}