/// Auth Error Helper - Centralizes auth error presentation
library;

import 'package:flutter/material.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/widgets/widgets.dart';

class AuthErrorHelper {
  static void showErrorSnackBar(BuildContext context, Failure failure) {
    AppSnackbar.showFailure(context, failure);
  }
}
