/// Screen to select items from all eligible orders for return
library;

import 'package:flutter/material.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../orders/data/models/order_model.dart';
import '../../../orders/data/datasources/orders_remote_datasource.dart';
import '../../data/models/return_model.dart';
import 'create_return_screen.dart';

/// شاشة اختيار المنتجات من جميع الطلبات للإرجاع
class SelectItemsForReturnScreen extends StatefulWidget {
  const SelectItemsForReturnScreen({super.key});

  @override
  State<SelectItemsForReturnScreen> createState() =>
      _SelectItemsForReturnScreenState();
}

class _SelectItemsForReturnScreenState
    extends State<SelectItemsForReturnScreen> {
  /// Map of orderItemId -> quantity
  final Map<String, int> _selectedItems = {};
  
  /// List of eligible orders
  List<OrderModel> _eligibleOrders = [];
  
  /// Loading state
  bool _isLoading = true;
  
  /// Error message
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEligibleOrders();
  }

  /// جلب الطلبات المؤهلة للإرجاع
  Future<void> _loadEligibleOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: Replace with actual implementation
      // For now, fetch all delivered orders
      // In production, add filters for:
      // - status = 'delivered'
      // - deliveredAt within return window (e.g., last 30 days)
      // final orders = await ordersDataSource.getMyOrders(status: 'delivered');
      
      // Placeholder: Empty list for now
      _eligibleOrders = [];
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'فشل تحميل الطلبات: $e';
      });
    }
  }

  /// تبديل اختيار المنتج
  void _toggleItem(String orderItemId, int maxQuantity) {
    setState(() {
      if (_selectedItems.containsKey(orderItemId)) {
        _selectedItems.remove(orderItemId);
      } else {
        _selectedItems[orderItemId] = maxQuantity;
      }
    });
  }

  /// المتابعة إلى صفحة إنشاء طلب الإرجاع
  void _proceed() {
    if (_selectedItems.isEmpty) return;

    // تحويل selectedItems إلى List<CreateReturnItemRequest>
    final items = _selectedItems.entries
        .map((e) => CreateReturnItemRequest(
              orderItemId: e.key,
              quantity: e.value,
            ))
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateReturnScreen(
          preSelectedItems: items,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختر المنتجات للإرجاع'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _errorMessage != null
              ? ErrorWidgetCustom(
                  message: _errorMessage!,
                  onRetry: _loadEligibleOrders,
                )
              : _eligibleOrders.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'لا توجد طلبات مؤهلة للإرجاع',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _eligibleOrders.length,
                      itemBuilder: (context, index) {
                        final order = _eligibleOrders[index];
                        return _OrderCard(
                          order: order,
                          selectedItems: _selectedItems,
                          onItemToggle: _toggleItem,
                        );
                      },
                    ),
      bottomNavigationBar: _selectedItems.isNotEmpty
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _proceed,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'متابعة (${_selectedItems.length} منتج)',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

/// بطاقة الطلب مع المنتجات
class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final Map<String, int> selectedItems;
  final Function(String, int) onItemToggle;

  const _OrderCard({
    required this.order,
    required this.selectedItems,
    required this.onItemToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          'طلب ${order.orderNumber}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${order.items.length} منتج'),
        children: order.items.map((item) {
          final isSelected = selectedItems.containsKey(item.id);
          
          return CheckboxListTile(
            value: isSelected,
            onChanged: (checked) {
              onItemToggle(item.id, item.quantity);
            },
            title: Text(item.productName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('السعر: ${item.unitPrice} ر.س'),
                Text('الكمية: ${item.quantity}'),
              ],
            ),
            secondary: item.productImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.productImage!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.image),
                    ),
                  )
                : const Icon(Icons.image),
          );
        }).toList(),
      ),
    );
  }
}
