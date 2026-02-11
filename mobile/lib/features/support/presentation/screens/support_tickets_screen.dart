/// Support Tickets List Screen - List of support tickets
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/support_cubit.dart';
import '../widgets/ticket_card.dart';

class SupportTicketsScreen extends StatefulWidget {
  const SupportTicketsScreen({super.key});

  @override
  State<SupportTicketsScreen> createState() => _SupportTicketsScreenState();
}

class _SupportTicketsScreenState extends State<SupportTicketsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<SupportCubit>().loadMyTickets(refresh: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<SupportCubit>().loadMoreTickets();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.support)),
      body: BlocBuilder<SupportCubit, SupportState>(
        builder: (context, state) {
          if (state.status == SupportStatus.loading && state.tickets.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == SupportStatus.error && state.tickets.isEmpty) {
            return _buildErrorState(theme, state.error);
          }

          if (state.tickets.isEmpty) {
            return _buildEmptyState(theme);
          }

          return RefreshIndicator(
            onRefresh: () =>
                context.read<SupportCubit>().loadMyTickets(refresh: true),
            child: ListView.separated(
              controller: _scrollController,
              padding: EdgeInsets.all(16.w),
              itemCount: state.tickets.length + (state.hasMoreTickets ? 1 : 0),
              separatorBuilder: (_, a) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                if (index >= state.tickets.length) {
                  return const Center(child: CircularProgressIndicator());
                }
                return TicketCard(ticket: state.tickets[index]);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/support/create'),
        icon: const Icon(Iconsax.add),
        label: const Text('تذكرة جديدة'),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.message_question,
            size: 80.sp,
            color: AppColors.textTertiaryLight,
          ),
          SizedBox(height: 24.h),
          Text(
            'لا توجد تذاكر دعم',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'إذا كان لديك أي استفسار، أنشئ تذكرة جديدة',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textTertiaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, String? error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.warning_2, size: 80.sp, color: AppColors.error),
          SizedBox(height: 24.h),
          Text(
            'حدث خطأ',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            error ?? 'فشل في تحميل التذاكر',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textTertiaryLight,
            ),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () =>
                context.read<SupportCubit>().loadMyTickets(refresh: true),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}
