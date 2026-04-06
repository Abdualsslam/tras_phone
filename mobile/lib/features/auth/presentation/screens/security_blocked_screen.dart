library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/security/app_security_models.dart';

class SecurityBlockedScreen extends StatelessWidget {
  const SecurityBlockedScreen({super.key, required this.assessment});

  final AppSecurityAssessment assessment;

  @override
  Widget build(BuildContext context) {
    final reasons = assessment.reasons.isEmpty
        ? const <String>['تم اكتشاف مؤشرات أمنية غير موثوقة على هذا الجهاز']
        : assessment.reasons;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 64.w,
                    height: 64.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: const Icon(
                      Icons.security_rounded,
                      color: Color(0xFFD32F2F),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'تم إيقاف التطبيق لحماية حسابك',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'تم اكتشاف بيئة تشغيل غير موثوقة أو تم العبث بالتطبيق. نمنع المتابعة في نسخ الإنتاج لحماية بياناتك وجلساتك.',
                    style: TextStyle(
                      fontSize: 15.sp,
                      height: 1.6,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'المؤشرات المكتشفة',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  ...reasons.map(
                    (reason) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 6.h),
                            child: Container(
                              width: 6.w,
                              height: 6.w,
                              decoration: const BoxDecoration(
                                color: Color(0xFFD32F2F),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              reason,
                              style: TextStyle(
                                fontSize: 14.sp,
                                height: 1.5,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F8FA),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Text(
                      'إذا كان الجهاز سليمًا، تواصل مع فريق الدعم الأمني عبر ${AppConfig.securitySupportEmail}.',
                      style: TextStyle(
                        fontSize: 13.sp,
                        height: 1.6,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
