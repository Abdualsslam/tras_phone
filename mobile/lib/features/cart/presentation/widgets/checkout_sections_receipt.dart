part of 'checkout_sections.dart';

class CheckoutTransferReceiptSection extends StatelessWidget {
  final bool isDark;
  final String? receiptImagePath;
  final TextEditingController transferNotesController;
  final VoidCallback onPickImage;
  final VoidCallback onClearImage;

  const CheckoutTransferReceiptSection({
    super.key,
    required this.isDark,
    required this.receiptImagePath,
    required this.transferNotesController,
    required this.onPickImage,
    required this.onClearImage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ã˜Â¥Ã™Å Ã˜ÂµÃ˜Â§Ã™â€ž Ã˜Â§Ã™â€žÃ˜ÂªÃ˜Â­Ã™Ë†Ã™Å Ã™â€ž (Ã™â€¦Ã˜Â·Ã™â€žÃ™Ë†Ã˜Â¨)',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: onPickImage,
            child: Container(
              height: 170.h,
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: receiptImagePath != null
                      ? AppColors.primary
                      : (isDark
                            ? AppColors.dividerDark
                            : AppColors.dividerLight),
                ),
              ),
              child: receiptImagePath == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.gallery_add,
                          size: 36.sp,
                          color: AppColors.textTertiaryLight,
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          'Ã˜Â§Ã˜Â¶Ã˜ÂºÃ˜Â· Ã™â€žÃ˜Â§Ã˜Â®Ã˜ÂªÃ™Å Ã˜Â§Ã˜Â± Ã˜ÂµÃ™Ë†Ã˜Â±Ã˜Â© Ã˜Â§Ã™â€žÃ˜Â¥Ã™Å Ã˜ÂµÃ˜Â§Ã™â€ž',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'PNG, JPG Ã˜Â­Ã˜ÂªÃ™â€° 10 MB',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiaryLight,
                          ),
                        ),
                      ],
                    )
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.r),
                          child: Image.file(
                            File(receiptImagePath!),
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8.h,
                          left: 8.w,
                          child: GestureDetector(
                            onTap: onClearImage,
                            child: Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                size: 14.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          SizedBox(height: 14.h),
          TextField(
            controller: transferNotesController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText:
                  'Ã™â€¦Ã™â€žÃ˜Â§Ã˜Â­Ã˜Â¸Ã˜Â§Ã˜Âª Ã˜Â§Ã™â€žÃ˜ÂªÃ˜Â­Ã™Ë†Ã™Å Ã™â€ž (Ã˜Â§Ã˜Â®Ã˜ÂªÃ™Å Ã˜Â§Ã˜Â±Ã™Å )',
              hintText:
                  'Ã˜Â£Ã™Å  Ã˜ÂªÃ™ÂÃ˜Â§Ã˜ÂµÃ™Å Ã™â€ž Ã˜Â¥Ã˜Â¶Ã˜Â§Ã™ÂÃ™Å Ã˜Â© Ã˜Â¹Ã™â€  Ã˜Â¹Ã™â€¦Ã™â€žÃ™Å Ã˜Â© Ã˜Â§Ã™â€žÃ˜ÂªÃ˜Â­Ã™Ë†Ã™Å Ã™â€ž',
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            'Ã˜Â³Ã˜ÂªÃ˜Â¬Ã˜Â¯ Ã˜Â§Ã™â€žÃ˜Â¨Ã™â€ Ã™Ë†Ã™Æ’ Ã˜Â§Ã™â€žÃ™â€¦Ã˜Â¯Ã˜Â¹Ã™Ë†Ã™â€¦Ã˜Â© Ã˜ÂªÃ˜Â­Ã˜Âª Ã˜Â®Ã™Å Ã˜Â§Ã˜Â± "Ã˜ÂªÃ˜Â­Ã™Ë†Ã™Å Ã™â€ž Ã˜Â¨Ã™â€ Ã™Æ’Ã™Å " Ã˜Â¨Ã˜Â§Ã™â€žÃ˜Â£Ã˜Â¹Ã™â€žÃ™â€°.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
