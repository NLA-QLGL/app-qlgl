enum PromotionType {
  percentage,
  fixedAmount,
  freeService,
}

enum PromotionStatus {
  active,
  used,
  expired,
}

class Promotion {
  final String id;
  final String code;
  final String title;
  final String description;
  final PromotionType type;
  final double value; // Giá trị giảm giá (%, VND, hoặc số lượng dịch vụ miễn phí)
  final double minOrderValue; // Giá trị đơn hàng tối thiểu để áp dụng
  final DateTime startDate;
  final DateTime endDate;
  final PromotionStatus status;
  final String? imageUrl;
  final bool isNew;
  final bool isFeatured;
  final int usageLimit; // Số lần sử dụng tối đa
  final int usageCount; // Số lần đã sử dụng

  Promotion({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.type,
    required this.value,
    required this.minOrderValue,
    required this.startDate,
    required this.endDate,
    this.status = PromotionStatus.active,
    this.imageUrl,
    this.isNew = false,
    this.isFeatured = false,
    this.usageLimit = 1,
    this.usageCount = 0,
  });

  // Kiểm tra xem khuyến mãi có còn hiệu lực không
  bool get isValid {
    final now = DateTime.now();
    return status == PromotionStatus.active &&
        now.isAfter(startDate) &&
        now.isBefore(endDate) &&
        (usageLimit == 0 || usageCount < usageLimit);
  }

  // Kiểm tra xem khuyến mãi có áp dụng được cho đơn hàng không
  bool isApplicable(double orderValue) {
    return isValid && orderValue >= minOrderValue;
  }

  // Tính toán số tiền giảm giá
  double calculateDiscount(double orderValue) {
    if (!isApplicable(orderValue)) return 0;

    switch (type) {
      case PromotionType.percentage:
        return orderValue * value / 100;
      case PromotionType.fixedAmount:
        return value;
      case PromotionType.freeService:
        return 0; // Dịch vụ miễn phí không giảm trực tiếp vào giá trị đơn hàng
    }
  }

  // Tạo bản sao của khuyến mãi với trạng thái đã sử dụng
  Promotion copyWithUsed() {
    return Promotion(
      id: id,
      code: code,
      title: title,
      description: description,
      type: type,
      value: value,
      minOrderValue: minOrderValue,
      startDate: startDate,
      endDate: endDate,
      status: PromotionStatus.used,
      imageUrl: imageUrl,
      isNew: isNew,
      isFeatured: isFeatured,
      usageLimit: usageLimit,
      usageCount: usageCount + 1,
    );
  }

  // Tạo danh sách khuyến mãi mẫu
  static List<Promotion> getSamplePromotions() {
    final now = DateTime.now();

    return [
      Promotion(
        id: '1',
        code: 'WELCOME30',
        title: 'Giảm 30% cho lần đầu sử dụng',
        description: 'Giảm 30% cho đơn hàng đầu tiên của bạn. Áp dụng cho tất cả các dịch vụ giặt là.',
        type: PromotionType.percentage,
        value: 30,
        minOrderValue: 100000,
        startDate: now.subtract(const Duration(days: 30)),
        endDate: now.add(const Duration(days: 60)),
        isNew: true,
        isFeatured: true,
        usageLimit: 1,
      ),
      Promotion(
        id: '2',
        code: 'SUMMER50K',
        title: 'Giảm 50.000đ cho đơn hàng mùa hè',
        description: 'Giảm 50.000đ cho đơn hàng từ 200.000đ. Áp dụng cho dịch vụ giặt quần áo mùa hè.',
        type: PromotionType.fixedAmount,
        value: 50000,
        minOrderValue: 200000,
        startDate: now.subtract(const Duration(days: 15)),
        endDate: now.add(const Duration(days: 45)),
        isFeatured: true,
      ),
      Promotion(
        id: '3',
        code: 'FREESHIP',
        title: 'Miễn phí giao hàng',
        description: 'Miễn phí giao hàng cho đơn hàng từ 150.000đ trong phạm vi 5km.',
        type: PromotionType.freeService,
        value: 1,
        minOrderValue: 150000,
        startDate: now.subtract(const Duration(days: 10)),
        endDate: now.add(const Duration(days: 20)),
      ),
      Promotion(
        id: '4',
        code: 'BLANKET20',
        title: 'Giảm 20% giặt chăn',
        description: 'Giảm 20% cho dịch vụ giặt chăn, mền, ga trải giường.',
        type: PromotionType.percentage,
        value: 20,
        minOrderValue: 200000,
        startDate: now.subtract(const Duration(days: 5)),
        endDate: now.add(const Duration(days: 25)),
        isNew: true,
      ),
      Promotion(
        id: '5',
        code: 'SHOES15',
        title: 'Giảm 15% giặt giày',
        description: 'Giảm 15% cho dịch vụ giặt giày, dép các loại.',
        type: PromotionType.percentage,
        value: 15,
        minOrderValue: 100000,
        startDate: now.subtract(const Duration(days: 20)),
        endDate: now.add(const Duration(days: 10)),
      ),
      Promotion(
        id: '6',
        code: 'WEEKEND25',
        title: 'Giảm 25% cuối tuần',
        description: 'Giảm 25% cho đơn hàng đặt vào cuối tuần (Thứ 7, Chủ nhật).',
        type: PromotionType.percentage,
        value: 25,
        minOrderValue: 150000,
        startDate: now.subtract(const Duration(days: 2)),
        endDate: now.add(const Duration(days: 30)),
      ),
      Promotion(
        id: '7',
        code: 'LOYAL100K',
        title: 'Giảm 100.000đ cho khách hàng thân thiết',
        description: 'Giảm 100.000đ cho khách hàng có từ 10 đơn hàng trở lên.',
        type: PromotionType.fixedAmount,
        value: 100000,
        minOrderValue: 300000,
        startDate: now.subtract(const Duration(days: 10)),
        endDate: now.add(const Duration(days: 50)),
        isFeatured: true,
      ),
      // Khuyến mãi đã hết hạn
      Promotion(
        id: '8',
        code: 'EXPIRED20',
        title: 'Giảm 20% đã hết hạn',
        description: 'Khuyến mãi này đã hết hạn.',
        type: PromotionType.percentage,
        value: 20,
        minOrderValue: 100000,
        startDate: now.subtract(const Duration(days: 60)),
        endDate: now.subtract(const Duration(days: 30)),
        status: PromotionStatus.expired,
      ),
      // Khuyến mãi đã sử dụng
      Promotion(
        id: '9',
        code: 'USED30',
        title: 'Giảm 30% đã sử dụng',
        description: 'Bạn đã sử dụng khuyến mãi này.',
        type: PromotionType.percentage,
        value: 30,
        minOrderValue: 200000,
        startDate: now.subtract(const Duration(days: 15)),
        endDate: now.add(const Duration(days: 15)),
        status: PromotionStatus.used,
        usageCount: 1,
      ),
    ];
  }
}

