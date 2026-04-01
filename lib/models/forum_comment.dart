class ForumComment {
  final String id;
  final String postId;
  final String authorId;
  final String? parentCommentId;
  final String authorName;
  final String content;
  final String createdAt;
  final String updatedAt;
  final List<ForumComment> replies;

  const ForumComment({
    required this.id,
    required this.postId,
    required this.authorId,
    this.parentCommentId,
    this.authorName = 'Member',
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.replies = const [],
  });

  factory ForumComment.fromJson(Map<String, dynamic> json) {
    final rawReplies = json['replies'];
    final replies = <ForumComment>[];
    if (rawReplies is List) {
      for (final item in rawReplies) {
        if (item is Map<String, dynamic>) {
          replies.add(ForumComment.fromJson(item));
        }
      }
    }
    final author = json['author'];
    return ForumComment(
      id: json['id'] as String? ?? '',
      postId: json['postId'] as String? ?? '',
      authorId: json['authorId'] as String? ?? '',
      parentCommentId: json['parentCommentId'] as String?,
      authorName: (author is Map<String, dynamic> ? author['name'] : null)
              as String? ??
          'Member',
      content: (json['body'] as String?) ?? (json['content'] as String?) ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      replies: replies,
    );
  }
}
