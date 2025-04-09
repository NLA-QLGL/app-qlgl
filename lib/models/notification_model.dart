enum NotificationType {
  order,
  promotion,
  system,
  payment,
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime time;
  final NotificationType type;
  final bool isRead;
  final String? actionData; // Dữ liệu để thực hiện hành động khi nhấn vào thông báo (ví dụ: ID đơn hàng)

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    this.isRead = false,
    this.actionData,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? time,
    NotificationType? type,
    bool? isRead,
    String? actionData,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      time: time ?? this.time,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      actionData: actionData ?? this.actionData,
    );
  }

  // Tạo danh sách thông báo mẫu
  static List<NotificationModel> getSampleNotifications() {
    final now = DateTime.now();

    return [
      // Hôm nay
      NotificationModel(
        id: '1',
        title: 'Đơn hàng đã được xác nhận',
        message: 'Đơn hàng #12345 của bạn đã được xác nhận và đang được xử lý.',
        time: now.subtract(const Duration(hours: 1)),
        type: NotificationType.order,
        actionData: '12345',
      ),
      NotificationModel(
        id: '2',
        title: 'Khuyến mãi đặc biệt',
        message: 'Giảm 30% cho dịch vụ giặt chăn từ ngày 15/05 đến 30/05.',
        time: now.subtract(const Duration(hours: 3)),
        type: NotificationType.promotion,
        isRead: true,
      ),

      // Hôm qua
      NotificationModel(
        id: '3',
        title: 'Đơn hàng đã hoàn thành',
        message: 'Đơn hàng #12340 của bạn đã được giao thành công.',
        time: now.subtract(const Duration(days: 1, hours: 5)),
        type: NotificationType.order,
        isRead: true,
        actionData: '12340',
      ),
      NotificationModel(
        id: '4',
        title: 'Thanh toán thành công',
        message: 'Bạn đã thanh toán thành công 150.000đ cho đơn hàng #12340.',
        time: now.subtract(const Duration(days: 1, hours: 7)),
        type: NotificationType.payment,
        isRead: true,
      ),

      // Tuần này
      NotificationModel(
        id: '5',
        title: 'Cập nhật hệ thống',
        message: 'Ứng dụng sẽ bảo trì từ 23:00 ngày 10/05 đến 02:00 ngày 11/05.',
        time: now.subtract(const Duration(days: 3)),
        type: NotificationType.system,
      ),
      NotificationModel(
        id: '6',
        title: 'Đơn hàng đã được xác nhận',
        message: 'Đơn hàng #12338 của bạn đã được xác nhận và đang được xử lý.',
        time: now.subtract(const Duration(days: 4)),
        type: NotificationType.order,
        isRead: true,
        actionData: '12338',
      ),

      // Tháng này
      NotificationModel(
        id: '7',
        title: 'Khuyến mãi tháng 5',
        message: 'Giảm 20% cho tất cả các dịch vụ giặt là trong tháng 5.',
        time: now.subtract(const Duration(days: 15)),
        type: NotificationType.promotion,
        isRead: true,
      ),
      NotificationModel(
        id: '8',
        title: 'Chào mừng bạn đến với ứng dụng',
        message: 'Cảm ơn bạn đã cài đặt ứng dụng Quản lý giặt. Hãy khám phá các tính năng ngay!',
        time: now.subtract(const Duration(days: 20)),
        type: NotificationType.system,
        isRead: true,
      ),
    ];
  }
}