enum NotificationRecipientType {
  adminOnly,
  allUsers,
  selectedUsers,
  productionTeam,
  directors,
  actors,
  mediaPartners,
}

enum NotificationPriority { low, medium, high, urgent }

enum NotificationType { push, email, sms }

enum NotificationDeliveryStatus { delivered, scheduled, failed, sending }

enum NotificationHistoryFilter { today, thisWeek, thisMonth, custom }

extension NotificationRecipientTypeLabel on NotificationRecipientType {
  String get label {
    switch (this) {
      case NotificationRecipientType.adminOnly:
        return 'Send to Admin Only';
      case NotificationRecipientType.allUsers:
        return 'Send to All Users';
      case NotificationRecipientType.selectedUsers:
        return 'Send to Selected Users';
      case NotificationRecipientType.productionTeam:
        return 'Send to Production Team';
      case NotificationRecipientType.directors:
        return 'Send to Directors';
      case NotificationRecipientType.actors:
        return 'Send to Actors';
      case NotificationRecipientType.mediaPartners:
        return 'Send to Media Partners';
    }
  }
}

extension NotificationPriorityLabel on NotificationPriority {
  String get label {
    switch (this) {
      case NotificationPriority.low:
        return 'Low';
      case NotificationPriority.medium:
        return 'Medium';
      case NotificationPriority.high:
        return 'High';
      case NotificationPriority.urgent:
        return 'Urgent';
    }
  }
}

extension NotificationTypeLabel on NotificationType {
  String get label {
    switch (this) {
      case NotificationType.push:
        return 'Push';
      case NotificationType.email:
        return 'Email';
      case NotificationType.sms:
        return 'SMS';
    }
  }
}

extension NotificationDeliveryStatusLabel on NotificationDeliveryStatus {
  String get label {
    switch (this) {
      case NotificationDeliveryStatus.delivered:
        return 'Delivered';
      case NotificationDeliveryStatus.scheduled:
        return 'Scheduled';
      case NotificationDeliveryStatus.failed:
        return 'Failed';
      case NotificationDeliveryStatus.sending:
        return 'Sending';
    }
  }
}

class NotificationSettingsModel {
  final NotificationRecipientType recipientType;
  final List<int> selectedUserIds;
  final NotificationPriority priority;
  final bool sendPush;
  final bool sendEmail;
  final bool sendSms;

  const NotificationSettingsModel({
    this.recipientType = NotificationRecipientType.adminOnly,
    this.selectedUserIds = const [],
    this.priority = NotificationPriority.medium,
    this.sendPush = true,
    this.sendEmail = true,
    this.sendSms = false,
  });

  NotificationSettingsModel copyWith({
    NotificationRecipientType? recipientType,
    List<int>? selectedUserIds,
    NotificationPriority? priority,
    bool? sendPush,
    bool? sendEmail,
    bool? sendSms,
  }) {
    return NotificationSettingsModel(
      recipientType: recipientType ?? this.recipientType,
      selectedUserIds: selectedUserIds ?? this.selectedUserIds,
      priority: priority ?? this.priority,
      sendPush: sendPush ?? this.sendPush,
      sendEmail: sendEmail ?? this.sendEmail,
      sendSms: sendSms ?? this.sendSms,
    );
  }
}
