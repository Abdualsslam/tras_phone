// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'educational_content_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EducationalContentModel _$EducationalContentModelFromJson(
  Map<String, dynamic> json,
) => EducationalContentModel(
  id: json['_id'] as String,
  title: json['title'] as String,
  titleAr: json['titleAr'] as String?,
  slug: json['slug'] as String,
  category: json['categoryId'],
  type: json['type'] as String,
  excerpt: json['excerpt'] as String?,
  excerptAr: json['excerptAr'] as String?,
  content: json['content'] as String,
  contentAr: json['contentAr'] as String?,
  featuredImage: json['featuredImage'] as String?,
  videoUrl: json['videoUrl'] as String?,
  videoDuration: (json['videoDuration'] as num?)?.toInt(),
  attachments: (json['attachments'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  relatedProducts: json['relatedProducts'],
  relatedContent: json['relatedContent'],
  tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
  metaTitle: json['metaTitle'] as String?,
  metaDescription: json['metaDescription'] as String?,
  status: json['status'] as String,
  publishedAt: json['publishedAt'] == null
      ? null
      : DateTime.parse(json['publishedAt'] as String),
  isFeatured: json['isFeatured'] as bool,
  viewCount: (json['viewCount'] as num).toInt(),
  likeCount: (json['likeCount'] as num).toInt(),
  shareCount: (json['shareCount'] as num).toInt(),
  readingTime: (json['readingTime'] as num?)?.toInt(),
  difficulty: json['difficulty'] as String,
  createdBy: json['createdBy'] as String?,
  updatedBy: json['updatedBy'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$EducationalContentModelToJson(
  EducationalContentModel instance,
) => <String, dynamic>{
  '_id': instance.id,
  'title': instance.title,
  'titleAr': instance.titleAr,
  'slug': instance.slug,
  'categoryId': instance.category,
  'type': instance.type,
  'excerpt': instance.excerpt,
  'excerptAr': instance.excerptAr,
  'content': instance.content,
  'contentAr': instance.contentAr,
  'featuredImage': instance.featuredImage,
  'videoUrl': instance.videoUrl,
  'videoDuration': instance.videoDuration,
  'attachments': instance.attachments,
  'relatedProducts': instance.relatedProducts,
  'relatedContent': instance.relatedContent,
  'tags': instance.tags,
  'metaTitle': instance.metaTitle,
  'metaDescription': instance.metaDescription,
  'status': instance.status,
  'publishedAt': instance.publishedAt?.toIso8601String(),
  'isFeatured': instance.isFeatured,
  'viewCount': instance.viewCount,
  'likeCount': instance.likeCount,
  'shareCount': instance.shareCount,
  'readingTime': instance.readingTime,
  'difficulty': instance.difficulty,
  'createdBy': instance.createdBy,
  'updatedBy': instance.updatedBy,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
