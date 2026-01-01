import 'package:flutter/material.dart';
import 'package:grampulse/features/map/domain/models/category_model.dart';

class MediaModel {
  final String? id;
  final String? url;
  final String? thumbnailUrl;
  final String? localPath;
  final MediaType type;
  
  const MediaModel({
    this.id,
    this.url,
    this.thumbnailUrl,
    this.localPath,
    required this.type,
  });
}

enum MediaType { image, video, audio }

class IssueModel {
  final String id;
  final String title;
  final String description;
  final CategoryModel category;
  final String status;
  final DateTime createdAt;
  final double latitude;
  final double longitude;
  final String? address;
  final List<MediaModel> media;
  final int severity;
  final String reporterId;
  
  const IssueModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.createdAt,
    required this.latitude,
    required this.longitude,
    this.address,
    required this.media,
    required this.severity,
    required this.reporterId,
  });
}
