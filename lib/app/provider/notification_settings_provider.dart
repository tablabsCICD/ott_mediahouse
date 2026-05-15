import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:media_house/data/services/mock_notification_service.dart';
import 'package:media_house/domain/entities/notification_model.dart';
import 'package:media_house/domain/entities/notification_settings_model.dart';
import 'package:media_house/domain/entities/user_model.dart';

class NotificationSettingsProvider extends ChangeNotifier {
  NotificationSettingsProvider({
    MockNotificationService? service,
  }) : _service = service ?? MockNotificationService();

  final MockNotificationService _service;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final TextEditingController emailSubjectController = TextEditingController();
  final TextEditingController historySearchController = TextEditingController();

  NotificationSettingsModel _settings = const NotificationSettingsModel();
  NotificationSettingsModel get settings => _settings;

  List<UserModel> _users = [];
  List<UserModel> get users => List.unmodifiable(_users);

  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => List.unmodifiable(_notifications);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSending = false;
  bool get isSending => _isSending;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _attachmentName;
  String? get attachmentName => _attachmentName;

  NotificationHistoryFilter? _historyFilter;
  NotificationHistoryFilter? get historyFilter => _historyFilter;

  NotificationType? _typeFilter;
  NotificationType? get typeFilter => _typeFilter;

  NotificationDeliveryStatus? _statusFilter;
  NotificationDeliveryStatus? get statusFilter => _statusFilter;

  DateTimeRange? _customDateRange;
  DateTimeRange? get customDateRange => _customDateRange;

  int _page = 1;
  static const int _pageSize = 8;

  int get totalSent => _notifications.length;
  int get failedCount => _notifications
      .where((item) => item.deliveryStatus == NotificationDeliveryStatus.failed)
      .length;
  int get deliveredCount => _notifications
      .where((item) => item.deliveryStatus == NotificationDeliveryStatus.delivered)
      .length;
  double get successRate =>
      _notifications.isEmpty ? 0 : deliveredCount / _notifications.length;

  List<UserModel> get selectedUsers {
    final ids = _settings.selectedUserIds.toSet();
    return _users.where((user) => ids.contains(user.id)).toList();
  }

  bool get hasActiveFilters =>
      _historyFilter != null || _typeFilter != null || _statusFilter != null;

