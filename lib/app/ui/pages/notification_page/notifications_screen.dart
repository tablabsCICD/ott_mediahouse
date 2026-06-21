import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:media_house/app/provider/notification_provider.dart';
import 'package:media_house/data/models/response/notification_response_model.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().getNotifications();
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 420) {
      context.read<NotificationProvider>().loadMoreNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Consumer<NotificationProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading) {
                      return const _NotificationLoadingList();
                    }

                    if (provider.errorMessage != null &&
                        provider.notifications.isEmpty) {
                      return _ErrorState(
                        message: provider.errorMessage!,
                        onRetry: provider.getNotifications,
                      );
                    }

                    if (provider.notifications.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: provider.refreshNotifications,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 120),
                            _EmptyState(),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: provider.refreshNotifications,
                      child: FocusTraversalGroup(
                        policy: OrderedTraversalPolicy(),
                        child: ListView.builder(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: provider.notifications.length +
                              (provider.isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= provider.notifications.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 18),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              );
                            }

                            final notification = provider.notifications[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: NotificationCard(
                                notification: notification,
                                autofocus: index == 0,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: theme.primaryColor.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.notifications_active_outlined,
              color: theme.primaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Notifications',
            style: TextStyle(
              color: theme.canvasColor,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class NotificationCard extends StatefulWidget {
  const NotificationCard({
    super.key,
    required this.notification,
    this.autofocus = false,
  });

  final NotificationItemModel notification;
  final bool autofocus;

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = widget.notification;
    final unread = item.isUnread;
    final borderColor =
        unread ? theme.primaryColor : theme.canvasColor.withValues(alpha: 0.12);
    final cardColor =
        unread ? theme.primaryColor.withValues(alpha: 0.08) : theme.cardColor;

    return FocusableActionDetector(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      onShowFocusHighlight: (value) => setState(() => _focused = value),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        scale: _focused ? 1.015 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _focused ? theme.primaryColor : borderColor,
              width: _focused ? 2 : 1,
            ),
            boxShadow: [
              if (_focused)
                BoxShadow(
                  color: theme.primaryColor.withValues(alpha: 0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: unread ? 5 : 3,
                  decoration: BoxDecoration(
                    color: unread
                        ? theme.primaryColor
                        : theme.canvasColor.withValues(alpha: 0.18),
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(8),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              _display(item.notificationTitle,
                                  fallback: 'Notification'),
                              style: TextStyle(
                                color: theme.canvasColor,
                                fontSize: 17,
                                fontWeight:
                                    unread ? FontWeight.w800 : FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _display(item.messageDescription,
                              fallback: 'No message available.'),
                          style: TextStyle(
                            color: theme.canvasColor.withValues(alpha: 0.78),
                            fontSize: 14,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 14,
                          runSpacing: 8,
                          children: [
                            _MetaText(label: 'Sent By', value: item.sentBy),
                            _MetaText(
                              label: 'Sent Date',
                              value: _formatDate(item.sentDateTime),
                            ),
                          ],
                        ),
                        if ((item.attachmentUrl ?? '').trim().isNotEmpty) ...[
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () =>
                                _openAttachment(item.attachmentUrl!.trim()),
                            icon: const Icon(Icons.attach_file, size: 18),
                            label: const Text('View Attachment'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: theme.primaryColor,
                              side: BorderSide(color: theme.primaryColor),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openAttachment(String url) async {
    if (kIsWeb) {
      html.window.open(url, '_blank');
      return;
    }
    await OpenFile.open(url);
  }

  String _display(String? value, {required String fallback}) {
    final text = value?.trim();
    return text == null || text.isEmpty ? fallback : text;
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return '-';
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime.toLocal());
  }

  Color _priorityColor(String? priority) {
    switch ((priority ?? '').toUpperCase()) {
      case 'HIGH':
        return Colors.red;
      case 'MEDIUM':
        return Colors.orange;
      case 'LOW':
      default:
        return Colors.green;
    }
  }

  Color _statusColor(String? status) {
    switch ((status ?? '').toUpperCase()) {
      case 'DELIVERED':
      case 'SUCCESS':
        return Colors.green;
      case 'FAILED':
        return Colors.red;
      case 'PENDING':
      default:
        return Colors.orange;
    }
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _MetaText extends StatelessWidget {
  const _MetaText({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = value?.trim();
    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: theme.canvasColor.withValues(alpha: 0.68),
          fontSize: 12.5,
        ),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: text == null || text.isEmpty ? '-' : text),
        ],
      ),
    );
  }
}

class _NotificationLoadingList extends StatelessWidget {
  const _NotificationLoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: _SkeletonCard(),
        );
      },
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.35, end: 0.75),
      duration: const Duration(milliseconds: 850),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        final color = theme.canvasColor.withValues(alpha: value * 0.16);
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.canvasColor.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SkeletonLine(width: 260, height: 18, color: color),
              const SizedBox(height: 12),
              _SkeletonLine(width: double.infinity, height: 12, color: color),
              const SizedBox(height: 8),
              _SkeletonLine(width: 420, height: 12, color: color),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                children: [
                  _SkeletonLine(width: 120, height: 24, color: color),
                  _SkeletonLine(width: 120, height: 24, color: color),
                  _SkeletonLine(width: 160, height: 24, color: color),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({
    required this.width,
    required this.height,
    required this.color,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 62,
            color: theme.primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No Notifications',
            style: TextStyle(
              color: theme.canvasColor,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You have not received any notifications yet.',
            style: TextStyle(
              color: theme.canvasColor.withValues(alpha: 0.65),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 58, color: theme.primaryColor),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.canvasColor),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
