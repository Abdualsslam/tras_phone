/// Theme Cubit - Manages app theme state (Light/Dark/System)
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../storage/local_storage.dart';
import '../constants/storage_keys.dart';

/// State for theme management
class ThemeState {
  final ThemeMode themeMode;
  final bool isLoading;

  const ThemeState({
    required this.themeMode,
    this.isLoading = false,
  });

  ThemeState copyWith({
    ThemeMode? themeMode,
    bool? isLoading,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Cubit for managing app theme
class ThemeCubit extends Cubit<ThemeState> {
  final LocalStorage _localStorage;

  ThemeCubit({required LocalStorage localStorage})
      : _localStorage = localStorage,
        super(const ThemeState(themeMode: ThemeMode.system));

  /// Load saved theme from storage
  Future<void> loadSavedTheme() async {
    emit(state.copyWith(isLoading: true));

    final savedTheme = _localStorage.getString(StorageKeys.themeMode);

    if (savedTheme != null) {
      ThemeMode themeMode;
      switch (savedTheme) {
        case 'light':
          themeMode = ThemeMode.light;
          break;
        case 'dark':
          themeMode = ThemeMode.dark;
          break;
        case 'system':
        default:
          themeMode = ThemeMode.system;
          break;
      }
      emit(ThemeState(themeMode: themeMode));
    } else {
      // Default to system
      emit(const ThemeState(themeMode: ThemeMode.system));
    }
  }

  /// Change app theme
  Future<void> changeTheme(ThemeMode themeMode) async {
    emit(state.copyWith(isLoading: true));

    String themeString;
    switch (themeMode) {
      case ThemeMode.light:
        themeString = 'light';
        break;
      case ThemeMode.dark:
        themeString = 'dark';
        break;
      case ThemeMode.system:
        themeString = 'system';
        break;
    }

    await _localStorage.setString(StorageKeys.themeMode, themeString);

    emit(ThemeState(themeMode: themeMode));
  }

  /// Toggle between light and dark (skips system)
  Future<void> toggleTheme() async {
    final newTheme = state.themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;

    await changeTheme(newTheme);
  }

  /// Check if dark mode is enabled
  bool isDarkMode(BuildContext context) {
    if (state.themeMode == ThemeMode.system) {
      return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
    return state.themeMode == ThemeMode.dark;
  }
}
