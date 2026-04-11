part of 'checkout_sections.dart';

class CheckoutAddressSection extends StatelessWidget {
  final bool isDark;
  final List<AddressEntity> addresses;
  final String? selectedAddressId;
  final String addAddressLabel;
  final VoidCallback onAddAddress;
  final ValueChanged<AddressEntity> onSelectAddress;

  const CheckoutAddressSection({
    super.key,
    required this.isDark,
    required this.addresses,
    required this.selectedAddressId,
    required this.addAddressLabel,
    required this.onAddAddress,
    required this.onSelectAddress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (addresses.isEmpty) {
      return _CheckoutSectionContainer(
        isDark: isDark,
        child: Column(
          children: [
            Icon(
              Iconsax.location,
              size: 40.sp,
              color: AppColors.textSecondaryLight,
            ),
            SizedBox(height: 8.h),
            Text(
              'Ù„Ø§ ØªÙˆØ¬Ø¯ Ø¹Ù†Ø§ÙˆÙŠÙ† Ù…ØªØ§Ø­Ø©',
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14.sp),
            ),
            SizedBox(height: 12.h),
            ElevatedButton.icon(
              onPressed: onAddAddress,
              icon: const Icon(Iconsax.add, size: 18),
              label: Text(addAddressLabel),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              ),
            ),
          ],
        ),
      );
    }

    return _CheckoutSectionContainer(
      isDark: isDark,
      child: Column(
        children: [
          ...addresses.map(
            (address) => CheckoutAddressCard(
              address: address,
              isSelected: selectedAddressId == address.id,
              isDark: isDark,
              onTap: () => onSelectAddress(address),
            ),
          ),
          TextButton.icon(
            onPressed: onAddAddress,
            icon: Icon(Iconsax.add, size: 18.sp),
            label: Text(addAddressLabel, style: TextStyle(fontSize: 13.sp)),
          ),
        ],
      ),
    );
  }
}

class CheckoutAddressCard extends StatelessWidget {
  final AddressEntity address;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const CheckoutAddressCard({
    super.key,
    required this.address,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 4.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.cardDark
              : (isSelected
                    ? AppColors.primary.withValues(alpha: 0.04)
                    : AppColors.inputBackgroundLight),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Iconsax.location,
                color: AppColors.primary,
                size: 22.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        address.label,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (address.isDefault) ...[
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            'Ø§ÙØªØ±Ø§Ø¶ÙŠ',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    address.addressLine,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondaryLight,
                      fontSize: 12.sp,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (address.cityName != null || address.phone != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      [
                        if (address.cityName != null) address.cityName!,
                        if (address.phone != null) address.phone!,
                      ].join(' â€¢ '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiaryLight,
                        fontSize: 11.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textTertiaryLight,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
