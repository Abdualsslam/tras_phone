/// Invoice View Screen - View and download invoice
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/order_entity.dart';
import '../cubit/orders_cubit.dart';

class InvoiceViewScreen extends StatefulWidget {
  final String orderId;

  const InvoiceViewScreen({super.key, required this.orderId});

  @override
  State<InvoiceViewScreen> createState() => _InvoiceViewScreenState();
}

class _InvoiceViewScreenState extends State<InvoiceViewScreen> {
  OrderEntity? _order;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final order = await context.read<OrdersCubit>().getOrderById(
        widget.orderId,
      );
      if (mounted) {
        setState(() {
          _order = order;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('الفاتورة')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('الفاتورة')),
        body: AppError(
          message: _error ?? 'لم يتم العثور على الطلب',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('الفاتورة'),
        actions: [
          IconButton(
            onPressed: () => _downloadInvoice(context),
            icon: Icon(Iconsax.document_download, size: 22.sp),
          ),
          IconButton(
            onPressed: () => _shareInvoice(context),
            icon: Icon(Iconsax.share, size: 22.sp),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'فاتورة ضريبية',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'TAX INVOICE',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          'تراس فون',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Divider(height: 32.h),

              // Invoice Info
              Builder(
                builder: (context) {
                  final order = _order!;
                  final dateFormat = DateFormat('dd MMMM yyyy', 'ar');
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoColumn(
                        'رقم الفاتورة',
                        order.orderNumber,
                        isDark,
                      ),
                      _buildInfoColumn(
                        'التاريخ',
                        dateFormat.format(order.createdAt),
                        isDark,
                      ),
                      _buildInfoColumn(
                        'الحالة',
                        order.paymentStatus.displayNameAr,
                        isDark,
                        valueColor: order.paymentStatus == PaymentStatus.paid
                            ? AppColors.success
                            : null,
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 24.h),

              // Customer Info
              if (_order!.shippingAddress != null)
                Builder(
                  builder: (context) {
                    final addr = _order!.shippingAddress!;
                    return Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceDark
                            : AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'بيانات العميل',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            addr.fullName,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            addr.formattedAddress,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                          Text(
                            addr.phone,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              if (_order!.shippingAddress != null) SizedBox(height: 24.h),

              // Items Table Header
              Container(
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
                color: AppColors.primary.withValues(alpha: 0.1),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        'المنتج',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'الكمية',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'السعر',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'المجموع',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ),
              ..._order!.items.map(
                (item) => _buildInvoiceItem(
                  item.nameAr ?? item.name,
                  item.quantity,
                  item.unitPrice,
                  item.total,
                  isDark,
                  returnedQuantity: item.returnedQuantity,
                  effectiveQuantity: item.effectiveQuantity,
                  isPartiallyReturned: item.isPartiallyReturned,
                  isFullyReturned: item.isFullyReturned,
                ),
              ),

              Divider(height: 24.h),

              // Totals
              Builder(
                builder: (context) {
                  final order = _order!;
                  return Column(
                    children: [
                      _buildTotalRow(
                        'المجموع الفرعي',
                        '${order.subtotal.toStringAsFixed(2)} ر.س',
                        isDark,
                      ),
                      if (order.taxAmount > 0)
                        _buildTotalRow(
                          'الضريبة',
                          '${order.taxAmount.toStringAsFixed(2)} ر.س',
                          isDark,
                        ),
                      if (order.shippingCost > 0)
                        _buildTotalRow(
                          'الشحن',
                          '${order.shippingCost.toStringAsFixed(2)} ر.س',
                          isDark,
                        ),
                      if (order.discount > 0 || order.couponDiscount > 0)
                        _buildTotalRow(
                          'الخصم',
                          '-${(order.discount + order.couponDiscount).toStringAsFixed(2)} ر.س',
                          isDark,
                          valueColor: AppColors.success,
                        ),
                      Divider(height: 16.h),
                      _buildTotalRow(
                        'الإجمالي',
                        '${order.total.toStringAsFixed(2)} ر.س',
                        isDark,
                        isBold: true,
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 24.h),

              // Payment Info
              Builder(
                builder: (context) {
                  final order = _order!;
                  final isPaid = order.paymentStatus == PaymentStatus.paid;
                  return Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: (isPaid ? AppColors.success : AppColors.warning)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isPaid ? Iconsax.tick_circle : Iconsax.clock,
                          size: 20.sp,
                          color: isPaid ? AppColors.success : AppColors.warning,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.paymentStatus.displayNameAr,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: isPaid
                                      ? AppColors.success
                                      : AppColors.warning,
                                ),
                              ),
                              Text(
                                'طريقة الدفع: ${order.paymentMethod?.displayNameAr ?? '-'}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: 24.h),

              // Footer
              Center(
                child: Column(
                  children: [
                    Text(
                      'شكراً لتعاملكم معنا',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'www.trasphone.com',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(
    String label,
    String value,
    bool isDark, {
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: AppColors.textSecondaryLight,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color:
                valueColor ??
                (isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight),
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceItem(
    String name,
    int qty,
    double price,
    double total,
    bool isDark, {
    int returnedQuantity = 0,
    int? effectiveQuantity,
    bool isPartiallyReturned = false,
    bool isFullyReturned = false,
  }) {
    final effective = effectiveQuantity ?? (qty - returnedQuantity);
    final displayQty = returnedQuantity > 0 ? effective : qty;
    final displayTotal =
        returnedQuantity > 0 ? (effective * price) : total;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.dividerLight.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(child: Text(name, style: TextStyle(fontSize: 12.sp))),
                    if (returnedQuantity > 0) ...[
                      SizedBox(width: 6.w),
                      Chip(
                        label: Text(
                          isFullyReturned ? 'مرتجع' : 'مرتجع جزئياً',
                          style: TextStyle(fontSize: 10.sp),
                        ),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        backgroundColor: AppColors.warning.withValues(alpha: 0.15),
                      ),
                    ],
                  ],
                ),
                if (returnedQuantity > 0 && qty > effective)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(
                      'الأصلية: $qty، المرتجع: $returnedQuantity، المتبقي: $effective',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              '$displayQty',
              style: TextStyle(fontSize: 12.sp),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              price.toStringAsFixed(0),
              style: TextStyle(fontSize: 12.sp),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              displayTotal.toStringAsFixed(0),
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(
    String label,
    String value,
    bool isDark, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 14.sp : 13.sp,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 16.sp : 13.sp,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: valueColor ?? (isBold ? AppColors.primary : null),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadInvoice(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('جاري تحميل الفاتورة...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    try {
      final url = await context.read<OrdersCubit>().getOrderInvoice(
        widget.orderId,
      );
      if (url.isNotEmpty && mounted) {
        final uri = Uri.tryParse(url);
        if (uri != null && await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم فتح رابط الفاتورة'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تعذر فتح رابط الفاتورة'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لا يوجد رابط للفاتورة'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تحميل الفاتورة: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _shareInvoice(BuildContext context) async {
    try {
      final url = await context.read<OrdersCubit>().getOrderInvoice(
        widget.orderId,
      );
      if (url.isNotEmpty && mounted) {
        await Share.share(
          'فاتورة الطلب ${_order?.orderNumber ?? widget.orderId}\n$url',
          subject: 'فاتورة الطلب ${_order?.orderNumber ?? widget.orderId}',
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لا يوجد رابط للمشاركة'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل المشاركة: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
