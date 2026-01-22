/// Banner Targeting Entity
library;

import 'package:equatable/equatable.dart';

class BannerTargetingEntity extends Equatable {
  final List<String> customerSegments;
  final List<String>? categories;
  final List<String> userTypes; // 'guest', 'registered', 'all'
  final List<String> devices; // 'mobile', 'tablet', 'desktop'

  const BannerTargetingEntity({
    this.customerSegments = const [],
    this.categories,
    this.userTypes = const ['all'],
    this.devices = const [],
  });

  /// هل البانر يستهدف جميع المستخدمين؟
  bool get isForAllUsers => userTypes.contains('all');

  /// هل البانر يستهدف الضيوف فقط؟
  bool get isForGuestsOnly =>
      userTypes.contains('guest') && !userTypes.contains('registered');

  /// هل البانر يستهدف المستخدمين المسجلين فقط؟
  bool get isForRegisteredOnly =>
      userTypes.contains('registered') && !userTypes.contains('guest');

  /// هل البانر يستهدف جهاز معين؟
  bool isForDevice(String device) => devices.isEmpty || devices.contains(device);

  @override
  List<Object?> get props => [customerSegments, categories, userTypes, devices];
}
