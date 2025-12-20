/// Static Page Screen - Terms, Privacy, About pages
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';

class StaticPageScreen extends StatelessWidget {
  final String title;
  final String slug;

  const StaticPageScreen({super.key, required this.title, required this.slug});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_3),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getContent(slug),
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.8,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getContent(String slug) {
    switch (slug) {
      case 'terms':
        return '''
الشروط والأحكام

مرحباً بك في تطبيق تراس فون. باستخدامك للتطبيق فإنك توافق على الشروط والأحكام التالية:

1. الحساب والتسجيل
- يجب أن تكون تاجراً مسجلاً للاستفادة من خدماتنا
- أنت مسؤول عن الحفاظ على سرية معلومات حسابك
- يجب أن تكون جميع المعلومات المقدمة صحيحة ودقيقة

2. الطلبات والمدفوعات
- جميع الأسعار بالريال السعودي وقابلة للتغيير
- الدفع مطلوب قبل أو عند التسليم حسب طريقة الدفع المختارة
- نحتفظ بالحق في إلغاء أي طلب لأسباب معينة

3. الشحن والتوصيل
- أوقات التوصيل تقديرية وقد تختلف
- أنت مسؤول عن تقديم عنوان توصيل صحيح
- رسوم الشحن غير قابلة للاسترداد

4. الإرجاع والاستبدال
- يمكن إرجاع المنتجات خلال 7 أيام من الاستلام
- يجب أن تكون المنتجات في حالتها الأصلية
- بعض المنتجات غير قابلة للإرجاع
''';
      case 'privacy':
        return '''
سياسة الخصوصية

نحن في تراس فون نقدر خصوصيتك ونلتزم بحماية بياناتك الشخصية.

1. البيانات التي نجمعها
- معلومات التسجيل (الاسم، رقم الجوال، البريد الإلكتروني)
- معلومات الطلبات وتاريخ الشراء
- بيانات الموقع لأغراض التوصيل

2. كيف نستخدم بياناتك
- لمعالجة طلباتك وتوصيلها
- للتواصل معك بخصوص طلباتك
- لتحسين خدماتنا وتجربة المستخدم
- لإرسال العروض والتحديثات (بموافقتك)

3. مشاركة البيانات
- لا نبيع بياناتك لأطراف ثالثة
- نشارك البيانات الضرورية مع شركات الشحن
- قد نشارك البيانات إذا طُلب قانونياً

4. أمان البيانات
- نستخدم تشفير SSL لحماية البيانات
- نخزن البيانات في خوادم آمنة
- نراجع إجراءاتنا الأمنية بانتظام
''';
      case 'about':
        return '''
عن تراس فون

تراس فون هي منصة متخصصة في بيع قطع غيار الجوالات بالجملة للتجار في المملكة العربية السعودية ودول الخليج.

رؤيتنا
أن نكون المنصة الأولى والأكثر موثوقية لقطع غيار الجوالات في المنطقة.

مهمتنا
توفير قطع غيار أصلية وعالية الجودة بأسعار منافسة مع خدمة عملاء ممتازة.

لماذا تراس فون؟
- منتجات أصلية ومضمونة
- أسعار تنافسية للتجار
- توصيل سريع لجميع مناطق المملكة
- خدمة عملاء على مدار الساعة
- نظام نقاط ومكافآت

تواصل معنا
الهاتف: 920000000
البريد: support@trasphone.com
تويتر: @trasphone
''';
      default:
        return 'محتوى الصفحة غير متوفر';
    }
  }
}
