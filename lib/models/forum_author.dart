class ForumAuthor {
  final String id;
  final String name;

  const ForumAuthor({
    required this.id,
    required this.name,
  });

  factory ForumAuthor.fromJson(Map<String, dynamic> json) {
    return ForumAuthor(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
    );
  }
}
