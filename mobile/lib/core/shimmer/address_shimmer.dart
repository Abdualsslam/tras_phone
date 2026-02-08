/// Address Shimmer - Loading placeholder for address selection screen
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'shimmer_base.dart';

/// Shimmer for address selection screen
class AddressListShimmer extends StatelessWidget {
  const AddressListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: 4,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) => const ShimmerAddressCard(),
    );
  }
}
