class VideoModel {
  final String id;
  final String title;
  final String description;
  final String path;
  final String teleprompterText;
  final DateTime createdAt;
  final String thumbnailPath;

  VideoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.path,
    required this.teleprompterText,
    required this.createdAt,
    this.thumbnailPath = '',
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      path: json['path'],
      teleprompterText: json['teleprompterText'],
      createdAt: DateTime.parse(json['createdAt']),
      thumbnailPath: json['thumbnailPath'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'path': path,
      'teleprompterText': teleprompterText,
      'createdAt': createdAt.toIso8601String(),
      'thumbnailPath': thumbnailPath,
    };
  }
}

