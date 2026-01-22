/// Educational Content Entity
library;

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'educational_category_entity.dart';

enum ContentType {
  article,
  video,
  tutorial,
  tip,
  guide;

  String get value {
    switch (this) {
      case ContentType.article:
        return 'article';
      case ContentType.video:
        return 'video';
      case ContentType.tutorial:
        return 'tutorial';
      case ContentType.tip:
        return 'tip';
      case ContentType.guide:
        return 'guide';
    }
  }

  String getName(String locale) {
    switch (this) {
      case ContentType.article:
        return locale == 'ar' ? 'مقال' : 'Article';
      case ContentType.video:
        return locale == 'ar' ? 'فيديو' : 'Video';
      case ContentType.tutorial:
        return locale == 'ar' ? 'دليل' : 'Tutorial';
      case ContentType.tip:
        return locale == 'ar' ? 'نصيحة' : 'Tip';
      case ContentType.guide:
        return locale == 'ar' ? 'مرشد' : 'Guide';
    }
  }

  IconData get icon {
    switch (this) {
      case ContentType.article:
        return Icons.article;
      case ContentType.video:
        return Icons.video_library;
      case ContentType.tutorial:
        return Icons.school;
      case ContentType.tip:
        return Icons.lightbulb;
      case ContentType.guide:
        return Icons.menu_book;
    }
  }
}

enum ContentDifficulty {
  beginner,
  intermediate,
  advanced;

  String get value {
    switch (this) {
      case ContentDifficulty.beginner:
        return 'beginner';
      case ContentDifficulty.intermediate:
        return 'intermediate';
      case ContentDifficulty.advanced:
        return 'advanced';
    }
  }

  String getName(String locale) {
    switch (this) {
      case ContentDifficulty.beginner:
        return locale == 'ar' ? 'مبتدئ' : 'Beginner';
      case ContentDifficulty.intermediate:
        return locale == 'ar' ? 'متوسط' : 'Intermediate';
      case ContentDifficulty.advanced:
        return locale == 'ar' ? 'متقدم' : 'Advanced';
    }
  }

  Color get color {
    switch (this) {
      case ContentDifficulty.beginner:
        return Colors.green;
      case ContentDifficulty.intermediate:
        return Colors.orange;
      case ContentDifficulty.advanced:
        return Colors.red;
    }
  }
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

  /// الحصول على العنوان حسب اللغة
  String getTitle(String locale) =>
      locale == 'ar' && titleAr != null ? titleAr! : title;

  /// الحصول على الملخص حسب اللغة
  String? getExcerpt(String locale) =>
      locale == 'ar' && excerptAr != null ? excerptAr : excerpt;

  /// الحصول على المحتوى حسب اللغة
  String getContentText(String locale) =>
      locale == 'ar' && contentAr != null ? contentAr! : content;

  /// هل المحتوى منشور؟
  bool get isPublished => status == 'published';

  /// هل يحتوي على فيديو؟
  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;

  /// مدة الفيديو بصيغة قابلة للقراءة
  String? get videoDurationFormatted {
    if (videoDuration == null) return null;
    final minutes = videoDuration! ~/ 60;
    final seconds = videoDuration! % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  /// وقت القراءة بصيغة قابلة للقراءة
  String get readingTimeFormatted {
    if (readingTime == null) return '';
    return readingTime == 1
        ? 'دقيقة واحدة'
        : '$readingTime دقائق';
  }
}
