import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../models/transaction.dart';

class OrderTrackingScreen extends StatefulWidget {
  final Transaction transaction;

  const OrderTrackingScreen({super.key, required this.transaction});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Determine current step based on transaction status
  late int _currentStep;

  // Rating state
  double _rating = 0;
  bool _hasRated = false;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();

    // Set current step based on transaction status
    if (widget.transaction.status == 'Đang giặt') {
      _currentStep = 1;
    } else if (widget.transaction.status == 'Đang phơi/sấy') {
      _currentStep = 2;
    } else if (widget.transaction.status == 'Đang giao hàng') {
      _currentStep = 3;
    } else if (widget.transaction.status == 'Thành công') {
      _currentStep = 4;
    } else {
      _currentStep = 0; // Default to "Đã nhận đơn"
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive design
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Thông tin đơn hàng',
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
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onPressed: () {
              _showOptionsMenu(context);
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // QR Code Section
              _buildQrCodeSection(isSmallScreen),

              // Order Details Section
              _buildOrderDetailsSection(isSmallScreen),

              // Action Buttons
              _buildActionButtons(isSmallScreen),

              // Order Timeline
              _buildOrderTimeline(isSmallScreen),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQrCodeSection(bool isSmallScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 20 : 30),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // QR Code with border
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: QrImageView(
              data: widget.transaction.id,
              version: QrVersions.auto,
              size: isSmallScreen ? 130 : 150,
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(10),
            ),
          ),
          const SizedBox(height: 20),

          // Order Type
          Text(
            widget.transaction.title,
            style: TextStyle(
              fontSize: isSmallScreen ? 20 : 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF333333),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Order ID
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF4ECDC4).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Mã đơn: ${widget.transaction.id}',
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 14,
                color: const Color(0xFF4ECDC4),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsSection(bool isSmallScreen) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Chi tiết đơn hàng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _getStatusColor(widget.transaction.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getStatusColor(widget.transaction.status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.transaction.status,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 11 : 12,
                        fontWeight: FontWeight.w500,
                        color: _getStatusColor(widget.transaction.status),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildOrderDetailItem(
            icon: Icons.scale_outlined,
            label: 'Cân nặng',
            value: '${(widget.transaction.amount / 10000).toStringAsFixed(1)}kg',
            isSmallScreen: isSmallScreen,
          ),
          _buildOrderDetailItem(
            icon: Icons.calendar_today_outlined,
            label: 'Ngày đặt hàng',
            value: widget.transaction.date,
            isSmallScreen: isSmallScreen,
          ),
          _buildOrderDetailItem(
            icon: Icons.calendar_today_outlined,
            label: 'Ngày dự kiến giao',
            value: _getEstimatedDeliveryDate(widget.transaction.date),
            isSmallScreen: isSmallScreen,
          ),
          _buildOrderDetailItem(
            icon: Icons.monetization_on_outlined,
            label: 'Tổng tiền',
            value: '${widget.transaction.amount.toInt()}đ',
            isHighlighted: true,
            isSmallScreen: isSmallScreen,
          ),
          _buildOrderDetailItem(
            icon: Icons.payment_outlined,
            label: 'Phương thức thanh toán',
            value: 'Tiền mặt khi nhận hàng',
            isSmallScreen: isSmallScreen,
          ),
          _buildOrderDetailItem(
            icon: Icons.location_on_outlined,
            label: 'Địa chỉ giao hàng',
            value: 'Số 123, Đường Lê Lợi, Quận Hoàn Kiếm, Hà Nội',
            isSmallScreen: isSmallScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailItem({
    required IconData icon,
    required String label,
    required String value,
    bool isHighlighted = false,
    required bool isSmallScreen,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF4ECDC4).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: isSmallScreen ? 16 : 18,
              color: const Color(0xFF4ECDC4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 13 : 14,
                    fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
                    color: isHighlighted ? const Color(0xFF4ECDC4) : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isSmallScreen) {
    final bool canRate = widget.transaction.status == 'Thành công';
    final double buttonHeight = 50;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: buttonHeight,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4ECDC4), Color(0xFF2AB7B0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4ECDC4).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    _showContactOptions(context);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.message_outlined,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Flexible(
                          child: Text(
                            'Liên hệ cửa hàng',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: buttonHeight,
              decoration: BoxDecoration(
                gradient: canRate
                    ? const LinearGradient(
                  colors: [Colors.orange, Color(0xFFFF8C00)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                    : LinearGradient(
                  colors: [Colors.grey.shade400, Colors.grey.shade300],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: canRate
                    ? [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: canRate ? () => _showRatingDialog(context) : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.star,
                            color: canRate ? Colors.white : Colors.grey.shade500,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Đánh giá chất lượng',
                            style: TextStyle(
                              color: canRate ? Colors.white : Colors.grey.shade500,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTimeline(bool isSmallScreen) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tiến trình đơn hàng',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 16),
          _buildTimelineItem(
            title: 'Đã nhận đơn',
            time: _getTimeFromDate(widget.transaction.date),
            isCompleted: _currentStep >= 0,
            isActive: _currentStep == 0,
            isFirst: true,
            isSmallScreen: isSmallScreen,
          ),
          _buildTimelineItem(
            title: 'Đang giặt',
            time: _currentStep >= 1 ? _getTimeFromDate(widget.transaction.date, hoursToAdd: 2) : 'Dự kiến: ${_getTimeFromDate(widget.transaction.date, hoursToAdd: 2)}',
            isCompleted: _currentStep >= 1,
            isActive: _currentStep == 1,
            isSmallScreen: isSmallScreen,
          ),
          _buildTimelineItem(
            title: 'Đang phơi/sấy',
            time: _currentStep >= 2 ? _getTimeFromDate(widget.transaction.date, hoursToAdd: 6) : 'Dự kiến: ${_getTimeFromDate(widget.transaction.date, hoursToAdd: 6)}',
            isCompleted: _currentStep >= 2,
            isActive: _currentStep == 2,
            isSmallScreen: isSmallScreen,
          ),
          _buildTimelineItem(
            title: 'Đang giao hàng',
            time: _currentStep >= 3 ? _getTimeFromDate(widget.transaction.date, daysToAdd: 1) : 'Dự kiến: ${_getTimeFromDate(widget.transaction.date, daysToAdd: 1)}',
            isCompleted: _currentStep >= 3,
            isActive: _currentStep == 3,
            isSmallScreen: isSmallScreen,
          ),
          _buildTimelineItem(
            title: 'Đã giao hàng',
            time: _currentStep >= 4 ? _getTimeFromDate(widget.transaction.date, daysToAdd: 1, hoursToAdd: 2) : 'Dự kiến: ${_getTimeFromDate(widget.transaction.date, daysToAdd: 1, hoursToAdd: 2)}',
            isCompleted: _currentStep >= 4,
            isActive: _currentStep == 4,
            isLast: true,
            isSmallScreen: isSmallScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String time,
    required bool isCompleted,
    bool isActive = false,
    bool isFirst = false,
    bool isLast = false,
    required bool isSmallScreen,
  }) {
    final Color activeColor = const Color(0xFF4ECDC4);
    final Color inactiveColor = Colors.grey.shade300;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20,
          child: Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: isCompleted ? activeColor : inactiveColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive ? activeColor : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: isCompleted
                    ? const Icon(
                  Icons.check,
                  size: 10,
                  color: Colors.white,
                )
                    : null,
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 40,
                  color: isCompleted ? activeColor : inactiveColor,
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: isSmallScreen ? 13 : 14,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? activeColor : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(
                  fontSize: isSmallScreen ? 11 : 12,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: isLast ? 0 : 20),
            ],
          ),
        ),
      ],
    );
  }

  void _showRatingDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Text(
                      'Đánh giá chất lượng dịch vụ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hãy cho chúng tôi biết trải nghiệm của bạn',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _rating = index + 1;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(
                              index < _rating ? Icons.star : Icons.star_border,
                              color: Colors.orange,
                              size: 36,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _getRatingText(_rating),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Nhập đánh giá của bạn (tùy chọn)',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF4ECDC4)),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _rating > 0
                            ? () {
                          Navigator.pop(context);
                          _showRatingSuccessDialog(context);
                          setState(() {
                            _hasRated = true;
                          });
                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Gửi đánh giá',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Hủy',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    // Add extra padding for bottom insets
                    SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showRatingSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green.shade600,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Cảm ơn bạn đã đánh giá!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Đánh giá của bạn giúp chúng tôi cải thiện dịch vụ tốt hơn.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4ECDC4),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Đóng',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContactOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  'Liên hệ cửa hàng',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                _buildContactOption(
                  icon: Icons.chat_bubble_outline,
                  title: 'Nhắn tin',
                  subtitle: 'Gửi tin nhắn đến cửa hàng',
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to chat screen
                  },
                ),
                const Divider(height: 1),
                _buildContactOption(
                  icon: Icons.phone_outlined,
                  title: 'Gọi điện',
                  subtitle: '0123 456 789',
                  onTap: () {
                    Navigator.pop(context);
                    // Make a phone call
                  },
                ),
                const Divider(height: 1),
                _buildContactOption(
                  icon: Icons.email_outlined,
                  title: 'Email',
                  subtitle: 'support@example.com',
                  onTap: () {
                    Navigator.pop(context);
                    // Send an email
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF4ECDC4).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: const Color(0xFF4ECDC4),
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 14,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  'Tùy chọn',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                _buildOptionItem(
                  icon: Icons.content_copy_outlined,
                  title: 'Sao chép mã đơn hàng',
                  onTap: () {
                    Navigator.pop(context);
                    // Copy order ID to clipboard
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã sao chép mã đơn hàng'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                _buildOptionItem(
                  icon: Icons.share_outlined,
                  title: 'Chia sẻ đơn hàng',
                  onTap: () {
                    Navigator.pop(context);
                    // Share order details
                  },
                ),
                const Divider(height: 1),
                _buildOptionItem(
                  icon: Icons.report_problem_outlined,
                  title: 'Báo cáo vấn đề',
                  onTap: () {
                    Navigator.pop(context);
                    // Report issue
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: const Color(0xFF4ECDC4),
        size: 24,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
      onTap: onTap,
    );
  }

  String _getTimeFromDate(String dateStr, {int daysToAdd = 0, int hoursToAdd = 0}) {
    // Parse the date string (format: DD/MM/YYYY HH:MM)
    final parts = dateStr.split(' ');
    final dateParts = parts[0].split('/');
    final timeParts = parts[1].split(':');

    final day = int.parse(dateParts[0]);
    final month = int.parse(dateParts[1]);
    final year = int.parse(dateParts[2]);
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    final date = DateTime(year, month, day, hour, minute);
    final newDate = date.add(Duration(days: daysToAdd, hours: hoursToAdd));

    return '${newDate.day}/${newDate.month}/${newDate.year} - ${newDate.hour.toString().padLeft(2, '0')}:${newDate.minute.toString().padLeft(2, '0')}';
  }

  String _getEstimatedDeliveryDate(String dateStr) {
    // Parse the date string (format: DD/MM/YYYY HH:MM)
    final parts = dateStr.split(' ');
    final dateParts = parts[0].split('/');

    final day = int.parse(dateParts[0]);
    final month = int.parse(dateParts[1]);
    final year = int.parse(dateParts[2]);

    final date = DateTime(year, month, day);
    final deliveryDate = date.add(const Duration(days: 2));

    return '${deliveryDate.day}/${deliveryDate.month}/${deliveryDate.year}';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Thành công':
        return Colors.green;
      case 'Đang giặt':
      case 'Đang phơi/sấy':
      case 'Đang giao hàng':
        return Colors.orange;
      case 'Đã hủy':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getRatingText(double rating) {
    if (rating == 0) return 'Chưa đánh giá';
    if (rating == 1) return 'Rất tệ';
    if (rating == 2) return 'Tệ';
    if (rating == 3) return 'Bình thường';
    if (rating == 4) return 'Tốt';
    return 'Rất tốt';
  }
}

