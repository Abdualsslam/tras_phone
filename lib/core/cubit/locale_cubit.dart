/// Locale Cubit - Manages app language state
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../storage/local_storage.dart';
import '../constants/storage_keys.dart';

/// State for locale management
class LocaleState {
  final Locale locale;
  final bool isLoading;

  const LocaleState({required this.locale, this.isLoading = false});

  LocaleState copyWith({Locale? locale, bool? isLoading}) {
    return LocaleState(
      locale: locale ?? this.locale,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Cubit for managing app locale/language
class LocaleCubit extends Cubit<LocaleState> {
  final LocalStorage _localStorage;

  LocaleCubit({required LocalStorage localStorage})
    : _localStorage = localStorage,
      super(const LocaleState(locale: Locale('ar')));

  /// Load saved locale from storage
  Future<void> loadSavedLocale() async {
    emit(state.copyWith(isLoading: true));

    final savedLocale = _localStorage.getString(StorageKeys.locale);

    if (savedLocale != null) {
      emit(LocaleState(locale: Locale(savedLocale)));
    } else {
      // Default to Arabic
      emit(const LocaleState(locale: Locale('ar')));
    }
  }

  /// Change app locale
  Future<void> changeLocale(Locale locale) async {
    emit(state.copyWith(isLoading: true));

    await _localStorage.setString(StorageKeys.locale, locale.languageCode);

    emit(LocaleState(locale: locale));
  }

  /// Toggle between Arabic and English
  Future<void> toggleLocale() async {
    final newLocale = state.locale.languageCode == 'ar'
        ? const Locale('en')
        : const Locale('ar');

    await changeLocale(newLocale);
  }

  /// Check if current locale is Arabic
  bool get isArabic => state.locale.languageCode == 'ar';

  /// Check if current locale is English
  bool get isEnglish => state.locale.languageCode == 'en';
}
