import 'package:ez_trainz/models/forum_author.dart';

class ForumPost {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String createdAt;
  final String updatedAt;
  final ForumAuthor? author;
  final int commentCount;

  const ForumPost({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.createdAt,
    required this.updatedAt,
    this.author,
    this.commentCount = 0,
  });

  factory ForumPost.fromJson(Map<String, dynamic> json) {
    ForumAuthor? author;
    final rawAuthor = json['author'];
    if (rawAuthor is Map<String, dynamic>) {
      author = ForumAuthor.fromJson(rawAuthor);
    }

    int count = 0;
    final c = json['_count'];
    if (c is Map && c['comments'] is int) {
      count = c['comments'] as int;
    } else if (c is Map && c['comments'] is num) {
      count = (c['comments'] as num).toInt();
    }

    return ForumPost(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      authorId: json['authorId'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      author: author,
      commentCount: count,
    );
  }

  /// Merge fields from [other] when this post was loaded from a minimal endpoint.
  ForumPost mergedWith(ForumPost other) {
    return ForumPost(
      id: id,
      title: title.isNotEmpty ? title : other.title,
      content: content.isNotEmpty ? content : other.content,
      authorId: authorId.isNotEmpty ? authorId : other.authorId,
      createdAt: createdAt.isNotEmpty ? createdAt : other.createdAt,
      updatedAt: updatedAt.isNotEmpty ? updatedAt : other.updatedAt,
      author: author ?? other.author,
      commentCount: commentCount > 0 ? commentCount : other.commentCount,
    );
  }
}
