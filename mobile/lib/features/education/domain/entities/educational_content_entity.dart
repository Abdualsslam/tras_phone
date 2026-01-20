/// Educational Content Entity
library;

import 'package:equatable/equatable.dart';
import 'educational_category_entity.dart';

enum ContentType {
  article,
  video,
  tutorial,
  tip,
  guide,
}

enum ContentDifficulty {
  beginner,
  intermediate,
  advanced,
}

class EducationalContentEntity extends Equatable {
  final String id;
  final String title;
  final String? titleAr;
  final String slug;
  final String categoryId;
  final EducationalCategoryEntity? category;
  final ContentType type;
  final String? excerpt;
  final String? excerptAr;
  final String content;
  final String? contentAr;
  final String? featuredImage;
  final String? videoUrl;
  final int? videoDuration;
  final List<String> attachments;
  final List<String> relatedProducts;
  final List<String> relatedContent;
  final List<String> tags;
  final String? metaTitle;
  final String? metaDescription;
  final String status;
  final DateTime? publishedAt;
  final bool isFeatured;
  final int viewCount;
  final int likeCount;
  final int shareCount;
  final int? readingTime;
  final ContentDifficulty difficulty;
  final String? createdBy;
  final String? updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EducationalContentEntity({
    required this.id,
    required this.title,
    this.titleAr,
    required this.slug,
    required this.categoryId,
    this.category,
    required this.type,
    this.excerpt,
    this.excerptAr,
    required this.content,
    this.contentAr,
    this.featuredImage,
    this.videoUrl,
    this.videoDuration,
    required this.attachments,
    required this.relatedProducts,
    required this.relatedContent,
    required this.tags,
    this.metaTitle,
    this.metaDescription,
    required this.status,
    this.publishedAt,
    required this.isFeatured,
    required this.viewCount,
    required this.likeCount,
    required this.shareCount,
    this.readingTime,
    required this.difficulty,
    this.createdBy,
    this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        titleAr,
        slug,
        categoryId,
        category,
        type,
        excerpt,
        excerptAr,
        content,
        contentAr,
        featuredImage,
        videoUrl,
        videoDuration,
        attachments,
        relatedProducts,
        relatedContent,
        tags,
        metaTitle,
        metaDescription,
        status,
        publishedAt,
        isFeatured,
        viewCount,
        likeCount,
        shareCount,
        readingTime,
        difficulty,
        createdBy,
        updatedBy,
        createdAt,
        updatedAt,
      ];
}
