/// Main Navigation Shell - Bottom navigation bar wrapper
/// Floating Island Design with Glassmorphism
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
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../wishlist/presentation/screens/wishlist_screen.dart';

class MainNavigationShell extends StatefulWidget {
  final int initialIndex;

  const MainNavigationShell({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  late AnimationController _animationController;

  final List<Widget> _screens = const [
    HomeScreen(),
    OrdersListScreen(),
    WishlistScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 4);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_currentIndex != index) {
      HapticFeedback.lightImpact();
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      extendBody: true,
      bottomNavigationBar: _buildFloatingNavBar(isDark),
    );
  }

  Widget _buildFloatingNavBar(bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        bottom: MediaQuery.of(context).padding.bottom,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 70.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF1C1C1E).withValues(alpha: 0.75),
                        const Color(0xFF2C2C2E).withValues(alpha: 0.7),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.75),
                        Colors.white.withValues(alpha: 0.65),
                      ],
              ),
              borderRadius: BorderRadius.circular(28.r),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.25),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.4)
                      : Colors.black.withValues(alpha: 0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                  spreadRadius: 0,
                ),
                if (!isDark)
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 52.w,
                  child: _buildNavItem(
                    index: 0,
                    icon: Iconsax.home_2,
                    activeIcon: Iconsax.home_25,
                    isDark: isDark,
                  ),
                ),
                SizedBox(
                  width: 52.w,
                  child: _buildNavItem(
                    index: 1,
                    icon: Iconsax.box,
                    activeIcon: Iconsax.box5,
                    isDark: isDark,
                    selectedOffset: 22.w,
                  ),
                ),
                SizedBox(
                  width: 56.w,
                  height: 56.w,
                  child: _buildCenterButton(isDark),
                ),
                SizedBox(
                  width: 52.w,
                  child: _buildNavItem(
                    index: 2,
                    icon: Iconsax.heart,
                    activeIcon: Iconsax.heart5,
                    isDark: isDark,
                  ),
                ),
                SizedBox(
                  width: 52.w,
                  child: _buildNavItem(
                    index: 4,
                    icon: Iconsax.user,
                    activeIcon: Iconsax.user,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required bool isDark,
    double? selectedOffset,
  }) {
    final isSelected = _currentIndex == index;
    final hasOffset = selectedOffset != null && selectedOffset > 0;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.2),
                      AppColors.primaryLight.withValues(alpha: 0.12),
                    ],
                  )
                : null,
            border: isSelected
                ? Border.all(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    width: 1.5,
                  )
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(
              left: hasOffset && isSelected ? selectedOffset : 0,
            ),
            child: Icon(
              isSelected ? activeIcon : icon,
              size: 24.sp,
              color: isSelected
                  ? AppColors.primary
                  : (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCenterButton(bool isDark) {
    final isSelected = _currentIndex == 3;

    return GestureDetector(
      onTap: () => _onItemTapped(3),
      child: Center(
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Outer glow effect
            if (isSelected)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        blurRadius: 25,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            // Main button
            Container(
              width: 52.w,
              height: 52.w,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: AppColors.primaryDark.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isSelected ? Iconsax.shopping_cart5 : Iconsax.shopping_cart,
                    key: ValueKey(isSelected),
                    size: 22.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // Cart badge
            BlocBuilder<CartCubit, CartState>(
              builder: (context, cartState) {
                int cartCount = 0;
                
                if (cartState is CartLoaded) {
                  cartCount = cartState.cart.itemsCount;
                } else if (cartState is CartUpdating) {
                  cartCount = cartState.cart.itemsCount;
                } else if (cartState is CartError && cartState.previousCart != null) {
                  cartCount = cartState.previousCart!.itemsCount;
                } else if (cartState is CartSyncing && cartState.currentCart != null) {
                  cartCount = cartState.currentCart!.itemsCount;
                }
                
                // Only show badge if count > 0
                if (cartCount <= 0) {
                  return const SizedBox.shrink();
                }
                
                return Positioned(
                  right: -2.w,
                  top: -2.h,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6B6B), Color(0xFFFF4757)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF4757).withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      cartCount > 99 ? '99+' : cartCount.toString(),
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
