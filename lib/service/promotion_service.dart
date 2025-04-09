import 'dart:async';
import '../models/promotion.dart';

class PromotionService {
  // Singleton pattern
  static final PromotionService _instance = PromotionService._internal();
  factory PromotionService() => _instance;
  PromotionService._internal();

  // Danh sách khuyến mãi
  List<Promotion> _promotions = [];

  // Stream controller để phát sự kiện khi có thay đổi
  final _promotionController = StreamController<List<Promotion>>.broadcast();
  Stream<List<Promotion>> get promotionStream => _promotionController.stream;

  // Khởi tạo dữ liệu
  Future<void> initialize() async {
    // Trong ứng dụng thực tế, bạn sẽ tải khuyến mãi từ API hoặc local storage
    _promotions = Promotion.getSamplePromotions();
    _promotionController.add(_promotions);
  }

  // Lấy tất cả khuyến mãi
  List<Promotion> getAllPromotions() {
    return List.from(_promotions);
  }

  // Lấy khuyến mãi đang hoạt động
  List<Promotion> getActivePromotions() {
    return _promotions.where((promotion) => promotion.isValid).toList();
  }

  // Lấy khuyến mãi nổi bật
  List<Promotion> getFeaturedPromotions() {
    return _promotions.where((promotion) => promotion.isFeatured && promotion.isValid).toList();
  }

  // Lấy khuyến mãi mới
  List<Promotion> getNewPromotions() {
    return _promotions.where((promotion) => promotion.isNew && promotion.isValid).toList();
  }

  // Lấy khuyến mãi theo ID
  Promotion? getPromotionById(String id) {
    try {
      return _promotions.firstWhere((promotion) => promotion.id == id);
    } catch (e) {
      return null;
    }
  }

  // Lấy khuyến mãi theo mã
  Promotion? getPromotionByCode(String code) {
    try {
      return _promotions.firstWhere((promotion) =>
      promotion.code.toLowerCase() == code.toLowerCase() &&
          promotion.isValid
      );
    } catch (e) {
      return null;
    }
  }

  // Sử dụng khuyến mãi
  Future<bool> usePromotion(String id) async {
    final index = _promotions.indexWhere((promotion) => promotion.id == id);
    if (index != -1 && _promotions[index].isValid) {
      _promotions[index] = _promotions[index].copyWithUsed();
      _promotionController.add(_promotions);
      return true;
    }
    return false;
  }

  // Tìm kiếm khuyến mãi
  List<Promotion> searchPromotions(String query) {
    if (query.isEmpty) return getAllPromotions();

    final lowercaseQuery = query.toLowerCase();
    return _promotions.where((promotion) {
      return promotion.title.toLowerCase().contains(lowercaseQuery) ||
          promotion.description.toLowerCase().contains(lowercaseQuery) ||
          promotion.code.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Đóng stream controller khi không cần thiết
  void dispose() {
    _promotionController.close();
  }
}

