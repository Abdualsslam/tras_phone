import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/bank_account_entity.dart';
import '../cubit/orders_cubit.dart';

class UploadReceiptFormController extends ChangeNotifier {
  final ImagePicker _picker;

  final TextEditingController notesController = TextEditingController();
  final TextEditingController transferRefController = TextEditingController();

  String? _receiptImagePath;
  DateTime? _transferDate;
  List<BankAccountEntity> _bankAccounts = const [];
  bool _isUploading = false;

  UploadReceiptFormController({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  String? get receiptImagePath => _receiptImagePath;
  DateTime? get transferDate => _transferDate;
  List<BankAccountEntity> get bankAccounts => _bankAccounts;
  bool get isUploading => _isUploading;
  bool get canUpload => _receiptImagePath != null && !_isUploading;

  void initialize(OrdersCubit cubit) {
    cubit.loadBankAccounts();
  }

  void setBankAccounts(List<BankAccountEntity> accounts) {
    _bankAccounts = accounts;
    notifyListeners();
  }

  Future<void> pickImage(ImageSource source) async {
    final xFile = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1920,
    );

    if (xFile == null) return;
    _receiptImagePath = xFile.path;
    notifyListeners();
  }

  void clearImage() {
    _receiptImagePath = null;
    notifyListeners();
  }

  void setTransferDate(DateTime? date) {
    _transferDate = date;
    notifyListeners();
  }

  Future<bool> uploadReceipt({
    required OrdersCubit cubit,
    required String orderId,
  }) async {
    if (_receiptImagePath == null) return false;

    _isUploading = true;
    notifyListeners();

    try {
      final file = File(_receiptImagePath!);
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);

      final order = await cubit.uploadReceipt(
        orderId: orderId,
        receiptImage: base64Image,
        transferReference: transferRefController.text.trim().isNotEmpty
            ? transferRefController.text.trim()
            : null,
        transferDate: _transferDate != null
            ? DateFormat('yyyy-MM-dd').format(_transferDate!)
            : null,
        notes: notesController.text.trim().isNotEmpty
            ? notesController.text.trim()
            : null,
      );

      return order != null;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    notesController.dispose();
    transferRefController.dispose();
    super.dispose();
  }
}
