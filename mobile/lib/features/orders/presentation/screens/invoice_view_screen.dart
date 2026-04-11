/// Invoice View Screen - View and download invoice
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/order_entity.dart';
import '../cubit/orders_cubit.dart';
import '../widgets/invoice_sections.dart';

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
      if (!mounted) return;

      setState(() {
        _order = order;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return _buildLoadingScaffold();
    }

    if (_error != null || _order == null) {
      return _buildErrorScaffold();
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
      body: InvoiceDocumentView(order: _order!, isDark: isDark),
    );
  }

  Scaffold _buildLoadingScaffold() {
    return Scaffold(
      appBar: AppBar(title: const Text('الفاتورة')),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Scaffold _buildErrorScaffold() {
    return Scaffold(
      appBar: AppBar(title: const Text('الفاتورة')),
      body: AppError(message: _error ?? 'لم يتم العثور على الطلب'),
    );
  }

  Future<void> _downloadInvoice(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final ordersCubit = context.read<OrdersCubit>();

    messenger.showSnackBar(
      const SnackBar(
        content: Text('جاري تحميل الفاتورة...'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    try {
      final url = await ordersCubit.getOrderInvoice(widget.orderId);
      if (!mounted) return;

      if (url.isEmpty) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('لا يوجد رابط للفاتورة'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final uri = Uri.tryParse(url);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!mounted) return;

        messenger.showSnackBar(
          const SnackBar(
            content: Text('تم فتح رابط الفاتورة'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      messenger.showSnackBar(
        const SnackBar(
          content: Text('تعذر فتح رابط الفاتورة'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Text('فشل تحميل الفاتورة: ${error.toString()}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _shareInvoice(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final ordersCubit = context.read<OrdersCubit>();

    try {
      final url = await ordersCubit.getOrderInvoice(widget.orderId);
      if (!mounted) return;

      if (url.isEmpty) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('لا يوجد رابط للمشاركة'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      await Share.share(
        'فاتورة الطلب ${_order?.orderNumber ?? widget.orderId}\n$url',
        subject: 'فاتورة الطلب ${_order?.orderNumber ?? widget.orderId}',
      );
    } catch (error) {
      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Text('فشل المشاركة: ${error.toString()}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
