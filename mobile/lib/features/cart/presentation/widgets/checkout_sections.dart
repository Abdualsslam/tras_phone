import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/config/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/checkout_session_entity.dart';
import '../../../orders/domain/entities/bank_account_entity.dart';
import '../../../orders/domain/entities/payment_method_entity.dart';
import '../../../profile/domain/entities/address_entity.dart';

part 'checkout_sections_common.dart';
part 'checkout_sections_address.dart';
part 'checkout_sections_payment_methods.dart';
part 'checkout_sections_credit.dart';
part 'checkout_sections_banks.dart';
part 'checkout_sections_wallet.dart';
part 'checkout_sections_receipt.dart';
part 'checkout_sections_summary.dart';
