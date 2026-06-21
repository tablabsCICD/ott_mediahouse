import 'package:flutter/material.dart';
import 'package:media_house/app/provider/notification_settings_provider.dart';
import 'package:media_house/domain/entities/notification_model.dart';
import 'package:media_house/domain/entities/notification_settings_model.dart';
import 'package:provider/provider.dart';

class SettingsCustomAppBar extends StatelessWidget {
  const SettingsCustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.movie_filter_rounded, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Production house notifications, audience messaging, and delivery controls.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.66),
                  ),
                ),
              ],
            ),
          ),
          // const ThemeToggleButton(),
        ],
      ),
    );
  }
}

class SettingsSectionCard extends StatelessWidget {
  const SettingsSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor.withOpacity(0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class NotificationAnalyticsCard extends StatelessWidget {
  const NotificationAnalyticsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationSettingsProvider>();
    final theme = Theme.of(context);
    return SettingsSectionCard(
      title: 'Notification Analytics',
      icon: Icons.insights_rounded,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth > 680 ? 4 : 2;
          return GridView.count(
            crossAxisCount: columns,
            childAspectRatio: columns == 4 ? 1.9 : 1.55,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _MetricTile(
                label: 'Total Sent',
                value: provider.totalSent.toString(),
                icon: Icons.send_rounded,
                color: theme.colorScheme.primary,
              ),
              _MetricTile(
                label: 'Failed',
                value: provider.failedCount.toString(),
                icon: Icons.error_outline_rounded,
                color: Colors.deepOrange,
              ),
              _MetricTile(
                label: 'Delivered',
                value: provider.deliveredCount.toString(),
                icon: Icons.done_all_rounded,
                color: Colors.green,
              ),
              _MetricTile(
                label: 'Success Rate',
                value: '${(provider.successRate * 100).round()}%',
                icon: Icons.trending_up_rounded,
                color: Colors.teal,
                progress: provider.successRate,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.progress,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const Spacer(),
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.68),
              fontWeight: FontWeight.w600,
            ),
          ),
          if (progress != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                color: color,
                backgroundColor: color.withOpacity(0.18),
              ),
            ),
        ],
      ),
    );
  }
}

class UserSelectionDialog extends StatefulWidget {
  const UserSelectionDialog({super.key});

  @override
  State<UserSelectionDialog> createState() => _UserSelectionDialogState();
}