  Future<void> initialize() async {
    if (_users.isNotEmpty || _isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _users = await _service.fetchUsers();
      _notifications =
          await _service.fetchNotifications(page: 1, limit: _pageSize);
      _page = 1;
      _hasMore = _notifications.length == _pageSize;
    } catch (error) {
      _errorMessage = 'Unable to load settings data: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _page = 1;
    _hasMore = true;
    _errorMessage = null;
    try {
      _users = await _service.fetchUsers();
      _notifications = await _service.fetchNotifications(
        page: _page,
        limit: _pageSize,
        query: historySearchController.text,
        filter: _historyFilter,
        type: _typeFilter,
        status: _statusFilter,
        startDate: _customDateRange?.start,
        endDate: _customDateRange?.end,
      );
      _hasMore = _notifications.length == _pageSize;
    } catch (error) {
      _errorMessage = 'Unable to refresh notifications: $error';
    }
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    notifyListeners();
    try {
      final nextPage = _page + 1;
      final nextItems = await _service.fetchNotifications(
        page: nextPage,
        limit: _pageSize,
        query: historySearchController.text,
        filter: _historyFilter,
        type: _typeFilter,
        status: _statusFilter,
        startDate: _customDateRange?.start,
        endDate: _customDateRange?.end,
      );
      _notifications = [..._notifications, ...nextItems];
      _page = nextPage;
      _hasMore = nextItems.length == _pageSize;
    } catch (error) {
      _errorMessage = 'Unable to load more notifications: $error';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void updateRecipientType(NotificationRecipientType type) {
    _settings = _settings.copyWith(recipientType: type);
    notifyListeners();
  }

  void toggleSelectedUser(UserModel user) {
    final ids = List<int>.from(_settings.selectedUserIds);
    ids.contains(user.id) ? ids.remove(user.id) : ids.add(user.id);
    _settings = _settings.copyWith(
      recipientType: NotificationRecipientType.selectedUsers,
      selectedUserIds: ids,
    );
    notifyListeners();
  }

  void removeSelectedUser(int userId) {
    final ids = List<int>.from(_settings.selectedUserIds)..remove(userId);
    _settings = _settings.copyWith(selectedUserIds: ids);
    notifyListeners();
  }

  void updatePriority(NotificationPriority priority) {
    _settings = _settings.copyWith(priority: priority);
    notifyListeners();
  }

  void updateChannel(NotificationType type, bool value) {
    _settings = _settings.copyWith(
      sendPush: type == NotificationType.push ? value : null,
      sendEmail: type == NotificationType.email ? value : null,
      sendSms: type == NotificationType.sms ? value : null,
    );
    notifyListeners();
  }

  Future<void> pickAttachment() async {
    final result = await FilePicker.platform.pickFiles(withData: false);
    if (result == null || result.files.isEmpty) return;
    _attachmentName = result.files.single.name;
    notifyListeners();
  }

  void clearAttachment() {
    _attachmentName = null;
    notifyListeners();
  }

  String? validateComposer() {
    if (titleController.text.trim().isEmpty) {
      return 'Notification title is required.';
    }
    if (messageController.text.trim().isEmpty) {
      return 'Message description is required.';
    }
    if (emailSubjectController.text.trim().isEmpty && _settings.sendEmail) {
      return 'Email subject is required when email is enabled.';
    }
    if (!_settings.sendPush && !_settings.sendEmail && !_settings.sendSms) {
      return 'Choose at least one delivery channel.';
    }
    if (_settings.recipientType == NotificationRecipientType.selectedUsers &&
        _settings.selectedUserIds.isEmpty) {
      return 'Select at least one user.';
    }
    return null;
  }

  Future<String?> sendNow({DateTime? scheduledAt}) async {
    final validationMessage = validateComposer();
    if (validationMessage != null) return validationMessage;

    _isSending = true;
    notifyListeners();
    try {
      final sent = await _service.sendNotification(
        title: titleController.text.trim(),
        message: messageController.text.trim(),
        emailSubject: emailSubjectController.text.trim(),
        settings: _settings,
        attachmentName: _attachmentName,
        scheduledAt: scheduledAt,
      );
      _notifications = [sent, ..._notifications];
      titleController.clear();
      messageController.clear();
      emailSubjectController.clear();
      _attachmentName = null;
      _errorMessage = null;
      return null;
    } catch (error) {
      return 'Unable to send notification: $error';
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  Future<void> resend(NotificationModel notification) async {
    _isSending = true;
    notifyListeners();
    try {
      final resent = await _service.sendNotification(
        title: notification.title,
        message: notification.message,
        emailSubject: notification.title,
        settings: _settings.copyWith(
          recipientType: notification.recipientType,
          priority: notification.priority,
        ),
      );
      _notifications = [resent, ..._notifications];
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  Future<void> deleteNotification(int id) async {
    await _service.deleteNotification(id);
    _notifications = _notifications.where((item) => item.id != id).toList();
    notifyListeners();
  }

  Future<void> applyFilters({
    NotificationHistoryFilter? historyFilter,
    NotificationType? typeFilter,
    NotificationDeliveryStatus? statusFilter,
    DateTimeRange? customDateRange,
    bool clear = false,
  }) async {
    if (clear) {
      _historyFilter = null;
      _typeFilter = null;
      _statusFilter = null;
      _customDateRange = null;
    } else {
      _historyFilter = historyFilter;
      _typeFilter = typeFilter;
      _statusFilter = statusFilter;
      _customDateRange = customDateRange;
    }
    await refresh();
  }

  Future<void> searchHistory(String query) async {
    await refresh();
  }

  @override
  void dispose() {
    titleController.dispose();
    messageController.dispose();
    emailSubjectController.dispose();
    historySearchController.dispose();
    super.dispose();
  }
}
