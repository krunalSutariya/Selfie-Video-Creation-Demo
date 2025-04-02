import 'package:equatable/equatable.dart';

class Video extends Equatable {
  final String id;
  final String title;
  final String description;
  final String path;
  final String teleprompterText;
  final DateTime createdAt;
  final String thumbnailPath;

  const Video({
    required this.id,
    required this.title,
    required this.description,
    required this.path,
    required this.teleprompterText,
    required this.createdAt,
    this.thumbnailPath = '',
  });

  @override
  List<Object?> get props => [
    id, 
    title, 
    description, 
    path, 
    teleprompterText, 
    createdAt, 
    thumbnailPath
  ];
}

