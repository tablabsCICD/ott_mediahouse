import 'package:flutter/material.dart';
import 'package:media_house/app/provider/notification_settings_provider.dart';
import 'package:media_house/app/ui/pages/settings_page/widgets/settings_widgets.dart';
import 'package:media_house/domain/entities/notification_model.dart';
import 'package:media_house/domain/entities/notification_settings_model.dart';
import 'package:provider/provider.dart';

class ProductionSettingsPage extends StatefulWidget {
  const ProductionSettingsPage({super.key});

  @override
  State<ProductionSettingsPage> createState() => _ProductionSettingsPageState();
}

class _ProductionSettingsPageState extends State<ProductionSettingsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationSettingsProvider>().initialize();
    });
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels > position.maxScrollExtent - 320) {
      context.read<NotificationSettingsProvider>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationSettingsProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: provider.refresh,
                  child: ListView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(18),
                    children: [
                      const SettingsCustomAppBar(),
                      const SizedBox(height: 18),
                      if (provider.errorMessage != null)
                        _ErrorBanner(message: provider.errorMessage!),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 1050;
                          if (isWide) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Column(
                                    children: const [
                                      NotificationAnalyticsCard(),
                                      SizedBox(height: 16),
                                      _NotificationSettingsSection(),
                                      SizedBox(height: 16),
                                      _MessageComposerSection(),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    children: const [
                                      _RecentActivitySection(),
                                      SizedBox(height: 16),
                                      _NotificationHistorySection(),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }
                          return Column(
                            children: const [
                              NotificationAnalyticsCard(),
                              SizedBox(height: 16),
                              _NotificationSettingsSection(),
                              SizedBox(height: 16),
                              _MessageComposerSection(),
                              SizedBox(height: 16),
                              _RecentActivitySection(),
                              SizedBox(height: 16),
                              _NotificationHistorySection(),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _NotificationSettingsSection extends StatelessWidget {
  const _NotificationSettingsSection();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationSettingsProvider>();
    final settings = provider.settings;
    final theme = Theme.of(context);

    return SettingsSectionCard(
      title: 'Notification Settings',
      icon: Icons.campaign_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<NotificationRecipientType>(
            initialValue: settings.recipientType,
            isExpanded: true,
            dropdownColor: theme.cardColor,
            iconEnabledColor: theme.colorScheme.primary,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              labelText: 'Send Notification To',
              labelStyle: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.68),
              ),
              prefixIcon: Icon(
                Icons.groups_2_outlined,
                color: theme.canvasColor,
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: theme.dividerColor.withOpacity(0.35),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 1.4,
                ),
              ),
            ),
            items: NotificationRecipientType.values.map((type) {
              return DropdownMenuItem<NotificationRecipientType>(
                value: type,
                child: Text(
                  type.label,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
            onChanged: (type) {
              if (type != null) {
                provider.updateRecipientType(type);
              }
            },
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: settings.recipientType ==
                    NotificationRecipientType.selectedUsers
                ? Column(
                    key: const ValueKey('selected-users'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) => const UserSelectionDialog(),
                        ),
                        icon: const Icon(Icons.group_add_outlined),
                        label: const Text('Choose Selected Users'),
                      ),
                      const SizedBox(height: 12),
                      if (provider.selectedUsers.isEmpty)
                        Text(
                          'No users selected yet.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.62),
                          ),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: provider.selectedUsers.map((user) {
                            return InputChip(
                              backgroundColor: theme.colorScheme.surface,
                              selectedColor:
                                  theme.colorScheme.primary.withOpacity(0.12),
                              side: BorderSide(
                                color:
                                    theme.colorScheme.primary.withOpacity(0.35),
                              ),
                              labelStyle: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                              deleteIconColor: theme.colorScheme.primary,
                              avatar: CircleAvatar(
                                backgroundColor: theme.colorScheme.primary,
                                child: Text(
                                    user.name.isEmpty ? '?' : user.name[0]),
                              ),
                              label: Text(user.name),
                              onDeleted: () =>
                                  provider.removeSelectedUser(user.id),
                            );
                          }).toList(),
                        ),
                    ],
                  )
                : const SizedBox.shrink(key: ValueKey('no-selected-users')),
          ),
        ],
      ),
    );
  }
}

class _MessageComposerSection extends StatelessWidget {
  const _MessageComposerSection();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationSettingsProvider>();
    final settings = provider.settings;
    final theme = Theme.of(context);

