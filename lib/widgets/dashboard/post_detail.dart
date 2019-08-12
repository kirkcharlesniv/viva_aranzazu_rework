import 'package:flutter/material.dart';
import 'package:viva_aranzazu_rework/bloc/models/post.dart';

class PostDetail extends StatelessWidget {
  final Post post;
  PostDetail(this.post);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(post.title),
      ),
      body: Column(
        children: <Widget>[Text(post.excerpt)],
      ),
    );
  }
}
