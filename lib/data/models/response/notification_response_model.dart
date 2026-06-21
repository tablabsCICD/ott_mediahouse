class NotificationResponseModel {
  NotificationResponseModel({
    this.success,
    this.message,
    this.data,
  });

  final bool? success;
  final String? message;
  final NotificationDataModel? data;

  factory NotificationResponseModel.fromJson(Map<String, dynamic> json) {
    return NotificationResponseModel(
      success: _toBool(json['success'] ?? json['isSuccess']),
      message: json['message']?.toString(),
      data: NotificationDataModel.fromAny(json['data'] ?? json),
    );
  }

  static bool? _toBool(dynamic value) {
    if (value is bool) return value;
    if (value == null) return null;
    final normalized = value.toString().toLowerCase().trim();
    if (normalized == 'true') return true;
    if (normalized == 'false') return false;
    return null;
  }
}

class NotificationDataModel {
  NotificationDataModel({
    this.items = const [],
    this.pageNo,
    this.pageSize,
    this.totalPages,
    this.totalElements,
    this.last,
  });

  final List<NotificationItemModel> items;
  final int? pageNo;
  final int? pageSize;
  final int? totalPages;
  final int? totalElements;
  final bool? last;

  factory NotificationDataModel.fromAny(dynamic raw) {
    if (raw is List) {
      return NotificationDataModel(items: _itemsFromList(raw));
    }

    if (raw is! Map) {
      return NotificationDataModel();
    }

    final json = Map<String, dynamic>.from(raw);
    final listRaw = json['content'] ??
        json['notifications'] ??
        json['notificationList'] ??
        json['notificationResponses'] ??
        json['pushNotifications'] ??
        json['pushNotificationList'] ??
        json['results'] ??
        json['items'] ??
        json['data'] ??
        json['records'];

    return NotificationDataModel(
      items: listRaw is List ? _itemsFromList(listRaw) : const [],
      pageNo: _toInt(json['pageNo'] ?? json['pageNumber'] ?? json['number']),
      pageSize: _toInt(json['pageSize'] ?? json['size']),
      totalPages: _toInt(json['totalPages']),
      totalElements: _toInt(json['totalElements'] ?? json['totalItems']),
      last: _toBool(json['last'] ?? json['isLast']),
    );
  }

  static List<NotificationItemModel> _itemsFromList(List<dynamic> list) {
    return list
        .whereType<Map>()
        .map((item) => NotificationItemModel.fromJson(
              Map<String, dynamic>.from(item),
            ))
        .toList(growable: false);
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value == null) return null;
    return int.tryParse(value.toString());
  }

  static bool? _toBool(dynamic value) {
    if (value is bool) return value;
    if (value == null) return null;
    final normalized = value.toString().toLowerCase().trim();
    if (normalized == 'true') return true;
    if (normalized == 'false') return false;
    return null;
  }
}

class NotificationItemModel {
  NotificationItemModel({
    this.id,
    this.notificationTitle,
    this.messageDescription,
    this.emailSubject,
    this.attachmentUrl,
    this.mediaHouseId,
    this.priority,
    this.recipientType,
    this.notificationType,
    this.totalRecipients,
    this.successCount,
    this.failedCount,
    this.deliveryStatus,
    this.sentBy,
    this.recipientId,
    this.sentDateTime,
    this.createdDate,
    this.openedAt,
    this.readAt,
    this.attachments = const [],
    this.recipientStatuses = const [],
  });

  final int? id;
  final String? notificationTitle;
  final String? messageDescription;
  final String? emailSubject;
  final String? attachmentUrl;
  final int? mediaHouseId;
  final String? priority;
  final String? recipientType;
  final String? notificationType;
  final int? totalRecipients;
  final int? successCount;
  final int? failedCount;
  final String? deliveryStatus;
  final String? sentBy;
  final int? recipientId;
  final DateTime? sentDateTime;
  final DateTime? createdDate;
  final DateTime? openedAt;
  final DateTime? readAt;
  final List<dynamic> attachments;
  final List<dynamic> recipientStatuses;

  bool get isUnread => readAt == null;

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
    return NotificationItemModel(
      id: _toInt(json['id'] ?? json['notificationId']),
      notificationTitle: _text(
        json['notificationTitle'] ?? json['title'] ?? json['subject'],
      ),
      messageDescription: _text(
        json['messageDescription'] ??
            json['message'] ??
            json['body'] ??
            json['description'],
      ),
      emailSubject: _text(json['emailSubject'] ?? json['subject']),
      attachmentUrl: _text(
        json['attachmentUrl'] ?? json['attachment'] ?? json['fileUrl'],
      ),
      mediaHouseId: _toInt(json['mediaHouseId'] ?? json['media_house_id']),
      priority: json['priority']?.toString(),
      recipientType: json['recipientType']?.toString(),
      notificationType: json['notificationType']?.toString(),
      totalRecipients: _toInt(json['totalRecipients']),
      successCount: _toInt(json['successCount']),
      failedCount: _toInt(json['failedCount']),
      deliveryStatus: json['deliveryStatus']?.toString(),
      sentBy: _text(json['sentBy'] ?? json['senderName'] ?? json['createdBy']),
      recipientId: _toInt(json['recipientId'] ?? json['userId']),
      sentDateTime: _toDate(
        json['sentDateTime'] ?? json['sentAt'] ?? json['createdAt'],
      ),
      createdDate: _toDate(json['createdDate'] ?? json['createdAt']),
      openedAt: _toDate(json['openedAt']),
      readAt: _toDate(json['readAt']),
      attachments: _toList(json['attachments']),
      recipientStatuses: _toList(json['recipientStatuses']),
    );
  }

  static String? _text(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }
    return text;
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value == null) return null;
    return int.tryParse(value.toString());
  }

  static DateTime? _toDate(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }
    return DateTime.tryParse(text);
  }

  static List<dynamic> _toList(dynamic value) {
    if (value is List) return List<dynamic>.from(value);
    return const [];
  }
}
