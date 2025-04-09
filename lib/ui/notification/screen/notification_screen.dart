import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../../models/notification_model.dart';
import '../../../models/transaction.dart';
import '../../../service/notification_service.dart';
import '../../order/screen/order_tracking_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> with SingleTickerProviderStateMixin {
  final NotificationService _notificationService = NotificationService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = true;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();

    // Khởi tạo animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    // Khởi tạo dữ liệu
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    await _notificationService.initialize();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleNotificationTap(NotificationModel notification) async {
    // Đánh dấu thông báo đã đọc
    await _notificationService.markAsRead(notification.id);
    setState(() {});

    // Xử lý hành động dựa trên loại thông báo
    if (notification.type == NotificationType.order && notification.actionData != null) {
      // Tạo một transaction giả để chuyển đến màn hình chi tiết đơn hàng
      final sampleTransaction = Transaction(
        id: notification.actionData!,
        title: 'Đơn hàng #${notification.actionData}',
        date: '${notification.time.day}/${notification.time.month}/${notification.time.year} ${notification.time.hour}:${notification.time.minute}',
        amount: 150000,
        status: 'Đang giặt',
      );

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OrderTrackingScreen(transaction: sampleTransaction),
          ),
        );
      }
    }
    // Có thể thêm các hành động khác tùy thuộc vào loại thông báo
  }

  Future<void> _markAllAsRead() async {
    await _notificationService.markAllAsRead();
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã đánh dấu tất cả thông báo là đã đọc'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _deleteAllNotifications() async {
    // Hiển thị dialog xác nhận
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tất cả thông báo?'),
        content: const Text('Bạn có chắc chắn muốn xóa tất cả thông báo không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isDeleting = true;
      });

      await _notificationService.deleteAllNotifications();

      if (mounted) {
        setState(() {
          _isDeleting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa tất cả thông báo'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<bool> _handleDismiss(NotificationModel notification) async {
    await _notificationService.deleteNotification(notification.id);
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã xóa thông báo'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Hoàn tác',
          onPressed: () {
            _notificationService.addNotification(notification);
            setState(() {});
          },
        ),
      ),
    );

    return true;
  }

  @override
  Widget build(BuildContext context) {
    // Lấy kích thước màn hình để responsive
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Thông báo',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: Colors.black87),
            tooltip: 'Đánh dấu tất cả đã đọc',
            onPressed: _notificationService.unreadCount > 0 ? _markAllAsRead : null,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.black87),
            tooltip: 'Xóa tất cả',
            onPressed: _notificationService.getAllNotifications().isNotEmpty ? _deleteAllNotifications : null,
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _isDeleting
          ? _buildDeletingState()
          : _notificationService.getAllNotifications().isEmpty
          ? _buildEmptyState()
          : _buildNotificationList(isSmallScreen),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4ECDC4)),
      ),
    );
  }

  Widget _buildDeletingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4ECDC4)),
          ),
          const SizedBox(height: 16),
          Text(
            'Đang xóa thông báo...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_off_outlined,
                size: 60,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Không có thông báo nào',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bạn sẽ nhận được thông báo khi có cập nhật mới',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loadNotifications,
              icon: const Icon(Icons.refresh),
              label: const Text('Làm mới'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4ECDC4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationList(bool isSmallScreen) {
    final groupedNotifications = _notificationService.getGroupedNotifications();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        color: const Color(0xFF4ECDC4),
        onRefresh: _loadNotifications,
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 24),
          itemCount: groupedNotifications.length,
          itemBuilder: (context, index) {
            final groupEntry = groupedNotifications.entries.elementAt(index);
            final groupName = groupEntry.key;
            final notifications = groupEntry.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGroupHeader(groupName),
                ...notifications.map((notification) {
                  return _buildNotificationItem(notification, isSmallScreen);
                }).toList(),
                const SizedBox(height: 8),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildGroupHeader(String groupName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        groupName,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4ECDC4),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification, bool isSmallScreen) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red.shade400,
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (_) => _handleDismiss(notification),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : const Color(0xFFF0FFFD),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: notification.isRead
              ? Border.all(color: Colors.grey.shade200)
              : Border.all(color: const Color(0xFF4ECDC4).withOpacity(0.3)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _handleNotificationTap(notification),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNotificationIcon(notification.type),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 14 : 15,
                                  fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatTime(notification.time),
                              style: TextStyle(
                                fontSize: isSmallScreen ? 11 : 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.message,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 13,
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (!notification.isRead) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF4ECDC4),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationType type) {
    IconData icon;
    Color color;

    switch (type) {
      case NotificationType.order:
        icon = Icons.local_shipping_outlined;
        color = const Color(0xFF4ECDC4);
        break;
      case NotificationType.promotion:
        icon = Icons.local_offer_outlined;
        color = Colors.orange;
        break;
      case NotificationType.system:
        icon = Icons.info_outline;
        color = Colors.blue;
        break;
      case NotificationType.payment:
        icon = Icons.payment_outlined;
        color = Colors.green;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: color,
        size: 20,
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final notificationDate = DateTime(time.year, time.month, time.day);

    if (notificationDate == today) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (notificationDate == yesterday) {
      return 'Hôm qua';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}

