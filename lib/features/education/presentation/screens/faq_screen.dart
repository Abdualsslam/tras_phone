/// FAQ Screen - Frequently asked questions
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final categories = [
      _FaqCategory(
        title: 'الطلبات والشحن',
        icon: Iconsax.truck,
        faqs: [
          _Faq(
            question: 'كيف يمكنني تتبع طلبي؟',
            answer:
                'يمكنك تتبع طلبك من خلال صفحة "طلباتي" في التطبيق. اضغط على الطلب المراد تتبعه لرؤية حالته الحالية وموقعه.',
          ),
          _Faq(
            question: 'ما هي مدة التوصيل؟',
            answer:
                'يتم التوصيل خلال 3-5 أيام عمل داخل المملكة العربية السعودية. قد تختلف المدة للمناطق النائية.',
          ),
          _Faq(
            question: 'هل يمكنني تغيير عنوان التوصيل بعد الطلب؟',
            answer:
                'نعم، يمكنك تغيير عنوان التوصيل قبل شحن الطلب. تواصل معنا عبر الدعم الفني لتحديث العنوان.',
          ),
        ],
      ),
      _FaqCategory(
        title: 'الدفع والفواتير',
        icon: Iconsax.card,
        faqs: [
          _Faq(
            question: 'ما هي طرق الدفع المتاحة؟',
            answer:
                'نوفر الدفع عند الاستلام، التحويل البنكي، والدفع من المحفظة.',
          ),
          _Faq(
            question: 'كيف أحصل على الفاتورة؟',
            answer:
                'يتم إرسال الفاتورة تلقائياً على رقم جوالك بعد إتمام الطلب. كما يمكنك تحميلها من صفحة تفاصيل الطلب.',
          ),
        ],
      ),
      _FaqCategory(
        title: 'الإرجاع والاستبدال',
        icon: Iconsax.rotate_left,
        faqs: [
          _Faq(
            question: 'ما هي سياسة الإرجاع؟',
            answer:
                'يمكنك إرجاع المنتج خلال 7 أيام من الاستلام بشرط أن يكون في حالته الأصلية وبتغليفه الأصلي.',
          ),
          _Faq(
            question: 'كيف أطلب إرجاع منتج؟',
            answer:
                'من صفحة "المرتجعات" في حسابك، اضغط على "طلب إرجاع جديد" واتبع الخطوات.',
          ),
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.faq)),
      body: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: categories.length,
        itemBuilder: (context, categoryIndex) {
          final category = categories[categoryIndex];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (categoryIndex > 0) SizedBox(height: 24.h),
              // Category Header
              Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      category.icon,
                      color: AppColors.primary,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    category.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              // FAQs
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  children: category.faqs.asMap().entries.map((entry) {
                    final isLast = entry.key == category.faqs.length - 1;
                    return Column(
                      children: [
                        _buildFaqItem(theme, entry.value),
                        if (!isLast)
                          Divider(height: 1, color: AppColors.dividerLight),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFaqItem(ThemeData theme, _Faq faq) {
    return ExpansionTile(
      title: Text(
        faq.question,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      childrenPadding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          faq.answer,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondaryLight,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

class _FaqCategory {
  final String title;
  final IconData icon;
  final List<_Faq> faqs;

  _FaqCategory({required this.title, required this.icon, required this.faqs});
}

class _Faq {
  final String question;
  final String answer;

  _Faq({required this.question, required this.answer});
}
