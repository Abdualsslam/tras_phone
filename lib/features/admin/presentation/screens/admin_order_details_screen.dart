/// Admin Order Details Screen - Order management for admin
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';

class AdminOrderDetailsScreen extends StatefulWidget {
  final String orderId;

  const AdminOrderDetailsScreen({super.key, required this.orderId});

  @override
  State<AdminOrderDetailsScreen> createState() =>
      _AdminOrderDetailsScreenState();
}

class _AdminOrderDetailsScreenState extends State<AdminOrderDetailsScreen> {
  String _currentStatus = 'processing';

  // Mock order data
  final _order = {
    'id': 'ORD-12345',
    'customer': 'محمد أحمد',
    'phone': '+966 55 123 4567',
    'email': 'mohamed@example.com',
    'address': 'الرياض، حي النخيل، شارع الأمير سلطان',
    'date': '20 ديسمبر 2024',
    'total': 1850.0,
    'paymentMethod': 'تحويل بنكي',
    'paymentStatus': 'paid',
  };

  final _items = [
    {'name': 'شاشة آيفون 15 برو ماكس', 'qty': 1, 'price': 950.0},
    {'name': 'بطارية آيفون 13', 'qty': 2, 'price': 120.0},
    {'name': 'منفذ شحن آيفون', 'qty': 5, 'price': 45.0},
  ];

  final _statusOptions = [
    {'value': 'pending', 'label': 'قيد الانتظار', 'color': AppColors.warning},
    {'value': 'processing', 'label': 'قيد المعالجة', 'color': AppColors.info},
    {'value': 'shipped', 'label': 'تم الشحن', 'color': AppColors.primary},
    {'value': 'delivered', 'label': 'تم التسليم', 'color': AppColors.success},
    {'value': 'cancelled', 'label': 'ملغي', 'color': AppColors.error},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('#${widget.orderId}'),
        actions: [
          IconButton(
            onPressed: () => _printInvoice(),
            icon: Icon(Iconsax.printer, size: 22.sp),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'invoice',
                child: Text('عرض الفاتورة'),
              ),
              const PopupMenuItem(
                value: 'contact',
                child: Text('اتصال بالعميل'),
              ),
              const PopupMenuItem(value: 'cancel', child: Text('إلغاء الطلب')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // Status Card
          _buildStatusCard(isDark),
          SizedBox(height: 16.h),

          // Customer Info
          _buildSectionCard('معلومات العميل', [
            _buildInfoRow(Iconsax.user, _order['customer'] as String, isDark),
            _buildInfoRow(Iconsax.call, _order['phone'] as String, isDark),
            _buildInfoRow(Iconsax.sms, _order['email'] as String, isDark),
            _buildInfoRow(
              Iconsax.location,
              _order['address'] as String,
              isDark,
            ),
          ], isDark),
          SizedBox(height: 16.h),

          // Order Items
          _buildItemsCard(isDark),
          SizedBox(height: 16.h),

          // Payment Info
          _buildSectionCard('معلومات الدفع', [
            _buildInfoRow(
              Iconsax.card,
              _order['paymentMethod'] as String,
              isDark,
            ),
            _buildPaymentStatus(isDark),
          ], isDark),
          SizedBox(height: 16.h),

          // Order Summary
          _buildSummaryCard(isDark),
          SizedBox(height: 24.h),

          // Action Buttons
          _buildActionButtons(isDark),
          SizedBox(height: 100.h),
        ],
      ),
    );
  }

  Widget _buildStatusCard(bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'حالة الطلب',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              Text(
                _order['date'] as String,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          DropdownButtonFormField<String>(
            value: _currentStatus,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
            ),
            items: _statusOptions.map((status) {
              return DropdownMenuItem(
                value: status['value'] as String,
                child: Row(
                  children: [
                    Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        color: status['color'] as Color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(status['label'] as String),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) _updateStatus(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children, bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          SizedBox(height: 16.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: AppColors.primary),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatus(bool isDark) {
    final isPaid = _order['paymentStatus'] == 'paid';
    return Row(
      children: [
        Icon(
          Iconsax.tick_circle,
          size: 20.sp,
          color: isPaid ? AppColors.success : AppColors.warning,
        ),
        SizedBox(width: 12.w),
        Text(
          isPaid ? 'تم الدفع' : 'في انتظار الدفع',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isPaid ? AppColors.success : AppColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildItemsCard(bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المنتجات (${_items.length})',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          SizedBox(height: 16.h),
          ..._items.map((item) => _buildItemRow(item, isDark)).toList(),
        ],
      ),
    );
  }

  Widget _buildItemRow(Map<String, dynamic> item, bool isDark) {
    final total = (item['qty'] as int) * (item['price'] as double);
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] as String,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  '${item['qty']} × ${(item['price'] as double).toStringAsFixed(0)} ر.س',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${total.toStringAsFixed(0)} ر.س',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'إجمالي الطلب',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          Text(
            '${(_order['total'] as double).toStringAsFixed(0)} ر.س',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _contactCustomer(),
            icon: Icon(Iconsax.call, size: 18.sp),
            label: const Text('اتصال'),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: () => _saveChanges(),
            icon: Icon(Iconsax.tick_circle, size: 18.sp),
            label: const Text('حفظ التغييرات'),
          ),
        ),
      ],
    );
  }

  void _updateStatus(String status) {
    setState(() => _currentStatus = status);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تحديث حالة الطلب'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'invoice':
        // Navigate to invoice
        break;
      case 'contact':
        _contactCustomer();
        break;
      case 'cancel':
        _showCancelDialog();
        break;
    }
  }

  void _contactCustomer() {
    // Implement call functionality
  }

  void _printInvoice() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('جاري طباعة الفاتورة...')));
  }

  void _saveChanges() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ التغييرات بنجاح'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء الطلب'),
        content: const Text('هل أنت متأكد من إلغاء هذا الطلب؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لا'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _currentStatus = 'cancelled');
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('إلغاء الطلب'),
          ),
        ],
      ),
    );
  }
}