    return SettingsSectionCard(
      title: 'Message Composer',
      icon: Icons.edit_notifications_rounded,
      child: Column(
        children: [
          TextField(
            controller: provider.titleController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Notification Title',
              prefixIcon: Icon(
                Icons.title_rounded,
                color: theme.canvasColor,
              ),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: provider.messageController,
            minLines: 4,
            maxLines: 6,
            decoration: InputDecoration(
              labelText: 'Message Description',
              alignLabelWithHint: true,
              prefixIcon: Icon(
                Icons.notes_rounded,
                color: theme.canvasColor,
              ),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: provider.emailSubjectController,
            decoration: InputDecoration(
              labelText: 'Email Subject',
              prefixIcon: Icon(
                Icons.mail_outline_rounded,
                color: theme.canvasColor,
              ),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          _AttachmentPicker(),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: SegmentedButton<NotificationPriority>(
              segments: NotificationPriority.values.map((priority) {
                return ButtonSegment(
                  value: priority,
                  label: Text(priority.label),
                  icon: Icon(_priorityIcon(priority)),
                );
              }).toList(),
              selected: {settings.priority},
              onSelectionChanged: (value) =>
                  provider.updatePriority(value.first),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilterChip(
                selected: settings.sendPush,
                label: const Text('Send Push Notification'),
                avatar: const Icon(Icons.notifications_active_outlined),
                selectedColor: theme.colorScheme.primary,
                backgroundColor: theme.colorScheme.surface,
                checkmarkColor: theme.colorScheme.onPrimary,
                labelStyle: TextStyle(
                  color: settings.sendPush
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface.withOpacity(0.78),
                  fontWeight:
                      settings.sendPush ? FontWeight.w700 : FontWeight.w500,
                ),
                side: BorderSide(
                  color: settings.sendPush
                      ? theme.colorScheme.primary
                      : theme.dividerColor.withOpacity(0.35),
                ),
                onSelected: (value) =>
                    provider.updateChannel(NotificationType.push, value),
              ),
              FilterChip(
                selected: settings.sendEmail,
                label: const Text('Send Email'),
                avatar: const Icon(Icons.mail_outline_rounded),
                selectedColor: theme.colorScheme.primary,
                backgroundColor: theme.colorScheme.surface,
                checkmarkColor: theme.colorScheme.onPrimary,
                labelStyle: TextStyle(
                  color: settings.sendEmail
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface.withOpacity(0.78),
                  fontWeight:
                      settings.sendEmail ? FontWeight.w700 : FontWeight.w500,
                ),
                side: BorderSide(
                  color: settings.sendEmail
                      ? theme.colorScheme.primary
                      : theme.dividerColor.withOpacity(0.35),
                ),
                onSelected: (value) =>
                    provider.updateChannel(NotificationType.email, value),
              ),
              FilterChip(
                selected: settings.sendSms,
                label: const Text('Send SMS/Text Message'),
                avatar: const Icon(Icons.sms_outlined),
                selectedColor: theme.colorScheme.primary,
                backgroundColor: theme.colorScheme.surface,
                checkmarkColor: theme.colorScheme.onPrimary,
                labelStyle: TextStyle(
                  color: settings.sendSms
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface.withOpacity(0.78),
                  fontWeight:
                      settings.sendSms ? FontWeight.w700 : FontWeight.w500,
                ),
                side: BorderSide(
                  color: settings.sendSms
                      ? theme.colorScheme.primary
                      : theme.dividerColor.withOpacity(0.35),
                ),
                onSelected: (value) =>
                    provider.updateChannel(NotificationType.sms, value),
              ),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 560;
              final buttons = [
                OutlinedButton.icon(
                  onPressed: () => _showPreview(context),
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Preview Message'),
                ),
                FilledButton.icon(
                  onPressed:
                      provider.isSending || provider.isAttachmentUploading
                          ? null
                          : () => _send(context),
                  icon: provider.isSending
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded),
                  label: const Text('Send Now'),
                ),
                FilledButton.tonalIcon(
                  onPressed:
                      provider.isSending || provider.isAttachmentUploading
                          ? null
                          : () => _schedule(context),
                  icon: const Icon(Icons.schedule_send_outlined),
                  label: const Text('Schedule Notification'),
                ),
              ];
              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: buttons
                      .map((button) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: button,
                          ))
                      .toList(),
                );
              }
              return Row(
                children: buttons
                    .map((button) => Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: button,
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  static IconData _priorityIcon(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Icons.keyboard_arrow_down_rounded;
      case NotificationPriority.medium:
        return Icons.drag_handle_rounded;
      case NotificationPriority.high:
        return Icons.keyboard_arrow_up_rounded;
      case NotificationPriority.urgent:
        return Icons.priority_high_rounded;
    }
  }

  void _showPreview(BuildContext context) {
    final provider = context.read<NotificationSettingsProvider>();
    final validation = provider.validateComposer();
    if (validation != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(validation)));
      return;
    }
    showDialog(
      context: context,
      builder: (_) => SendNotificationDialog(
        title: provider.titleController.text.trim(),
        message: provider.messageController.text.trim(),
        subject: provider.emailSubjectController.text.trim(),
      ),
    );
  }

  Future<void> _send(BuildContext context) async {
    final provider = context.read<NotificationSettingsProvider>();
    final message = await provider.sendNow();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? 'Notification sent successfully.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _schedule(BuildContext context) async {
    final provider = context.read<NotificationSettingsProvider>();
    final scheduledAt = await _pickScheduleDateTime(context);
    if (!context.mounted) return;
    if (scheduledAt == null) return;

    final message = await provider.scheduleNotification(scheduledAt);
    if (!context.mounted) return;
    final localizations = MaterialLocalizations.of(context);
    final scheduledLabel =
        '${localizations.formatFullDate(scheduledAt)} at ${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(scheduledAt))}';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? 'Notification scheduled for $scheduledLabel.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<DateTime?> _pickScheduleDateTime(BuildContext context) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(minutes: 15)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (!context.mounted || date == null) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(minutes: 15))),
    );
    if (time == null) return null;

    final scheduledAt = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    if (!scheduledAt.isAfter(DateTime.now())) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Choose a future date and time for scheduling.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return null;
    }
    return scheduledAt;
  }
}

