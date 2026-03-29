/// Forum post / thread item from `GET /forum/posts` or similar.
class ForumPost {
  const ForumPost({
    required this.id,
    required this.title,
    required this.content,
    required this.authorName,
    required this.authorId,
    required this.createdAt,
    this.updatedAt,
    this.commentCount,
    this.isThread,
  });

  final String id;
  final String title;
  final String content;
  final String authorName;
  final String authorId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int? commentCount;
  final bool? isThread;

  static String _text(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      final v = json[k];
      if (v is String && v.isNotEmpty) return v;
    }
    return '';
  }

  static DateTime? _date(dynamic v) {
    if (v is String && v.isNotEmpty) {
      try {
        return DateTime.parse(v);
      } catch (_) {}
    }
    return null;
  }

  factory ForumPost.fromJson(Map<String, dynamic> json) {
    final author = json['author'] is Map<String, dynamic>
        ? json['author'] as Map<String, dynamic>
        : null;
    var authorName = _text(json, ['authorName', 'username', 'userName', 'name']);
    if (authorName.isEmpty && author != null) {
      authorName = _text(author, ['name', 'username', 'userName']);
    }
    var authorId = _text(json, ['authorId', 'userId', 'cognitoId', 'user_id']);
    if (authorId.isEmpty && author != null) {
      authorId = _text(author, ['id', 'sub', 'cognitoId']);
    }

    return ForumPost(
      id: json['id'] as String? ?? '',
      title: _text(json, ['title', 'subject', 'topic']),
      content: _text(json, ['content', 'body', 'text', 'message']),
      authorName: authorName.isNotEmpty ? authorName : 'Anonymous',
      authorId: authorId,
      createdAt: _date(json['createdAt']) ??
          _date(json['created_at']) ??
          _date(json['timestamp']) ??
          DateTime.now(),
      updatedAt: _date(json['updatedAt']) ?? _date(json['updated_at']),
      commentCount: json['commentCount'] as int? ??
          json['commentsCount'] as int? ??
          json['replyCount'] as int?,
      isThread: json['isThread'] as bool? ?? json['thread'] as bool?,
    );
  }
}
