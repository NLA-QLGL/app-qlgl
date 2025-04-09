import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../models/promotion.dart';
import '../../../service/promotion_service.dart';

class PromotionScreen extends StatefulWidget {
  const PromotionScreen({super.key});

  @override
  State<PromotionScreen> createState() => _PromotionScreenState();
}

class _PromotionScreenState extends State<PromotionScreen> with SingleTickerProviderStateMixin {
  final PromotionService _promotionService = PromotionService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'Tất cả';
  final List<String> _filterOptions = ['Tất cả', 'Đang hoạt động', 'Đã sử dụng', 'Đã hết hạn'];

  List<Promotion> _filteredPromotions = [];
  List<Promotion> _featuredPromotions = [];
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _promoCodeController = TextEditingController();

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
    _loadPromotions();

    // Thêm listener cho search controller
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadPromotions() async {
    setState(() {
      _isLoading = true;
    });

    await _promotionService.initialize();
    _filterPromotions();

    // Lấy danh sách khuyến mãi nổi bật
    _featuredPromotions = _promotionService.getFeaturedPromotions();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      _animationController.forward();
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filterPromotions();
    });
  }

  void _filterPromotions() {
    // Đầu tiên tìm kiếm theo query
    List<Promotion> searchResults = _promotionService.searchPromotions(_searchQuery);

    // Sau đó lọc theo trạng thái
    if (_selectedFilter != 'Tất cả') {
      if (_selectedFilter == 'Đang hoạt động') {
        searchResults = searchResults.where((p) => p.status == PromotionStatus.active && p.isValid).toList();
      } else if (_selectedFilter == 'Đã sử dụng') {
        searchResults = searchResults.where((p) => p.status == PromotionStatus.used).toList();
      } else if (_selectedFilter == 'Đã hết hạn') {
        searchResults = searchResults.where((p) =>
        p.status == PromotionStatus.expired ||
            (p.status == PromotionStatus.active && !p.isValid)
        ).toList();
      }
    }

    setState(() {
      _filteredPromotions = searchResults;
    });
  }

  void _showPromoCodeDialog() {
    // Sử dụng controller để theo dõi giá trị nhập vào
    _promoCodeController.clear();
    bool _isVerifying = false;
    String? _errorMessage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Title
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4ECDC4).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.confirmation_number_outlined,
                            color: Color(0xFF4ECDC4),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Nhập mã khuyến mãi',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Description
                    Text(
                      'Nhập mã khuyến mãi của bạn để được giảm giá cho đơn hàng tiếp theo',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Input field
                    TextField(
                      controller: _promoCodeController,
                      decoration: InputDecoration(
                        hintText: 'Nhập mã khuyến mãi',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        prefixIcon: const Icon(Icons.local_offer_outlined, color: Color(0xFF4ECDC4)),
                        suffixIcon: _promoCodeController.text.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            setState(() {
                              _promoCodeController.clear();
                              _errorMessage = null;
                            });
                          },
                        )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF4ECDC4), width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.red.shade300),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.red.shade300, width: 2),
                        ),
                        errorText: _errorMessage,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                      ),
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                        LengthLimitingTextInputFormatter(15),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _errorMessage = null;
                        });
                      },
                      autofocus: true,
                    ),
                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey.shade700,
                              side: BorderSide(color: Colors.grey.shade300),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Hủy',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isVerifying
                                ? null
                                : () {
                              final code = _promoCodeController.text.trim();
                              if (code.isEmpty) {
                                setState(() {
                                  _errorMessage = 'Vui lòng nhập mã khuyến mãi';
                                });
                                return;
                              }

                              setState(() {
                                _isVerifying = true;
                              });

                              // Giả lập việc kiểm tra mã
                              Future.delayed(const Duration(milliseconds: 800), () {
                                final promotion = _promotionService.getPromotionByCode(code);

                                if (promotion != null && promotion.isValid) {
                                  Navigator.of(context).pop();
                                  _showPromotionDetails(promotion);
                                } else {
                                  setState(() {
                                    _isVerifying = false;
                                    _errorMessage = promotion == null
                                        ? 'Mã khuyến mãi không tồn tại'
                                        : 'Mã khuyến mãi đã hết hạn hoặc không hợp lệ';
                                  });
                                }
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4ECDC4),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey.shade300,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isVerifying
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : const Text(
                              'Áp dụng',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Tip
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Chuyển đến màn hình khuyến mãi đang hoạt động
                          setState(() {
                            _selectedFilter = 'Đang hoạt động';
                            _filterPromotions();
                          });
                        },
                        icon: const Icon(Icons.lightbulb_outline, size: 16),
                        label: const Text('Xem các mã khuyến mãi đang hoạt động'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF4ECDC4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _verifyPromoCode(String code) {
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập mã khuyến mãi'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final promotion = _promotionService.getPromotionByCode(code);

    if (promotion != null && promotion.isValid) {
      _showPromotionDetails(promotion);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            promotion == null
                ? 'Mã khuyến mãi không tồn tại'
                : 'Mã khuyến mãi đã hết hạn hoặc không hợp lệ',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
        ),
      );
    }
  }

  void _showPromotionDetails(Promotion promotion) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _buildPromotionDetailsSheet(promotion);
      },
    );
  }

  Widget _buildPromotionDetailsSheet(Promotion promotion) {
    // Lấy kích thước màn hình để responsive
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;

    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Promotion header
          Row(
            children: [
              _buildPromotionTypeIcon(promotion.type, size: 50),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      promotion.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4ECDC4).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        promotion.code,
                        style: const TextStyle(
                          color: Color(0xFF4ECDC4),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Promotion details
          _buildDetailItem(
            icon: Icons.info_outline,
            title: 'Mô tả',
            content: promotion.description,
          ),
          const SizedBox(height: 16),

          _buildDetailItem(
            icon: Icons.monetization_on_outlined,
            title: 'Giá trị',
            content: _formatPromotionValue(promotion),
          ),
          const SizedBox(height: 16),

          _buildDetailItem(
            icon: Icons.shopping_bag_outlined,
            title: 'Đơn hàng tối thiểu',
            content: '${promotion.minOrderValue.toInt()}đ',
          ),
          const SizedBox(height: 16),

          _buildDetailItem(
            icon: Icons.date_range_outlined,
            title: 'Thời hạn',
            content: '${_formatDate(promotion.startDate)} - ${_formatDate(promotion.endDate)}',
          ),
          const SizedBox(height: 24),

          // Action button
          SizedBox(
            width: double.infinity,
            height: isSmallScreen ? 48 : 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _usePromotion(promotion);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4ECDC4),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Sử dụng ngay',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Copy code button
          SizedBox(
            width: double.infinity,
            height: isSmallScreen ? 48 : 56,
            child: OutlinedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: promotion.code));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã sao chép mã khuyến mãi'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.copy),
              label: const Text('Sao chép mã'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF4ECDC4),
                side: const BorderSide(color: Color(0xFF4ECDC4)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF4ECDC4).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF4ECDC4),
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _usePromotion(Promotion promotion) {
    // Trong ứng dụng thực tế, bạn sẽ áp dụng mã này vào đơn hàng
    // Ở đây chúng ta chỉ hiển thị thông báo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã áp dụng mã khuyến mãi ${promotion.code}'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );

    // Cập nhật trạng thái khuyến mãi
    _promotionService.usePromotion(promotion.id).then((_) {
      // Cập nhật lại danh sách
      _filterPromotions();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _promoCodeController.dispose();
    super.dispose();
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
          'Khuyến mãi',
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
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _loadPromotions,
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : RefreshIndicator(
        color: const Color(0xFF4ECDC4),
        onRefresh: _loadPromotions,
        child: CustomScrollView(
          slivers: [
            // Promo code entry button
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: const Color(0xFFF0FFFD),
                child: OutlinedButton.icon(
                  onPressed: () {
                    _promoCodeController.clear();
                    _showPromoCodeDialog();
                  },
                  icon: const Icon(Icons.confirmation_number_outlined),
                  label: const Text('Nhập mã khuyến mãi'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4ECDC4),
                    side: const BorderSide(color: Color(0xFF4ECDC4)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),

            // Search bar
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm khuyến mãi...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF4ECDC4)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Filter chips
            SliverToBoxAdapter(
              child: Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: Colors.white,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filterOptions.length,
                  itemBuilder: (context, index) {
                    final filter = _filterOptions[index];
                    final isSelected = _selectedFilter == filter;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedFilter = filter;
                          _filterPromotions();
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF4ECDC4)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF4ECDC4)
                                : Colors.grey.shade300,
                          ),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: const Color(0xFF4ECDC4).withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ] : null,
                        ),
                        child: Text(
                          filter,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey.shade700,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Featured promotions section (only show if there are featured promotions and filter is "All")
            if (_featuredPromotions.isNotEmpty && _selectedFilter == 'Tất cả' && _searchQuery.isEmpty)
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Color(0xFFFFA726),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Khuyến mãi nổi bật',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 16 : 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 170, // Tăng chiều cao từ 180 lên 190
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: _featuredPromotions.length,
                        itemBuilder: (context, index) {
                          return _buildFeaturedPromotionCard(_featuredPromotions[index], isSmallScreen);
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),

            // All promotions section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_offer,
                      color: Color(0xFF4ECDC4),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _selectedFilter == 'Tất cả' ? 'Tất cả khuyến mãi' : _selectedFilter,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (_searchQuery.isNotEmpty || _selectedFilter != 'Tất cả')
                      TextButton.icon(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _selectedFilter = 'Tất cả';
                            _filterPromotions();
                          });
                        },
                        icon: const Icon(Icons.clear, size: 16),
                        label: const Text('Xóa bộ lọc'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Promotions list or empty state
            _filteredPromotions.isEmpty
                ? SliverFillRemaining(
              child: _buildEmptyState(),
            )
                : SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final promotion = _filteredPromotions[index];
                    return _buildPromotionCard(promotion, isSmallScreen);
                  },
                  childCount: _filteredPromotions.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4ECDC4)),
          ),
          const SizedBox(height: 16),
          Text(
            'Đang tải khuyến mãi...',
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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_offer_outlined,
                size: 60,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy khuyến mãi nào',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Thử thay đổi bộ lọc hoặc tìm kiếm khác',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _selectedFilter = 'Tất cả';
                  _filterPromotions();
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Xóa bộ lọc'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4ECDC4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sửa phương thức _buildFeaturedPromotionCard để tránh tràn bố cục
  Widget _buildFeaturedPromotionCard(Promotion promotion, bool isSmallScreen) {
    final bool isValid = promotion.isValid;

    return Container(
      width: 280,
      height: 160, // Thêm chiều cao cố định để tránh tràn
      margin: const EdgeInsets.only(right: 12, bottom: 8, top: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF0FFFD),
            Colors.white,
          ],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isValid ? () => _showPromotionDetails(promotion) : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12), // Giảm padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Đảm bảo column chỉ chiếm không gian cần thiết
              children: [
                Row(
                  children: [
                    _buildPromotionTypeIcon(promotion.type, size: 36), // Giảm kích thước icon
                    const SizedBox(width: 8), // Giảm khoảng cách
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            promotion.title,
                            style: const TextStyle(
                              fontSize: 14, // Giảm kích thước font
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2), // Giảm khoảng cách
                          Text(
                            _formatPromotionValue(promotion),
                            style: const TextStyle(
                              fontSize: 12, // Giảm kích thước font
                              color: Color(0xFF4ECDC4),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8), // Giảm khoảng cách
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4ECDC4).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: const Color(0xFF4ECDC4).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    promotion.code,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13, // Giảm kích thước font
                      color: Color(0xFF4ECDC4),
                    ),
                  ),
                ),
                const Spacer(), // Thêm spacer để đẩy phần dưới xuống cuối
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'HSD: ${_formatDate(promotion.endDate)}',
                      style: TextStyle(
                        fontSize: 11, // Giảm kích thước font
                        color: Colors.grey.shade600,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _showPromotionDetails(promotion),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4ECDC4),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), // Giảm padding
                        minimumSize: const Size(60, 28), // Giảm kích thước tối thiểu
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Sử dụng',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11, // Giảm kích thước font
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPromotionCard(Promotion promotion, bool isSmallScreen) {
    final bool isValid = promotion.isValid;
    final bool isExpired = !isValid || promotion.status == PromotionStatus.expired;
    final bool isUsed = promotion.status == PromotionStatus.used;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isValid ? () => _showPromotionDetails(promotion) : null,
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isExpired || isUsed
                        ? Colors.grey.shade100
                        : const Color(0xFFF0FFFD),
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      _buildPromotionTypeIcon(promotion.type),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              promotion.title,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 14 : 16,
                                fontWeight: FontWeight.bold,
                                color: isExpired || isUsed
                                    ? Colors.grey.shade600
                                    : Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatPromotionValue(promotion),
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 13,
                                color: isExpired || isUsed
                                    ? Colors.grey.shade500
                                    : const Color(0xFF4ECDC4),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (promotion.isNew && isValid)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Mới',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Promotion code
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mã khuyến mãi:',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isExpired || isUsed
                                    ? Colors.grey.shade100
                                    : const Color(0xFF4ECDC4).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: isExpired || isUsed
                                      ? Colors.grey.shade300
                                      : const Color(0xFF4ECDC4).withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                promotion.code,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isSmallScreen ? 13 : 14,
                                  color: isExpired || isUsed
                                      ? Colors.grey.shade500
                                      : const Color(0xFF4ECDC4),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Hạn sử dụng: ${_formatDate(promotion.endDate)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isExpired
                                    ? Colors.red.shade400
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Action button
                      Column(
                        children: [
                          if (isExpired)
                            _buildStatusBadge(
                              'Đã hết hạn',
                              Colors.red.shade400,
                            )
                          else if (isUsed)
                            _buildStatusBadge(
                              'Đã sử dụng',
                              Colors.grey.shade600,
                            )
                          else
                            ElevatedButton(
                              onPressed: () => _showPromotionDetails(promotion),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4ECDC4),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Sử dụng',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          const SizedBox(height: 8),
                          if (!isExpired && !isUsed)
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: promotion.code));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Đã sao chép mã khuyến mãi'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              child: Text(
                                'Sao chép mã',
                                style: TextStyle(
                                  color: const Color(0xFF4ECDC4),
                                  fontSize: 12,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                        ],
                      ),
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

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildPromotionTypeIcon(PromotionType type, {double size = 40}) {
    IconData icon;
    Color color;

    switch (type) {
      case PromotionType.percentage:
        icon = Icons.percent;
        color = const Color(0xFF4ECDC4);
        break;
      case PromotionType.fixedAmount:
        icon = Icons.money_off;
        color = Colors.orange;
        break;
      case PromotionType.freeService:
        icon = Icons.card_giftcard;
        color = Colors.purple;
        break;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color,
        size: size * 0.5,
      ),
    );
  }

  String _formatPromotionValue(Promotion promotion) {
    switch (promotion.type) {
      case PromotionType.percentage:
        return 'Giảm ${promotion.value.toInt()}%';
      case PromotionType.fixedAmount:
        return 'Giảm ${promotion.value.toInt()}đ';
      case PromotionType.freeService:
        return 'Miễn phí dịch vụ';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

