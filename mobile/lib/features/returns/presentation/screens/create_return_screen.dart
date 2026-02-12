/// Create Return Screen - Submit a return request
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../data/models/return_model.dart';
import '../../domain/entities/return_entity.dart';
import '../../domain/enums/return_enums.dart';
import '../cubit/create_return_cubit.dart';
import '../cubit/create_return_state.dart';
import '../widgets/image_uploader.dart';

class CreateReturnScreen extends StatefulWidget {
  /// Pre-selected items from SelectItemsForReturnScreen
  final List<CreateReturnItemRequest>? preSelectedItems;

  const CreateReturnScreen({super.key, this.preSelectedItems});

  @override
  State<CreateReturnScreen> createState() => _CreateReturnScreenState();
}

class _CreateReturnScreenState extends State<CreateReturnScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<CreateReturnCubit>()..loadReasons(),
      child: BlocListener<CreateReturnCubit, CreateReturnState>(
        listener: (context, state) {
          if (state is CreateReturnSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('تم إرسال طلب الإرجاع بنجاح'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.pushReplacement('/return/${state.returnRequest.id}');
          } else if (state is CreateReturnError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: _CreateReturnView(preSelectedItems: widget.preSelectedItems),
      ),
    );
  }
}

class _CreateReturnView extends StatefulWidget {
  final List<CreateReturnItemRequest>? preSelectedItems;

  const _CreateReturnView({this.preSelectedItems});

  @override
  State<_CreateReturnView> createState() => _CreateReturnViewState();
}

class _CreateReturnViewState extends State<_CreateReturnView> {
  final _formKey = GlobalKey<FormState>();
  ReturnType _selectedType = ReturnType.refund;
  ReturnReasonEntity? _selectedReason;
  final _notesController = TextEditingController();
  List<String> _uploadedImages = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final preSelectedItems = widget.preSelectedItems ?? [];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('طلب إرجاع'),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_3),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<CreateReturnCubit, CreateReturnState>(
        builder: (context, state) {
          if (state is CreateReturnLoading) {
            _isSubmitting = true;
          } else {
            _isSubmitting = false;
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selected Items Info
                  if (preSelectedItems.isNotEmpty)
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.cardDark
                            : AppColors.cardLight,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50.w,
                            height: 50.w,
                            decoration: BoxDecoration(
                              color: AppColors.backgroundLight,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(
                              Iconsax.box,
                              color: AppColors.textTertiaryLight,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'المنتجات المحددة',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${preSelectedItems.length} منتج',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.textTertiaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (preSelectedItems.isNotEmpty) SizedBox(height: 24.h),

                  // Return Type
                  Text(
                    'نوع الإرجاع',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: ReturnType.values.map((type) {
                      return ChoiceChip(
                        label: Text(type.displayNameAr),
                        selected: _selectedType == type,
                        onSelected: (_) => setState(() => _selectedType = type),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16.h),

                  // Reason
                  Text(
                    'سبب الإرجاع',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  BlocBuilder<CreateReturnCubit, CreateReturnState>(
                    builder: (context, state) {
                      if (state is CreateReturnReasonsLoaded) {
                        return DropdownButtonFormField<ReturnReasonEntity>(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            filled: true,
                            fillColor: isDark
                                ? AppColors.cardDark
                                : AppColors.cardLight,
                            hintText: 'اختر السبب',
                          ),
                          initialValue: _selectedReason,
                          items: state.reasons.where((r) => r.isActive).map((
                            reason,
                          ) {
                            return DropdownMenuItem(
                              value: reason,
                              child: Text(reason.getName('ar')),
                            );
                          }).toList(),
                          onChanged: (reason) =>
                              setState(() => _selectedReason = reason),
                          validator: (value) {
                            if (value == null) {
                              return 'يرجى اختيار سبب الإرجاع';
                            }
                            return null;
                          },
                        );
                      }
                      return const SizedBox(
                        height: 56,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                  ),
                  SizedBox(height: 16.h),

                  // Images (if required)
                  BlocBuilder<CreateReturnCubit, CreateReturnState>(
                    builder: (context, state) {
                      if (state is CreateReturnReasonsLoaded &&
                          _selectedReason?.requiresPhoto == true) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'صور المنتج',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  '*',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            ImageUploader(
                              images: _uploadedImages,
                              onImagesChanged: (images) {
                                setState(() => _uploadedImages = images);
                              },
                              required: true,
                            ),
                            SizedBox(height: 16.h),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  // Optional Images
                  if (_selectedReason?.requiresPhoto != true)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'صور المنتج (اختياري)',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        ImageUploader(
                          images: _uploadedImages,
                          onImagesChanged: (images) {
                            setState(() => _uploadedImages = images);
                          },
                        ),
                        SizedBox(height: 16.h),
                      ],
                    ),

                  // Notes
                  Text(
                    'تفاصيل إضافية',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'اشرح سبب الإرجاع بالتفصيل...',
                      filled: true,
                      fillColor: isDark
                          ? AppColors.cardDark
                          : AppColors.cardLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Policy Notice
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Iconsax.info_circle,
                          color: Colors.orange,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'سياسة الإرجاع: يجب أن يكون المنتج في حالته الأصلية',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.orange[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Submit
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => _submitReturn(context, preSelectedItems),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('إرسال طلب الإرجاع'),
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

  Future<void> _submitReturn(
    BuildContext context,
    List<CreateReturnItemRequest> preSelectedItems,
  ) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (preSelectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا توجد منتجات محددة للإرجاع'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار سبب الإرجاع'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedReason!.requiresPhoto && _uploadedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إرفاق صور للمنتج'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final cubit = context.read<CreateReturnCubit>();

    // Upload images first if any
    List<String> imageUrls = [];
    if (_uploadedImages.isNotEmpty) {
      imageUrls = await cubit.uploadImages(_uploadedImages);
      if (imageUrls.isEmpty) {
        // Error already shown by cubit
        return;
      }
    }

    // Create return request
    final request = CreateReturnRequest(
      returnType: _selectedType.toApiString(),
      reasonId: _selectedReason!.id,
      items: preSelectedItems,
      customerNotes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
      customerImages: imageUrls.isNotEmpty ? imageUrls : null,
    );

    await cubit.createReturn(request);
  }
}
