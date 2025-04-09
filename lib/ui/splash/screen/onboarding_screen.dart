import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../login/screen/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLastPage = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Onboarding data
  final List<Map<String, dynamic>> _onboardingData = [
    {
      'title': 'Dịch vụ giặt là chuyên nghiệp',
      'description': 'Chúng tôi cung cấp dịch vụ giặt là chuyên nghiệp với chất lượng cao và giá cả hợp lý.',
      'icon': Icons.local_laundry_service,
      'color': const Color(0xFF4ECDC4),
      'secondaryColor': const Color(0xFF2AB7B0),
    },
    {
      'title': 'Đặt lịch dễ dàng',
      'description': 'Đặt lịch giặt là chỉ với vài thao tác đơn giản trên ứng dụng, tiết kiệm thời gian của bạn.',
      'icon': Icons.calendar_today,
      'color': const Color(0xFF5D78FF),
      'secondaryColor': const Color(0xFF3955D9),
    },
    {
      'title': 'Theo dõi đơn hàng',
      'description': 'Theo dõi trạng thái đơn hàng của bạn theo thời gian thực, biết chính xác khi nào đồ giặt sẽ được giao.',
      'icon': Icons.local_shipping,
      'color': const Color(0xFFFF6B6B),
      'secondaryColor': const Color(0xFFE83E3E),
    },
  ];

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();

    // Add listener to page controller
    _pageController.addListener(() {
      if (_pageController.page!.round() != _currentPage) {
        setState(() {
          _currentPage = _pageController.page!.round();
          _isLastPage = _currentPage == _onboardingData.length - 1;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (_isLastPage) {
      _navigateToLogin();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive design
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                    child: TextButton(
                      onPressed: _navigateToLogin,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 12 : 16,
                            vertical: isSmallScreen ? 6 : 8
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'Bỏ qua',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),

                // Page view
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _onboardingData.length,
                    itemBuilder: (context, index) {
                      return _buildOnboardingPage(
                        title: _onboardingData[index]['title'],
                        description: _onboardingData[index]['description'],
                        icon: _onboardingData[index]['icon'],
                        color: _onboardingData[index]['color'],
                        secondaryColor: _onboardingData[index]['secondaryColor'],
                        isSmallScreen: isSmallScreen,
                        screenSize: screenSize,
                        index: index,
                      );
                    },
                  ),
                ),

                // Page indicator and buttons
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                  child: Column(
                    children: [
                      // Page indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _onboardingData.length,
                              (index) => _buildPageIndicator(index),
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.03),

                      // Next/Start button
                      SizedBox(
                        width: double.infinity,
                        height: isSmallScreen ? 48 : 56,
                        child: ElevatedButton(
                          onPressed: _onNextPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _onboardingData[_currentPage]['color'],
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _isLastPage ? 'Bắt đầu ngay' : 'Tiếp theo',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 14 : 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                _isLastPage ? Icons.login : Icons.arrow_forward,
                                size: isSmallScreen ? 16 : 18,
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (!_isLastPage) ...[
                        SizedBox(height: isSmallScreen ? 12 : 16),
                        TextButton(
                          onPressed: _navigateToLogin,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey.shade700,
                          ),
                          child: Text(
                            'Đã có tài khoản? Đăng nhập',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
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
    );
  }

  Widget _buildOnboardingPage({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required Color secondaryColor,
    required bool isSmallScreen,
    required Size screenSize,
    required int index,
  }) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double value = 1.0;
        if (_pageController.position.haveDimensions) {
          value = _pageController.page! - index;
          value = (1 - (value.abs() * 0.5)).clamp(0.0, 1.0);
        }

        return Transform.scale(
          scale: Curves.easeOut.transform(value),
          child: child,
        );
      },
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16.0 : 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Thêm padding phía trên để đẩy nội dung lên cao
              SizedBox(height: screenSize.height * 0.08),

              // Illustration
              _buildIllustration(icon, color, secondaryColor, screenSize),
              SizedBox(height: screenSize.height * 0.05),

              // App logo or name
              Text(
                'Quản lý giặt',
                style: TextStyle(
                  fontSize: isSmallScreen ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              SizedBox(height: screenSize.height * 0.03),

              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: isSmallScreen ? 18 : 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF333333),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenSize.height * 0.02),

              // Description
              Text(
                description,
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              // Thêm khoảng trống lớn ở dưới để tạo khoảng cách với nút
              SizedBox(height: screenSize.height * 0.1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIllustration(IconData icon, Color color, Color secondaryColor, Size screenSize) {
    final size = screenSize.width * 0.5;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background decorative elements
          ...List.generate(5, (index) {
            final angle = index * (math.pi * 2 / 5);
            final radius = size * 0.35;
            return Positioned(
              left: size / 2 + radius * math.cos(angle) - 15,
              top: size / 2 + radius * math.sin(angle) - 15,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: secondaryColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),

          // Main icon container
          Container(
            width: size * 0.5,
            height: size * 0.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, secondaryColor],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: size * 0.25,
            ),
          ),

          // Animated rotating ring
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 2 * math.pi),
            duration: const Duration(seconds: 10),
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value,
                child: child,
              );
            },
            child: Container(
              width: size * 0.7,
              height: size * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withOpacity(0.3),
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignOutside,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    bool isCurrentPage = index == _currentPage;
    Color color = _onboardingData[_currentPage]['color'];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isCurrentPage ? 24 : 8,
      decoration: BoxDecoration(
        color: isCurrentPage ? color : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
        boxShadow: isCurrentPage ? [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
    );
  }
}

