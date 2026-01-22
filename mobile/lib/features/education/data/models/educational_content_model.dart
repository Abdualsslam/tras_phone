/// Educational Content Model
library;

import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/educational_content_entity.dart';
import 'educational_category_model.dart';

part 'educational_content_model.g.dart';

@JsonSerializable()
class EducationalContentModel {
  @JsonKey(name: '_id')
  final String id;
  final String title;
  final String? titleAr;
  final String slug;
  @JsonKey(name: 'categoryId')
  final dynamic category; // Can be String or EducationalCategoryModel
  final String type;
  final String? excerpt;
  final String? excerptAr;
  final String content;
  final String? contentAr;
  final String? featuredImage;
  final String? videoUrl;
  final int? videoDuration;
  final List<String> attachments;
  @JsonKey(name: 'relatedProducts')
  final dynamic relatedProducts; // Can be List<String> or List<Map>
  @JsonKey(name: 'relatedContent')
  final dynamic relatedContent; // Can be List<String> or List<Map>
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
  final String difficulty;
  final String? createdBy;
  final String? updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EducationalContentModel({
    required this.id,
    required this.title,
    this.titleAr,
    required this.slug,
    required this.category,
    required this.type,
    this.excerpt,
    this.excerptAr,
    required this.content,
    this.contentAr,
    this.featuredImage,
    this.videoUrl,
    this.videoDuration,
    required this.attachments,
    this.relatedProducts,
    this.relatedContent,
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

  factory EducationalContentModel.fromJson(Map<String, dynamic> json) =>
      _$EducationalContentModelFromJson(json);

  Map<String, dynamic> toJson() => _$EducationalContentModelToJson(this);

  EducationalContentEntity toEntity() {
    // Extract category ID
    String categoryId;
    EducationalCategoryModel? categoryModel;
    
    if (category is String) {
      categoryId = category as String;
    } else if (category is Map<String, dynamic>) {
      categoryModel = EducationalCategoryModel.fromJson(category);
      categoryId = categoryModel.id;
    } else {
      categoryId = '';
    }

    // Parse related products (can be strings or objects)
    List<String> parsedRelatedProducts = [];
    if (relatedProducts != null) {
      if (relatedProducts is List) {
        for (var product in relatedProducts) {
          if (product is String) {
            parsedRelatedProducts.add(product);
          } else if (product is Map<String, dynamic>) {
            // Extract ID from populated product object
            final productId = product['_id'] ?? product['id'];
            if (productId != null) {
              parsedRelatedProducts.add(productId.toString());
            }
          }
        }
      }
    }

    // Parse related content (can be strings or objects)
    List<String> parsedRelatedContent = [];
    if (relatedContent != null) {
      if (relatedContent is List) {
        for (var contentItem in relatedContent) {
          if (contentItem is String) {
            parsedRelatedContent.add(contentItem);
          } else if (contentItem is Map<String, dynamic>) {
            // Extract ID from populated content object
            final contentId = contentItem['_id'] ?? contentItem['id'];
            if (contentId != null) {
              parsedRelatedContent.add(contentId.toString());
            }
          }
        }
      }
    }

    // Parse content type
    ContentType contentType;
    switch (type.toLowerCase()) {
      case 'article':
        contentType = ContentType.article;
        break;
      case 'video':
        contentType = ContentType.video;
        break;
      case 'tutorial':
        contentType = ContentType.tutorial;
        break;
      case 'tip':
        contentType = ContentType.tip;
        break;
      case 'guide':
        contentType = ContentType.guide;
        break;
      default:
        contentType = ContentType.article;
    }

    // Parse difficulty
    ContentDifficulty contentDifficulty;
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        contentDifficulty = ContentDifficulty.beginner;
        break;
      case 'intermediate':
        contentDifficulty = ContentDifficulty.intermediate;
        break;
      case 'advanced':
        contentDifficulty = ContentDifficulty.advanced;
        break;
      default:
        contentDifficulty = ContentDifficulty.beginner;
    }

    return EducationalContentEntity(
      id: id,
      title: title,
      titleAr: titleAr,
      slug: slug,
      categoryId: categoryId,
      category: categoryModel?.toEntity(),
      type: contentType,
      excerpt: excerpt,
      excerptAr: excerptAr,
      content: content,
      contentAr: contentAr,
      featuredImage: featuredImage,
      videoUrl: videoUrl,
      videoDuration: videoDuration,
      attachments: attachments,
      relatedProducts: parsedRelatedProducts,
      relatedContent: parsedRelatedContent,
      tags: tags,
      metaTitle: metaTitle,
      metaDescription: metaDescription,
      status: status,
      publishedAt: publishedAt,
      isFeatured: isFeatured,
      viewCount: viewCount,
      likeCount: likeCount,
      shareCount: shareCount,
      readingTime: readingTime,
      difficulty: contentDifficulty,
      createdBy: createdBy,
      updatedBy: updatedBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
