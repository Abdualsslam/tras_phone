/// App Widget - Root application widget.
library;

import 'package:flutter/widgets.dart';

import 'app_bootstrap.dart';

class TrasPhoneApp extends StatelessWidget {
  const TrasPhoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppBootstrap();
  }
}