class _UserSelectionDialogState extends State<UserSelectionDialog> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationSettingsProvider>();
    final theme = Theme.of(context);
    final users = provider.users.where((user) {
      final lowerQuery = _query.toLowerCase();
      return user.name.toLowerCase().contains(lowerQuery) ||
          user.email.toLowerCase().contains(lowerQuery) ||
          user.role.toLowerCase().contains(lowerQuery);
    }).toList();

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Select Users',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded),
                  hintText: 'Search users, roles, or email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final selected =
                        provider.settings.selectedUserIds.contains(user.id);
                    return CheckboxListTile(
                      value: selected,
                      onChanged: (_) => provider.toggleSelectedUser(user),
                      activeColor: theme.colorScheme.primary,
                      checkColor: theme.colorScheme.onPrimary,
                      selected: selected,
                      selectedTileColor: theme.colorScheme.primary,
                      title: Text(user.name),
                      subtitle: Text('${user.role} - ${user.email}'),
                      secondary: CircleAvatar(
                        backgroundColor: theme.colorScheme.primary,
                        child: Text(user.name.isEmpty ? '?' : user.name[0]),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Done (${provider.selectedUsers.length})'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notification,
    required this.onViewDetails,
    required this.onResend,
    required this.onDelete,
  });

  final NotificationModel notification;
  final VoidCallback onViewDetails;
  final VoidCallback onResend;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 320),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withOpacity(0.16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _typeIcon(notification.notificationType),
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.68),
                        ),
                      ),
                    ],
                  ),
                ),
                _Badge(
                  label: notification.priority.label,
                  color: _priorityColor(notification.priority),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoPill(
                  icon: Icons.person_outline_rounded,
                  label: notification.sentBy,
                ),
                _InfoPill(
                  icon: Icons.schedule_rounded,
                  label: _formatDateTime(notification.sentAt),
                ),
                _InfoPill(
                  icon: Icons.group_outlined,
                  label: notification.recipientType.label,
                ),
                _InfoPill(
                  icon: Icons.mark_email_read_outlined,
                  label: notification.deliveryStatus.label,
                  color: _statusColor(notification.deliveryStatus),
                ),
                _InfoPill(
                  icon: Icons.notifications_active_outlined,
                  label: notification.notificationType.label,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton.icon(
                  onPressed: onViewDetails,
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('View Details'),
                ),
                TextButton.icon(
                  onPressed: onResend,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Resend'),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Delete',
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static IconData _typeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.push:
        return Icons.notifications_active_outlined;
      case NotificationType.email:
        return Icons.mail_outline_rounded;
      case NotificationType.sms:
        return Icons.sms_outlined;
    }
  }

  static Color _priorityColor(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Colors.blueGrey;
      case NotificationPriority.medium:
        return Colors.blue;
      case NotificationPriority.high:
        return Colors.orange;
      case NotificationPriority.urgent:
        return Colors.red;
    }
  }

  static Color _statusColor(NotificationDeliveryStatus status) {
    switch (status) {
      case NotificationDeliveryStatus.delivered:
        return Colors.green;
      case NotificationDeliveryStatus.scheduled:
        return Colors.blue;
      case NotificationDeliveryStatus.failed:
        return Colors.red;
      case NotificationDeliveryStatus.sending:
        return Colors.orange;
    }
  }

  static String _formatDateTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day}/${date.month}/${date.year} $hour:$minute';
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
    this.color,
  });

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = color ?? theme.colorScheme.onSurface.withOpacity(0.70);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: foreground.withOpacity(0.09),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: foreground),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: foreground, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  NotificationHistoryFilter? _historyFilter;
  NotificationType? _typeFilter;
  NotificationDeliveryStatus? _statusFilter;
  DateTimeRange? _customDateRange;
  String _sortDirection = 'desc';

  @override
  void initState() {
    super.initState();
    final provider = context.read<NotificationSettingsProvider>();
    _historyFilter = provider.historyFilter;
    _typeFilter = provider.typeFilter;
    _statusFilter = provider.statusFilter;
    _customDateRange = provider.customDateRange;
    _sortDirection = provider.sortDirection;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'History Filters',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: NotificationHistoryFilter.values.map((filter) {
                  final selected = _historyFilter == filter;
                  return ChoiceChip(
                    selected: selected,
                    label: Text(_historyLabel(filter)),
                    selectedColor: theme.colorScheme.primary,
                    backgroundColor: theme.colorScheme.surface,
                    labelStyle: TextStyle(
                      color: selected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface.withOpacity(0.78),
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    side: BorderSide(
                      color: selected
                          ? theme.colorScheme.primary
                          : theme.dividerColor.withOpacity(0.35),
                    ),
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _historyFilter = filter),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              if (_historyFilter == NotificationHistoryFilter.custom) ...[
                OutlinedButton.icon(
                  onPressed: _pickDateRange,
                  icon: const Icon(Icons.date_range_rounded),
                  label: Text(_customDateRange == null
                      ? 'Choose Custom Date'
                      : _dateRangeLabel(_customDateRange!)),
                ),
                const SizedBox(height: 16),
              ],
              DropdownButtonFormField<NotificationType>(
                initialValue: _typeFilter,
                decoration: const InputDecoration(
                  labelText: 'Notification Type',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<NotificationType>(
                    value: null,
                    child: Text('All Types'),
                  ),
                  ...NotificationType.values.map(
                    (type) => DropdownMenuItem<NotificationType>(
                      value: type,
                      child: Text(type.label),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _typeFilter = value),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<NotificationDeliveryStatus>(
                initialValue: _statusFilter,
                decoration: const InputDecoration(
                  labelText: 'Delivery Status',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<NotificationDeliveryStatus>(
                    value: null,
                    child: Text('All Statuses'),
                  ),
                  ...NotificationDeliveryStatus.values.map(
                    (status) => DropdownMenuItem<NotificationDeliveryStatus>(
                      value: status,
                      child: Text(status.label),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _statusFilter = value),
              ),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment<String>(
                    value: 'desc',
                    icon: Icon(Icons.south_rounded),
                    label: Text('Newest'),
                  ),
                  ButtonSegment<String>(
                    value: 'asc',
                    icon: Icon(Icons.north_rounded),
                    label: Text('Oldest'),
                  ),
                ],
                selected: {_sortDirection},
                onSelectionChanged: (value) {
                  setState(() => _sortDirection = value.first);
                },
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        await context
                            .read<NotificationSettingsProvider>()
                            .applyFilters(clear: true);
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        await context
                            .read<NotificationSettingsProvider>()
                            .applyFilters(
                              historyFilter: _historyFilter,
                              typeFilter: _typeFilter,
                              statusFilter: _statusFilter,
                              customDateRange: _customDateRange,
                              sortDirection: _sortDirection,
                            );
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _historyLabel(NotificationHistoryFilter filter) {
    switch (filter) {
      case NotificationHistoryFilter.today:
        return 'Today';
      case NotificationHistoryFilter.thisWeek:
        return 'This Week';
      case NotificationHistoryFilter.thisMonth:
        return 'This Month';
      case NotificationHistoryFilter.custom:
        return 'Custom Date';
    }
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _customDateRange ??
          DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now),
    );
    if (picked != null) {
      setState(() => _customDateRange = picked);
    }
  }

  String _dateRangeLabel(DateTimeRange range) {
    return '${range.start.day}/${range.start.month}/${range.start.year} - '
        '${range.end.day}/${range.end.month}/${range.end.year}';
  }
}

class EmptyNotificationWidget extends StatelessWidget {
  const EmptyNotificationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 38),
      child: Column(
        children: [
          Icon(
            Icons.notifications_paused_outlined,
            size: 56,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'No notifications found',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try changing filters or send a new campaign.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.62),
            ),
          ),
        ],
      ),
    );
  }
}
