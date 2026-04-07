class NotificationResponse {
  bool? status;
  String? message;
  NotificationData? data;

  NotificationResponse({this.status, this.message, this.data});

  NotificationResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? NotificationData.fromJson(json['data']) : null;
  }
}

class NotificationData {
  List<NotificationModel>? notifications;
  int? unreadCount;

  NotificationData({this.notifications, this.unreadCount});

  NotificationData.fromJson(Map<String, dynamic> json) {
    if (json['notifications'] != null) {
      notifications = <NotificationModel>[];
      json['notifications'].forEach((v) {
        notifications!.add(NotificationModel.fromJson(v));
      });
    }
    unreadCount = json['unreadCount'];
  }
}

class NotificationModel {
  int? id;
  int? userId;
  String? title;
  String? message;
  String? type;
  bool? isRead;
  String? createdAt;
  String? updatedAt;

  NotificationModel(
      {this.id,
      this.userId,
      this.title,
      this.message,
      this.type,
      this.isRead,
      this.createdAt,
      this.updatedAt});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    title = json['title'];
    message = json['message'];
    type = json['type'];
    isRead = json['is_read'] is int ? json['is_read'] == 1 : json['is_read'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
}
