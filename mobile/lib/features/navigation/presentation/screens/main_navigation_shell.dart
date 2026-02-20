/// Main Navigation Shell - Bottom navigation bar wrapper
/// Modern Floating Island with refined glassmorphism
library;

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../../cart/presentation/screens/cart_screen.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../orders/presentation/screens/orders_list_screen.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../profile/presentation/cubit/profile_state.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../wishlist/presentation/screens/wishlist_screen.dart';

class MainNavigationShell extends StatefulWidget {
  final int initialIndex;

  const MainNavigationShell({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell>
    with TickerProviderStateMixin {
  late int _currentIndex;
  late final List<AnimationController> _scaleControllers;
  late final List<Animation<double>> _scaleAnimations;

  final List<Widget> _screens = const [
    HomeScreen(),
    OrdersListScreen(),
    WishlistScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  // Tab config: icon, activeIcon, label
  static const _tabs = [
    (icon: Iconsax.home_2, active: Iconsax.home_25, label: 'الرئيسية'),
    (icon: Iconsax.box, active: Iconsax.box5, label: 'طلباتي'),
    (icon: Iconsax.heart, active: Iconsax.heart5, label: 'المفضلة'),
    (icon: Iconsax.shopping_cart, active: Iconsax.shopping_cart5, label: 'السلة'),
    (icon: Iconsax.user, active: Iconsax.user, label: 'حسابي'),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 4);

    _scaleControllers = List.generate(
      5,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 250),
      ),
    );
    _scaleAnimations = _scaleControllers.map((c) {
      return Tween<double>(begin: 1.0, end: 0.85).animate(
        CurvedAnimation(parent: c, curve: Curves.easeInOut),
      );
    }).toList();
  }

  @override
  void dispose() {
    for (final c in _scaleControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_currentIndex != index) {
      HapticFeedback.lightImpact();
      // Bounce animation
      _scaleControllers[index].forward().then((_) {
        _scaleControllers[index].reverse();
      });
      setState(() => _currentIndex = index);

      if (index == 4) {
        final profileCubit = context.read<ProfileCubit>();
        if (profileCubit.state is ProfileInitial) {
          profileCubit.loadProfile();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      extendBody: true,
      bottomNavigationBar: _FloatingNavBar(
        currentIndex: _currentIndex,
        isDark: isDark,
        scaleAnimations: _scaleAnimations,
        onTap: _onItemTapped,
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final bool isDark;
  final List<Animation<double>> scaleAnimations;
  final ValueChanged<int> onTap;

  const _FloatingNavBar({
    required this.currentIndex,
    required this.isDark,
    required this.scaleAnimations,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        bottom: bottomPadding + 8.h,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            height: 68.h,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1A1A1C).withValues(alpha: 0.82)
                  : Colors.white.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.5)
                      : Colors.black.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
                if (!isDark)
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.04),
                    blurRadius: 40,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Row(
              children: List.generate(5, (i) {
                if (i == 3) {
                  // Cart tab - special center button
                  return Expanded(
                    child: _CartButton(
                      isSelected: currentIndex == 3,
                      isDark: isDark,
                      scaleAnimation: scaleAnimations[3],
                      onTap: () => onTap(3),
                    ),
                  );
                }
                final tab = _MainNavigationShellState._tabs[i];
                return Expanded(
                  child: _NavItem(
                    icon: tab.icon,
                    activeIcon: tab.active,
                    label: tab.label,
                    isSelected: currentIndex == i,
                    isDark: isDark,
                    scaleAnimation: scaleAnimations[i],
                    onTap: () => onTap(i),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Individual Nav Item ───
class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final bool isDark;
  final Animation<double> scaleAnimation;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.scaleAnimation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selectedColor = AppColors.primary;
    final unselectedColor = isDark
        ? AppColors.textTertiaryDark
        : AppColors.textSecondaryLight;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with animated indicator dot
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              padding: EdgeInsets.all(isSelected ? 8.w : 6.w),
              decoration: isSelected
                  ? BoxDecoration(
                      color: selectedColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    )
                  : null,
              child: Icon(
                isSelected ? activeIcon : icon,
                size: 22.sp,
                color: isSelected ? selectedColor : unselectedColor,
              ),
            ),
            SizedBox(height: 2.h),
            // Label
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? selectedColor : unselectedColor,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Cart Center Button ───
class _CartButton extends StatelessWidget {
  final bool isSelected;
  final bool isDark;
  final Animation<double> scaleAnimation;
  final VoidCallback onTap;

  const _CartButton({
    required this.isSelected,
    required this.isDark,
    required this.scaleAnimation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Main circle
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                width: 50.w,
                height: 50.w,
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? AppColors.primaryGradient
                      : LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.85),
                            AppColors.primaryDark.withValues(alpha: 0.85),
                          ],
                        ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(
                        alpha: isSelected ? 0.45 : 0.25,
                      ),
                      blurRadius: isSelected ? 16 : 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  isSelected
                      ? Iconsax.shopping_cart5
                      : Iconsax.shopping_cart,
                  size: 22.sp,
                  color: Colors.white,
                ),
              ),
              // Badge
              _CartBadge(isDark: isDark),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Cart Badge ───
class _CartBadge extends StatelessWidget {
  final bool isDark;

  const _CartBadge({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, cartState) {
        int count = 0;
        if (cartState is CartLoaded) {
          count = cartState.cart.itemsCount;
        } else if (cartState is CartUpdating) {
          count = cartState.cart.itemsCount;
        } else if (cartState is CartError && cartState.previousCart != null) {
          count = cartState.previousCart!.itemsCount;
        } else if (cartState is CartSyncing && cartState.currentCart != null) {
          count = cartState.currentCart!.itemsCount;
        }

        if (count <= 0) return const SizedBox.shrink();

        return Positioned(
          right: -4.w,
          top: -4.h,
          child: AnimatedScale(
            scale: 1.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              constraints: BoxConstraints(minWidth: 20.w),
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFF4757),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: isDark ? const Color(0xFF1A1A1C) : Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF4757).withValues(alpha: 0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                count > 99 ? '99+' : count.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
