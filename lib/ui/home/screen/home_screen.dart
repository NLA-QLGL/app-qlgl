import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';

import '../../../helper/convert_price.dart';
import '../../../models/transaction.dart';
import '../../../service/notification_service.dart';
import '../../chat/screen/chat_screen.dart';
import '../../notification/screen/notification_screen.dart';
import '../../order/screen/order_tracking_screen.dart';
import '../../profile/screen/profile_screen.dart';
import '../../promotion/screen/promotion_screen.dart';
import '../../transaction/history/screen/transaction_history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _currentDate = '';

  // Sample transactions for the home screen
  late List<Transaction> _homeTransactions;

  final List<Map<String, dynamic>> _banners = [
    {
      'title': 'Giảm 30% cho lần đầu sử dụng',
      'subtitle': 'Áp dụng cho tất cả các dịch vụ giặt',
      'color': const Color(0xFF4ECDC4),
      'gradientColors': [const Color(0xFF4ECDC4), const Color(0xFF2AB7B0)],
      'icon': Icons.local_offer,
    },
    {
      'title': 'Dịch vụ giặt giày mới',
      'subtitle': 'Giặt sạch, khử mùi, bảo vệ màu sắc',
      'color': const Color(0xFF5D78FF),
      'gradientColors': [const Color(0xFF5D78FF), const Color(0xFF3955D9)],
      'icon': Icons.cleaning_services,
    },
    {
      'title': 'Giao hàng miễn phí',
      'subtitle': 'Cho đơn hàng trên 200.000đ',
      'color': const Color(0xFFFF6B6B),
      'gradientColors': [const Color(0xFFFF6B6B), const Color(0xFFE83E3E)],
      'icon': Icons.delivery_dining,
    },
  ];

  final List<Map<String, dynamic>> _utilities = [
    {
      'title': 'Giặt đồ',
      'icon': Icons.local_laundry_service,
      'color': const Color(0xFF4ECDC4),
    },
    {
      'title': 'Tìm cửa hàng',
      'icon': Icons.search,
      'color': const Color(0xFF5D78FF),
    },
    {
      'title': 'Kiểm tra đơn hàng',
      'icon': Icons.filter_list,
      'color': const Color(0xFFFF6B6B),
    },
    {
      'title': 'Khuyến mãi',
      'icon': Icons.local_offer,
      'color': const Color(0xFFFFA726),
    },
  ];

  final _notificationService = NotificationService();
  int _unreadNotificationCount = 0;

  @override
  void initState() {
    super.initState();
    _startBannerTimer();
    _updateCurrentDate();

    // Get the first 3 transactions from the sample data
    final allTransactions = Transaction.getSampleTransactions();
    _homeTransactions = allTransactions.take(3).toList();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();

    // Initialize notifications
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
    if (mounted) {
      setState(() {
        _unreadNotificationCount = _notificationService.unreadCount;
      });
    }
  }

  void _updateCurrentDate() {
    final now = DateTime.now();
    _currentDate = DateFormat('EEEE, d MMMM yyyy').format(now);
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentBannerIndex < _banners.length - 1) {
        _currentBannerIndex++;
      } else {
        _currentBannerIndex = 0;
      }

      if (_bannerController.hasClients) {
        _bannerController.animateToPage(
          _currentBannerIndex,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onBannerChanged(int index) {
    setState(() {
      _currentBannerIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive design
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildHeader(context, isSmallScreen),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(0),
                    children: [
                      _buildBannerSlider(isSmallScreen, screenSize),
                      SizedBox(height: screenSize.height * 0.02),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenSize.width * 0.04
                        ),
                        child: _buildTransactionHistory(context, isSmallScreen),
                      ),
                      SizedBox(height: screenSize.height * 0.02),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenSize.width * 0.04
                        ),
                        child: _buildUtilities(context, isSmallScreen),
                      ),
                      SizedBox(height: screenSize.height * 0.02),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBannerSlider(bool isSmallScreen, Size screenSize) {
    final double bannerHeight = isSmallScreen ? 170 : 190;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: bannerHeight,
          child: PageView.builder(
            controller: _bannerController,
            onPageChanged: _onBannerChanged,
            itemCount: _banners.length,
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return Container(
                margin: EdgeInsets.symmetric(
                    horizontal: screenSize.width * 0.04,
                    vertical: 10
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: banner['gradientColors'],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: banner['color'].withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: Icon(
                        banner['icon'],
                        size: isSmallScreen ? 120 : 150,
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    // Decorative circles
                    Positioned(
                      left: -30,
                      top: -30,
                      child: Container(
                        width: isSmallScreen ? 80 : 100,
                        height: isSmallScreen ? 80 : 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      right: -20,
                      top: 20,
                      child: Container(
                        width: isSmallScreen ? 50 : 60,
                        height: isSmallScreen ? 50 : 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            banner['title'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isSmallScreen ? 18 : 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            banner['subtitle'],
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: isSmallScreen ? 12 : 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: isSmallScreen ? 12 : 16),
                          Container(
                            height: isSmallScreen ? 32 : 36,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                // Handle banner action
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: banner['color'],
                                elevation: 0,
                                padding: EdgeInsets.symmetric(
                                    horizontal: isSmallScreen ? 12 : 16,
                                    vertical: 0
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Xem chi tiết',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isSmallScreen ? 12 : 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _banners.length,
                  (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _currentBannerIndex == index ? 18 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: _currentBannerIndex == index
                      ? const Color(0xFF4ECDC4)
                      : Colors.grey.shade300,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, bool isSmallScreen) {
    final double avatarSize = isSmallScreen ? 50 : 60;
    final double iconSize = isSmallScreen ? 36 : 40;
    final double iconPadding = isSmallScreen ? 8 : 10;

    // Sử dụng MediaQuery để lấy kích thước màn hình và padding an toàn
    final mediaQuery = MediaQuery.of(context);
    final statusBarHeight = mediaQuery.padding.top;

    return Material(
      elevation: 0,
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        // Sử dụng padding thay vì chiều cao cố định
        padding: EdgeInsets.only(
          top: statusBarHeight + 10,
          bottom: 15,
          left: 20,
          right: 20,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4ECDC4), Color(0xFF2AB7B0)],
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x404ECDC4),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row for action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildHeaderIconButton(
                    icon: Icons.chat_bubble_outline,
                    size: iconSize,
                    padding: iconPadding,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ChatScreen(),
                        ),
                      );
                    },
                  ),
                  Stack(
                    children: [
                      _buildHeaderIconButton(
                        icon: Icons.notifications_none,
                        size: iconSize,
                        padding: iconPadding,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const NotificationScreen(),
                            ),
                          ).then((_) {
                            // Refresh unread count when returning from notification screen
                            setState(() {
                              _unreadNotificationCount = _notificationService.unreadCount;
                            });
                          });
                        },
                      ),
                      if (_unreadNotificationCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              _unreadNotificationCount > 9 ? '9+' : _unreadNotificationCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  _buildHeaderIconButton(
                    icon: Icons.person_outline,
                    size: iconSize,
                    padding: iconPadding,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Row for user info
              Row(
                children: [
                  Container(
                    width: avatarSize,
                    height: avatarSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      image: const DecorationImage(
                        image: AssetImage('assets/images/default_profile.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Chào, Anh',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 18 : 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currentDate,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: isSmallScreen ? 11 : 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    required double size,
    required double padding,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: size * 0.5),
        onPressed: onPressed,
        padding: EdgeInsets.all(padding),
        constraints: BoxConstraints(
          minWidth: size,
          minHeight: size,
        ),
      ),
    );
  }

  Widget _buildTransactionHistory(BuildContext context, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Lịch sử giao dịch',
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const TransactionHistoryScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('Xem tất cả'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF4ECDC4),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: List.generate(_homeTransactions.length, (index) {
              final transaction = _homeTransactions[index];
              return Column(
                children: [
                  SizedBox(
                    height: 80, // Increased height to prevent overflow
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          // Navigate to order tracking screen with transaction data
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => OrderTrackingScreen(transaction: transaction),
                            ),
                          );
                        },
                        child: _buildTransactionItem(transaction, isSmallScreen),
                      ),
                    ),
                  ),
                  if (index < _homeTransactions.length - 1)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.grey.shade200,
                      indent: 16,
                      endIndent: 16,
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(Transaction transaction, bool isSmallScreen) {
    // Determine icon based on transaction title
    IconData icon = Icons.receipt_outlined;
    if (transaction.title.contains('quần áo')) {
      icon = Icons.checkroom;
    } else if (transaction.title.contains('chăn')) {
      icon = Icons.bed;
    } else if (transaction.title.contains('giày')) {
      icon = Icons.shopping_bag;
    }

    // Determine status color
    Color statusColor = transaction.status == 'Thành công'
        ? Colors.green
        : Colors.orange;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: isSmallScreen ? 36 : 40,
            height: isSmallScreen ? 36 : 40,
            decoration: BoxDecoration(
              color: const Color(0xFF4ECDC4).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF4ECDC4),
              size: isSmallScreen ? 18 : 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, // Thêm dòng này để giảm thiểu chiều cao
              children: [
                Text(
                  transaction.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 13 : 15, // Giảm kích thước font
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2), // Giảm khoảng cách
                Text(
                  transaction.date,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: isSmallScreen ? 10 : 11, // Giảm kích thước font
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Thêm dòng này để giảm thiểu chiều cao
            children: [
              Text(
                formatCurrency(transaction.amount.toInt()),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallScreen ? 13 : 15, // Giảm kích thước font
                ),
              ),
              const SizedBox(height: 2), // Giảm khoảng cách
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 6 : 8,
                    vertical: 1 // Giảm padding dọc
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  transaction.status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: isSmallScreen ? 10 : 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Cập nhật phương thức _buildUtilities để sử dụng Wrap thay vì Row
  Widget _buildUtilities(BuildContext context, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tiện ích',
          style: TextStyle(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 8 : 12), // Giảm padding
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          // Sử dụng Wrap thay vì Row để tự động xuống dòng khi cần
          child: Wrap(
            alignment: WrapAlignment.spaceEvenly,
            spacing: isSmallScreen ? 4 : 8, // Khoảng cách ngang giữa các item
            runSpacing: isSmallScreen ? 4 : 8, // Khoảng cách dọc giữa các hàng
            children: List.generate(_utilities.length, (index) {
              final utility = _utilities[index];
              return _buildUtilityItem(
                icon: utility['icon'],
                title: utility['title'],
                color: utility['color'],
                isSmallScreen: isSmallScreen,
                onTap: () {
                  if (index == 2) { // Check order status
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => OrderTrackingScreen(
                          transaction: _homeTransactions.isNotEmpty
                              ? _homeTransactions.first
                              : Transaction.getSampleTransactions().first,
                        ),
                      ),
                    );
                  } else if (index == 3) { // Khuyến mãi
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PromotionScreen(),
                      ),
                    );
                  }
                  // Handle other utility actions
                },
              );
            }),
          ),
        ),
      ],
    );
  }

  // Thay đổi phương thức _buildUtilityItem để giảm kích thước
  Widget _buildUtilityItem({
    required IconData icon,
    required String title,
    required Color color,
    required bool isSmallScreen,
    required VoidCallback onTap,
  }) {
    // Giảm kích thước của mỗi item
    final double itemWidth = isSmallScreen ? 60 : 70;
    final double iconSize = isSmallScreen ? 28 : 32;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: itemWidth,
        height: itemWidth, // Chiều cao bằng chiều rộng để tạo hình vuông
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: isSmallScreen ? 14 : 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isSmallScreen ? 8 : 9,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