class _AttachmentPicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationSettingsProvider>();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: Theme.of(context).dividerColor.withOpacity(0.22)),
      ),
      child: Row(
        children: [
          const Icon(Icons.attach_file_rounded),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              provider.isAttachmentUploading
                  ? 'Uploading ${provider.attachmentName ?? 'attachment'}...'
                  : provider.attachmentName ?? 'Optional Attachment Upload',
            ),
          ),
          if (provider.isAttachmentUploading)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          if (provider.attachmentName != null)
            IconButton(
              tooltip: 'Remove attachment',
              onPressed: provider.isAttachmentUploading
                  ? null
                  : provider.clearAttachment,
              icon: const Icon(Icons.close_rounded),
            ),
          OutlinedButton(
            onPressed:
                provider.isAttachmentUploading ? null : provider.pickAttachment,
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }
}

class SendNotificationDialog extends StatelessWidget {
  const SendNotificationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.subject,
  });

  final String title;
  final String message;
  final String subject;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Message Preview'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(message),
            const Divider(height: 24),
            Text('Email Subject', style: theme.textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(subject),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _NotificationHistorySection extends StatelessWidget {
  const _NotificationHistorySection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<NotificationSettingsProvider>();

    return SettingsSectionCard(
      title: 'Notification History',
      icon: Icons.history_rounded,
      trailing: IconButton.filledTonal(
        tooltip: 'Filters',
        onPressed: () => showModalBottomSheet(
          context: context,
          showDragHandle: true,
          isScrollControlled: true,
          builder: (_) => const FilterBottomSheet(),
        ),
        icon: Icon(provider.hasActiveFilters
            ? Icons.filter_alt_rounded
            : Icons.filter_alt_outlined),
      ),
      child: Column(
        children: [
          TextField(
            controller: provider.historySearchController,
            onSubmitted: provider.searchHistory,
            decoration: InputDecoration(
              hintText: 'Search title, message, or sender',
              prefixIcon: Icon(
                Icons.search_rounded,
                color: theme.canvasColor,
              ),
              suffixIcon: IconButton(
                tooltip: 'Search',
                onPressed: () => provider.searchHistory(
                  provider.historySearchController.text,
                ),
                icon: Icon(
                  Icons.arrow_forward_rounded,
                  color: theme.canvasColor,
                ),
              ),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          if (provider.notifications.isEmpty)
            const EmptyNotificationWidget()
          else
            ListView.builder(
              itemCount: provider.notifications.length +
                  (provider.isLoadingMore ? 1 : 0),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                if (index >= provider.notifications.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final notification = provider.notifications[index];
                return NotificationCard(
                  notification: notification,
                  onViewDetails: () => _showDetails(context, notification),
                  onResend: () => _resend(context, notification),
                  onDelete: () => provider.deleteNotification(notification.id),
                );
              },
            ),
        ],
      ),
    );
  }

  void _showDetails(BuildContext context, NotificationModel notification) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(notification.message),
              const SizedBox(height: 16),
              Text('Recipients: ${notification.recipientCount}'),
              Text('Recipient Type: ${notification.recipientType.label}'),
              Text('Delivery Status: ${notification.deliveryStatus.label}'),
              Text('Notification Type: ${notification.notificationType.label}'),
              Text('Priority: ${notification.priority.label}'),
            ],
          ),
        );
      },
    );
  }

  Future<void> _resend(
    BuildContext context,
    NotificationModel notification,
  ) async {
    final provider = context.read<NotificationSettingsProvider>();
    final message = await provider.resend(notification);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? 'Notification resent successfully.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _RecentActivitySection extends StatelessWidget {
  const _RecentActivitySection();

  @override
  Widget build(BuildContext context) {
    final notifications = context
        .watch<NotificationSettingsProvider>()
        .notifications
        .take(4)
        .toList();
    final theme = Theme.of(context);
    return SettingsSectionCard(
      title: 'Recent Activity',
      icon: Icons.timeline_rounded,
      child: notifications.isEmpty
          ? const EmptyNotificationWidget()
          : Column(
              children: notifications.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 34,
                        width: 34,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.14),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.bolt_rounded,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${item.deliveryStatus.label} via ${item.notificationType.label}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.62),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.22)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}
