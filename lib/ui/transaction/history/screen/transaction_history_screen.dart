import 'package:flutter/material.dart';

import '../../../../helper/convert_price.dart';
import '../../../../models/transaction.dart';
import '../../../order/screen/order_tracking_screen.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Filter options
  String _selectedFilter = 'Tất cả';
  final List<String> _filterOptions = ['Tất cả', 'Thành công', 'Đang xử lý', 'Đã hủy'];

  // Search query
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  // Grouped transactions
  late Map<String, List<Transaction>> _filteredTransactions;
  late Map<String, List<Transaction>> _allTransactions;

  // Selected date range
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();

    // Initialize transactions
    _allTransactions = Transaction.getGroupedTransactions();
    _filteredTransactions = Map.from(_allTransactions);

    // Add listener to search controller
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _filterTransactions();
    });
  }

  void _filterTransactions() {
    if (_searchQuery.isEmpty && _selectedFilter == 'Tất cả' && _selectedDateRange == null) {
      _filteredTransactions = Map.from(_allTransactions);
      return;
    }

    // Create a new filtered map
    _filteredTransactions = {};

    _allTransactions.forEach((month, transactions) {
      // Filter transactions based on search query, status filter, and date range
      final filteredList = transactions.where((transaction) {
        // Check search query
        final matchesSearch = _searchQuery.isEmpty ||
            transaction.title.toLowerCase().contains(_searchQuery) ||
            transaction.id.toLowerCase().contains(_searchQuery);

        // Check status filter
        bool matchesFilter = true;
        if (_selectedFilter != 'Tất cả') {
          matchesFilter = transaction.status == _selectedFilter;
        }

        // Check date range
        bool matchesDateRange = true;
        if (_selectedDateRange != null) {
          // Parse the transaction date (format: DD/MM/YYYY HH:MM)
          final parts = transaction.date.split(' ');
          final dateParts = parts[0].split('/');
          final day = int.parse(dateParts[0]);
          final month = int.parse(dateParts[1]);
          final year = int.parse(dateParts[2]);

          final transactionDate = DateTime(year, month, day);
          matchesDateRange = (transactionDate.isAfter(_selectedDateRange!.start) ||
              transactionDate.isAtSameMomentAs(_selectedDateRange!.start)) &&
              (transactionDate.isBefore(_selectedDateRange!.end) ||
                  transactionDate.isAtSameMomentAs(_selectedDateRange!.end));
        }

        return matchesSearch && matchesFilter && matchesDateRange;
      }).toList();

      // Only add the month if it has filtered transactions
      if (filteredList.isNotEmpty) {
        _filteredTransactions[month] = filteredList;
      }
    });
  }

  Future<void> _selectDateRange() async {
    final initialDateRange = _selectedDateRange ??
        DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 30)),
          end: DateTime.now(),
        );

    final newDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4ECDC4),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF4ECDC4),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (newDateRange != null) {
      setState(() {
        _selectedDateRange = newDateRange;
        _filterTransactions();
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedFilter = 'Tất cả';
      _searchController.clear();
      _searchQuery = '';
      _selectedDateRange = null;
      _filteredTransactions = Map.from(_allTransactions);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive design
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: !_isSearching
            ? const Text(
          'Lịch sử giao dịch',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        )
            : TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm giao dịch...',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            border: InputBorder.none,
          ),
          style: const TextStyle(color: Colors.black87, fontSize: 16),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // IconButton(
          //   icon: Icon(
          //     _isSearching ? Icons.close : Icons.search,
          //     color: Colors.black87,
          //   ),
          //   onPressed: () {
          //     setState(() {
          //       _isSearching = !_isSearching;
          //       if (!_isSearching) {
          //         _searchController.clear();
          //       }
          //     });
          //   },
          // ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black87),
            onPressed: () {
              _showFilterBottomSheet(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Date range filter chip (if selected)
          if (_selectedDateRange != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4ECDC4).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF4ECDC4).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.date_range,
                            size: 16,
                            color: Color(0xFF4ECDC4),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month}/${_selectedDateRange!.start.year} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}/${_selectedDateRange!.end.year}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF4ECDC4),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _selectedDateRange = null;
                                _filterTransactions();
                              });
                            },
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Color(0xFF4ECDC4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_selectedFilter != 'Tất cả' || _searchQuery.isNotEmpty)
                    TextButton(
                      onPressed: _clearFilters,
                      child: const Text(
                        'Xóa bộ lọc',
                        style: TextStyle(
                          color: Color(0xFF4ECDC4),
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),

          // Filter chips
          if (_selectedFilter != 'Tất cả')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 8, bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4ECDC4).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF4ECDC4).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedFilter,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF4ECDC4),
                          ),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _selectedFilter = 'Tất cả';
                              _filterTransactions();
                            });
                          },
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: Color(0xFF4ECDC4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Summary card
          _buildSummaryCard(isSmallScreen),

          // Transaction list
          Expanded(
            child: _filteredTransactions.isEmpty
                ? _buildEmptyState()
                : FadeTransition(
              opacity: _fadeAnimation,
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 16, bottom: 24),
                itemCount: _filteredTransactions.length,
                itemBuilder: (context, index) {
                  final monthEntry = _filteredTransactions.entries.elementAt(index);
                  final monthName = monthEntry.key;
                  final transactions = monthEntry.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMonthHeader(monthName),
                      const SizedBox(height: 8),
                      ...transactions.map((transaction) {
                        return _buildTransactionCard(context, transaction, isSmallScreen);
                      }).toList(),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action for adding new transaction or refreshing
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã cập nhật danh sách giao dịch'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        backgroundColor: const Color(0xFF4ECDC4),
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy giao dịch nào',
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
            onPressed: _clearFilters,
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
    );
  }

  Widget _buildSummaryCard(bool isSmallScreen) {
    // Calculate total spending
    double totalSpending = 0;
    double currentMonthSpending = 0;
    double previousMonthSpending = 0;

    final currentDate = DateTime.now();
    final currentMonth = currentDate.month;
    final currentYear = currentDate.year;
    final previousMonth = currentMonth == 1 ? 12 : currentMonth - 1;
    final previousYear = currentMonth == 1 ? currentYear - 1 : currentYear;

    _filteredTransactions.forEach((month, transactions) {
      for (var transaction in transactions) {
        totalSpending += transaction.amount;

        // Parse transaction date
        final parts = transaction.date.split(' ');
        final dateParts = parts[0].split('/');
        final transactionDay = int.parse(dateParts[0]);
        final transactionMonth = int.parse(dateParts[1]);
        final transactionYear = int.parse(dateParts[2]);

        if (transactionMonth == currentMonth && transactionYear == currentYear) {
          currentMonthSpending += transaction.amount;
        } else if (transactionMonth == previousMonth && transactionYear == previousYear) {
          previousMonthSpending += transaction.amount;
        }
      }
    });

    // Format numbers with commas
    final formatter = (double value) => value.toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},'
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng chi tiêu',
                style: TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.date_range,
                      size: 14,
                      color: Color(0xFF4ECDC4),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: _selectDateRange,
                      child: Text(
                        'Chọn thời gian',
                        style: TextStyle(
                          color: const Color(0xFF4ECDC4),
                          fontSize: isSmallScreen ? 10 : 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            // '${formatter(totalSpending)}đ',
              formatCurrency(totalSpending.toInt()),
            style: TextStyle(
              color: const Color(0xFF333333),
              fontSize: isSmallScreen ? 20 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSummaryItem(
                'Tháng này',
                '${formatter(currentMonthSpending)}đ',
                isSmallScreen,
                icon: Icons.calendar_today,
                color: const Color(0xFF4ECDC4),
              ),
              Container(
                height: 40,
                width: 1,
                color: Colors.grey.withOpacity(0.3),
              ),
              _buildSummaryItem(
                'Tháng trước',
                '${formatter(previousMonthSpending)}đ',
                isSmallScreen,
                icon: Icons.history,
                color: Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
      String label,
      String value,
      bool isSmallScreen, {
        required IconData icon,
        required Color color,
      }) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 14,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: isSmallScreen ? 11 : 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: const Color(0xFF333333),
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthHeader(String monthName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF4ECDC4).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF4ECDC4).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              monthName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4ECDC4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, Transaction transaction, bool isSmallScreen) {
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
    Color statusColor;
    if (transaction.status == 'Thành công') {
      statusColor = Colors.green;
    } else if (transaction.status == 'Đã hủy') {
      statusColor = Colors.red;
    } else {
      statusColor = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Navigate to order tracking screen with transaction data
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => OrderTrackingScreen(transaction: transaction),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 8 : 10, // Giảm padding
                vertical: isSmallScreen ? 10 : 14 // Giảm padding
            ),
            child: Row(
              children: [
                // Left icon container
                Container(
                  width: isSmallScreen ? 40 : 45,
                  height: isSmallScreen ? 40 : 45,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4ECDC4).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF4ECDC4),
                    size: isSmallScreen ? 20 : 22,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 8 : 10), // Giảm khoảng cách
                // Middle content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 13 : 15, // Giảm kích thước font
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis, // Thêm ellipsis khi text quá dài
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: isSmallScreen ? 10 : 12, // Giảm kích thước icon
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 2), // Giảm khoảng cách
                          Flexible(
                            child: Text(
                              transaction.date,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: isSmallScreen ? 10 : 11, // Giảm kích thước font
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Right content
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatCurrency(transaction.amount.toInt()),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 13 : 15, // Giảm kích thước font
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 4 : 6, // Giảm padding
                          vertical: 2 // Giảm padding
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 4, // Giảm kích thước
                            height: 4, // Giảm kích thước
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 2), // Giảm khoảng cách
                          Text(
                            transaction.status,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: isSmallScreen ? 9 : 10, // Giảm kích thước font
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Arrow indicator
                Padding(
                  padding: const EdgeInsets.only(left: 2), // Giảm padding
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: isSmallScreen ? 8 : 10, // Giảm kích thước icon
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Lọc giao dịch',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _clearFilters();
                        },
                        child: const Text(
                          'Đặt lại',
                          style: TextStyle(
                            color: Color(0xFF4ECDC4),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Trạng thái',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _filterOptions.map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF4ECDC4)
                                : const Color(0xFF4ECDC4).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF4ECDC4)
                                  : const Color(0xFF4ECDC4).withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            filter,
                            style: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFF4ECDC4),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Thời gian',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _selectDateRange();
                          },
                          icon: const Icon(Icons.date_range, size: 18),
                          label: Text(
                            _selectedDateRange != null
                                ? '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}'
                                : 'Chọn khoảng thời gian',
                            style: const TextStyle(fontSize: 14),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF4ECDC4),
                            side: BorderSide(color: Colors.grey.shade300),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        this.setState(() {
                          _filterTransactions();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4ECDC4),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Áp dụng',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

