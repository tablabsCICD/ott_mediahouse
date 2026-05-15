import 'notification_settings_model.dart';

class NotificationModel {
  final int id;
  final String title;
  final String message;
  final String sentBy;
  final DateTime sentAt;
  final NotificationRecipientType recipientType;
  final NotificationDeliveryStatus deliveryStatus;
  final NotificationType notificationType;
  final NotificationPriority priority;
  final int recipientCount;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.sentBy,
    required this.sentAt,
    required this.recipientType,
    required this.deliveryStatus,
    required this.notificationType,
    required this.priority,
    required this.recipientCount,
  });

  NotificationModel copyWith({
    int? id,
    String? title,
    String? message,
    String? sentBy,
    DateTime? sentAt,
    NotificationRecipientType? recipientType,
    NotificationDeliveryStatus? deliveryStatus,
    NotificationType? notificationType,
    NotificationPriority? priority,
    int? recipientCount,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      sentBy: sentBy ?? this.sentBy,
      sentAt: sentAt ?? this.sentAt,
      recipientType: recipientType ?? this.recipientType,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      notificationType: notificationType ?? this.notificationType,
      priority: priority ?? this.priority,
      recipientCount: recipientCount ?? this.recipientCount,
    );
  }
}
