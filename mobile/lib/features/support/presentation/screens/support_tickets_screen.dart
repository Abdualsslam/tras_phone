/// Support Tickets List Screen - List of support tickets
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/support_model.dart';
import '../cubit/support_cubit.dart';

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
    final isDark = theme.brightness == Brightness.dark;

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
              separatorBuilder: (_, _a) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                if (index >= state.tickets.length) {
                  return const Center(child: CircularProgressIndicator());
                }
                return _buildTicketCard(
                  context,
                  theme,
                  isDark,
                  state.tickets[index],
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/support/create-ticket'),
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
          Icon(
            Iconsax.warning_2,
            size: 80.sp,
            color: AppColors.error,
          ),
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

  Widget _buildTicketCard(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    TicketModel ticket,
  ) {
    return GestureDetector(
      onTap: () => context.push('/support/tickets/${ticket.id}'),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Iconsax.message_text, color: AppColors.primary),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket.subject,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        ticket.category?.getName('ar') ?? 'غير محدد',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(ticket.status),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              ticket.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(ticket.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiaryLight,
                  ),
                ),
                Row(
                  children: [
                    if (ticket.messageCount > 0) ...[
                      Icon(
                        Iconsax.message,
                        size: 14.sp,
                        color: AppColors.textTertiaryLight,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${ticket.messageCount}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiaryLight,
                        ),
                      ),
                    ],
                    if (ticket.canRate) ...[
                      SizedBox(width: 8.w),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          'قيم الخدمة',
                          style: TextStyle(
                            color: AppColors.warning,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(TicketStatus status) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        status.displayNameAr,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: status.color,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inHours < 1) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays == 1) return 'أمس';
    return '${date.day}/${date.month}/${date.year}';
  }
}
