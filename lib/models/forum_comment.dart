class ForumComment {
  const ForumComment({
    required this.id,
    required this.postId,
    required this.content,
    required this.authorName,
    required this.authorId,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String postId;
  final String content;
  final String authorName;
  final String authorId;
  final DateTime createdAt;
  final DateTime? updatedAt;

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

  factory ForumComment.fromJson(Map<String, dynamic> json) {
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

    return ForumComment(
      id: json['id'] as String? ?? '',
      postId: _text(json, ['postId', 'post_id']),
      content: _text(json, ['content', 'body', 'text', 'message']),
      authorName: authorName.isNotEmpty ? authorName : 'Anonymous',
      authorId: authorId,
      createdAt: _date(json['createdAt']) ??
          _date(json['created_at']) ??
          _date(json['timestamp']) ??
          DateTime.now(),
      updatedAt: _date(json['updatedAt']) ?? _date(json['updated_at']),
    );
  }
}
