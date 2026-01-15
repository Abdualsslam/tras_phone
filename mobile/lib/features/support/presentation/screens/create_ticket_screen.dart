/// Create Ticket Screen - Create new support ticket
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../data/models/support_model.dart';
import '../cubit/support_cubit.dart';

class CreateTicketScreen extends StatefulWidget {
  final String? orderId;
  final String? productId;

  const CreateTicketScreen({
    super.key,
    this.orderId,
    this.productId,
  });

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  TicketCategoryModel? _selectedCategory;
  TicketPriority _selectedPriority = TicketPriority.medium;
  final List<String> _attachments = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    context.read<SupportCubit>().loadCategories();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('تذكرة جديدة'),
        leading: IconButton(
          icon: const Icon(Iconsax.close_circle),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<SupportCubit, SupportState>(
        listener: (context, state) {
          if (state.status == SupportStatus.error && state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Selection
                  Text(
                    'التصنيف',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  if (state.status == SupportStatus.loading &&
                      state.categories.isEmpty)
                    const Center(child: CircularProgressIndicator())
                  else
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: state.categories.map((cat) {
                        final isSelected = _selectedCategory?.id == cat.id;
                        return ChoiceChip(
                          label: Text(cat.getName('ar')),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() => _selectedCategory = cat);
                          },
                          selectedColor: AppColors.primary.withValues(alpha: 0.2),
                          labelStyle: TextStyle(
                            color:
                                isSelected ? AppColors.primary : null,
                            fontWeight:
                                isSelected ? FontWeight.w600 : null,
                          ),
                        );
                      }).toList(),
                    ),
                  SizedBox(height: 16.h),

                  // Priority Selection
                  Text(
                    'الأولوية',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: TicketPriority.values.map((priority) {
                      final isSelected = _selectedPriority == priority;
                      return ChoiceChip(
                        label: Text(priority.displayNameAr),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() => _selectedPriority = priority);
                        },
                        selectedColor: priority.color.withValues(alpha: 0.2),
                        labelStyle: TextStyle(
                          color: isSelected ? priority.color : null,
                          fontWeight: isSelected ? FontWeight.w600 : null,
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16.h),

                  // Subject
                  Text(
                    'الموضوع',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: _subjectController,
                    validator: (value) =>
                        value?.isEmpty == true ? 'هذا الحقل مطلوب' : null,
                    decoration: InputDecoration(
                      hintText: 'اكتب عنوان المشكلة',
                      filled: true,
                      fillColor:
                          isDark ? AppColors.cardDark : AppColors.cardLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Description
                  Text(
                    'الوصف',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 5,
                    maxLength: 1000,
                    validator: (value) =>
                        value?.isEmpty == true ? 'هذا الحقل مطلوب' : null,
                    decoration: InputDecoration(
                      hintText: 'اشرح مشكلتك بالتفصيل...',
                      filled: true,
                      fillColor:
                          isDark ? AppColors.cardDark : AppColors.cardLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Order ID notice
                  if (widget.orderId != null)
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          Icon(Iconsax.shopping_bag,
                              color: AppColors.info, size: 20.sp),
                          SizedBox(width: 8.w),
                          Text(
                            'مرتبطة بالطلب: ${widget.orderId}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.info,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (widget.orderId != null) SizedBox(height: 16.h),

                  // Attachments
                  Text(
                    'المرفقات (اختياري)',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  GestureDetector(
                    onTap: _pickAttachments,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.dividerLight,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Iconsax.document_upload,
                            size: 40.sp,
                            color: AppColors.textTertiaryLight,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'اضغط لإرفاق صور أو ملفات',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textTertiaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_attachments.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: _attachments.map((url) {
                        return Chip(
                          label: Text(
                            url.split('/').last,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          deleteIcon:
                              Icon(Iconsax.close_circle, size: 16.sp),
                          onDeleted: () {
                            setState(() => _attachments.remove(url));
                          },
                        );
                      }).toList(),
                    ),
                  ],
                  SizedBox(height: 32.h),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitTicket,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: _isSubmitting
                          ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('إرسال التذكرة'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickAttachments() async {
    // TODO: Implement file picker
    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('سيتم إضافة هذه الميزة قريباً'),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  Future<void> _submitTicket() async {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('اختر تصنيف التذكرة'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      final ticket = await context.read<SupportCubit>().createTicket(
            categoryId: _selectedCategory!.id,
            subject: _subjectController.text,
            description: _descriptionController.text,
            priority: _selectedPriority,
            orderId: widget.orderId,
            productId: widget.productId,
            attachments: _attachments.isNotEmpty ? _attachments : null,
          );

      setState(() => _isSubmitting = false);

      if (ticket != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('تم إرسال التذكرة بنجاح'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        );
        context.pop();
      }
    }
  }
}
