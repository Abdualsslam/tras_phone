import 'package:flutter/material.dart';

class TimelineStepData {
  final String label;
  final String? subtitle;
  final IconData icon;
  final String? actionLabel;
  final String? actionUrl;

  TimelineStepData({
    required this.label,
    this.subtitle,
    required this.icon,
    this.actionLabel,
    this.actionUrl,
  });
}
