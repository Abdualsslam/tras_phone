/// Attachment Picker Widget
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';

class AttachmentPicker extends StatefulWidget {
  final List<String> attachments;
  final Function(List<String>)? onChanged;
  final int maxAttachments;
  final bool allowImages;
  final bool allowFiles;

  const AttachmentPicker({
    super.key,
    required this.attachments,
    this.onChanged,
    this.maxAttachments = 5,
    this.allowImages = true,
    this.allowFiles = false,
  });

  @override
  State<AttachmentPicker> createState() => _AttachmentPickerState();
}

class _AttachmentPickerState extends State<AttachmentPicker> {
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickImage() async {
    if (widget.attachments.length >= widget.maxAttachments) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يمكنك إرفاق ${widget.maxAttachments} ملفات كحد أقصى'),
        ),
      );
      return;
    }

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        final updated = [...widget.attachments, image.path];
        widget.onChanged?.call(updated);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء اختيار الصورة: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _takePhoto() async {
    if (widget.attachments.length >= widget.maxAttachments) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يمكنك إرفاق ${widget.maxAttachments} ملفات كحد أقصى'),
        ),
      );
      return;
    }

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        final updated = [...widget.attachments, image.path];
        widget.onChanged?.call(updated);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء التقاط الصورة: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _removeAttachment(int index) {
    final updated = List<String>.from(widget.attachments);
    updated.removeAt(index);
    widget.onChanged?.call(updated);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Attachment List
        if (widget.attachments.isNotEmpty)
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: List.generate(widget.attachments.length, (index) {
              return _buildAttachmentPreview(
                widget.attachments[index],
                index,
                isDark,
              );
            }),
          ),
        SizedBox(height: 8.h),
        // Add Button
        if (widget.attachments.length < widget.maxAttachments)
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              if (widget.allowImages) ...[
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(Iconsax.gallery, size: 18.sp),
                  label: const Text('معرض الصور'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _takePhoto,
                  icon: Icon(Iconsax.camera, size: 18.sp),
                  label: const Text('التقاط صورة'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                  ),
                ),
              ],
            ],
          ),
      ],
    );
  }

  Widget _buildAttachmentPreview(
    String path,
    int index,
    bool isDark,
  ) {
    return Stack(
      children: [
        Container(
          width: 80.w,
          height: 80.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: isDark
                  ? AppColors.dividerDark
                  : AppColors.dividerLight,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Image.asset(
              path,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: Icon(Icons.image, size: 24.sp),
                );
              },
            ),
          ),
        ),
        Positioned(
          top: -4,
          right: -4,
          child: CircleAvatar(
            radius: 12.r,
            backgroundColor: AppColors.error,
            child: IconButton(
              padding: EdgeInsets.zero,
              iconSize: 14.sp,
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => _removeAttachment(index),
            ),
          ),
        ),
      ],
    );
  }
}
