import 'message.dart';

class Chat {
  final String id;
  final String storeName;
  final String lastMessage;
  final String date;
  final List<Message> messages;

  Chat({
    required this.id,
    required this.storeName,
    required this.lastMessage,
    required this.date,
    required this.messages,
  });

  static List<Chat> getSampleChats() {
    return [
      Chat(
        id: '1',
        storeName: 'Cửa hàng giặt Hà Nội',
        lastMessage: 'Chào bạn, Đơn hàng đang được xử lý...',
        date: '12/01/2024',
        messages: [
          Message(
            id: '1',
            text: 'Chào bạn, tôi muốn hỏi về đơn hàng giặt quần áo của tôi',
            isFromUser: true,
            timestamp: DateTime(2024, 1, 12, 9, 30),
          ),
          Message(
            id: '2',
            text: 'Chào bạn, Đơn hàng đang được xử lý và sẽ giao vào ngày mai. Bạn có cần hỗ trợ gì thêm không?',
            isFromUser: false,
            timestamp: DateTime(2024, 1, 12, 9, 35),
          ),
        ],
      ),
      Chat(
        id: '2',
        storeName: 'Cửa hàng giặt H2',
        lastMessage: 'Chào bạn, Đơn hàng đang được giao...',
        date: '12/01/2024',
        messages: [
          Message(
            id: '1',
            text: 'Chào cửa hàng, tôi muốn đặt dịch vụ giặt chăn',
            isFromUser: true,
            timestamp: DateTime(2024, 1, 12, 10, 15),
          ),
          Message(
            id: '2',
            text: 'Chào bạn, Đơn hàng đang được giao đến địa chỉ của bạn. Dự kiến 30 phút nữa sẽ đến.',
            isFromUser: false,
            timestamp: DateTime(2024, 1, 12, 10, 20),
          ),
        ],
      ),
    ];
  }
}

