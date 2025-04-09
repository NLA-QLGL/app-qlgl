import 'dart:async';
import '../models/notification_model.dart';

class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Danh sách thông báo
  List<NotificationModel> _notifications = [];

  // Stream controller để phát sự kiện khi có thông báo mới
  final _notificationController = StreamController<List<NotificationModel>>.broadcast();
  Stream<List<NotificationModel>> get notificationStream => _notificationController.stream;

  // Số lượng thông báo chưa đọc
  int get unreadCount => _notifications.where((notification) => !notification.isRead).length;

  // Khởi tạo dữ liệu
  Future<void> initialize() async {
    // Trong ứng dụng thực tế, bạn sẽ tải thông báo từ local storage hoặc API
    _notifications = NotificationModel.getSampleNotifications();
    _notificationController.add(_notifications);
  }

  // Lấy tất cả thông báo
  List<NotificationModel> getAllNotifications() {
    return List.from(_notifications);
  }

  // Lấy thông báo theo ID
  NotificationModel? getNotificationById(String id) {
    try {
      return _notifications.firstWhere((notification) => notification.id == id);
    } catch (e) {
      return null;
    }
  }

  // Thêm thông báo mới
  Future<void> addNotification(NotificationModel notification) async {
    _notifications.insert(0, notification);
    _notificationController.add(_notifications);
  }

  // Đánh dấu thông báo đã đọc
  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((notification) => notification.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _notificationController.add(_notifications);
    }
  }

  // Đánh dấu tất cả thông báo đã đọc
  Future<void> markAllAsRead() async {
    _notifications = _notifications.map((notification) =>
        notification.copyWith(isRead: true)
    ).toList();
    _notificationController.add(_notifications);
  }

  // Xóa thông báo
  Future<void> deleteNotification(String id) async {
    _notifications.removeWhere((notification) => notification.id == id);
    _notificationController.add(_notifications);
  }

  // Xóa tất cả thông báo
  Future<void> deleteAllNotifications() async {
    _notifications.clear();
    _notificationController.add(_notifications);
  }

  // Nhóm thông báo theo ngày
  Map<String, List<NotificationModel>> getGroupedNotifications() {
    final Map<String, List<NotificationModel>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (var notification in _notifications) {
      final notificationDate = DateTime(
        notification.time.year,
        notification.time.month,
        notification.time.day,
      );

      String group;

      if (notificationDate == today) {
        group = 'Hôm nay';
      } else if (notificationDate == yesterday) {
        group = 'Hôm qua';
      } else if (today.difference(notificationDate).inDays <= 7) {
        group = 'Tuần này';
      } else if (notificationDate.month == today.month && notificationDate.year == today.year) {
        group = 'Tháng này';
      } else {
        group = 'Trước đó';
      }

      if (!grouped.containsKey(group)) {
        grouped[group] = [];
      }

      grouped[group]!.add(notification);
    }

    return grouped;
  }

  // Đóng stream controller khi không cần thiết
  void dispose() {
    _notificationController.close();
  }
}

