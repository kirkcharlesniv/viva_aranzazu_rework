import 'package:equatable/equatable.dart';

class Post extends Equatable {
  final int id;
  final String date;
  final String title;
  final String excerpt;
  final String authorName;
  final String authorImage;
  final String thumbnail;

  Post(
      {this.id,
      this.date,
      this.title,
      this.excerpt,
      this.authorName,
      this.authorImage,
      this.thumbnail})
      : super([id, date, title, excerpt, authorName, authorImage, thumbnail]);

  @override
  String toString() => 'Post { id: $id }';
}
