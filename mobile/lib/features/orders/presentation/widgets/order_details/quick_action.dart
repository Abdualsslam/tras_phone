import 'package:flutter/material.dart';

class OrderQuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  OrderQuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
