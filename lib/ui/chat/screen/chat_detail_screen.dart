import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../../models/chat.dart';
import '../../../models/message.dart';

class ChatDetailScreen extends StatefulWidget {
  final Chat chat;

  const ChatDetailScreen({super.key, required this.chat});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<Message> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  bool _showSendButton = false;

  @override
  void initState() {
    super.initState();
    // Load initial messages
    _messages.addAll(widget.chat.messages);

    // Listen for text changes to show/hide send button
    _messageController.addListener(_onTextChanged);

    // Simulate store typing after a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isTyping = true;
        });

        // Simulate store sending a message after typing
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            final storeMessage = Message(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              text: 'Chào bạn, chúng tôi có thể giúp gì cho bạn?',
              isFromUser: false,
              timestamp: DateTime.now(),
              status: MessageStatus.read,
            );

            setState(() {
              _isTyping = false;
              _messages.add(storeMessage);
            });

            _scrollToBottom();
          }
        });
      }
    });
  }

  void _onTextChanged() {
    setState(() {
      _showSendButton = _messageController.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: _messageController.text.trim(),
      isFromUser: true,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );

    setState(() {
      _messages.add(newMessage);
      _messageController.clear();
      _showSendButton = false;
    });

    _scrollToBottom();

    // Simulate message being delivered after a delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      setState(() {
        final index = _messages.indexOf(newMessage);
        if (index != -1) {
          _messages[index] = Message(
            id: newMessage.id,
            text: newMessage.text,
            isFromUser: newMessage.isFromUser,
            timestamp: newMessage.timestamp,
            status: MessageStatus.delivered,
          );
        }
      });

      // Simulate store typing after a delay
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;

        setState(() {
          _isTyping = true;
        });

        // Simulate message being read and store response after a delay
        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;

          setState(() {
            final index = _messages.indexOf(newMessage);
            if (index != -1) {
              _messages[index] = Message(
                id: newMessage.id,
                text: newMessage.text,
                isFromUser: newMessage.isFromUser,
                timestamp: newMessage.timestamp,
                status: MessageStatus.read,
              );
            }
            _isTyping = false;
          });

          // Simulate store response
          Future.delayed(const Duration(milliseconds: 500), () {
            if (!mounted) return;

            final storeResponse = Message(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              text: _getRandomResponse(),
              isFromUser: false,
              timestamp: DateTime.now(),
              status: MessageStatus.read,
            );

            setState(() {
              _messages.add(storeResponse);
            });

            _scrollToBottom();
          });
        });
      });
    });
  }

  String _getRandomResponse() {
    final responses = [
      'Cảm ơn bạn đã liên hệ. Chúng tôi sẽ kiểm tra đơn hàng của bạn ngay.',
      'Đơn hàng của bạn đang được xử lý. Dự kiến sẽ giao trong hôm nay.',
      'Bạn có thể cho chúng tôi biết mã đơn hàng để kiểm tra không?',
      'Chúng tôi đã ghi nhận yêu cầu của bạn và sẽ xử lý trong thời gian sớm nhất.',
      'Bạn có cần hỗ trợ thêm gì không?',
    ];

    return responses[math.Random().nextInt(responses.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.store,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.chat.storeName,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _isTyping ? 'đang nhập...' : 'Trực tuyến',
                    style: TextStyle(
                      color: _isTyping ? Colors.grey.shade600 : Colors.green,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onPressed: () {
              // Show more options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                image: DecorationImage(
                  image: const AssetImage('assets/profile.png'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.white.withOpacity(0.05),
                    BlendMode.dstATop,
                  ),
                ),
              ),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length) {
                    // Show typing indicator
                    return _buildTypingIndicator();
                  }

                  final message = _messages[index];
                  final showTimestamp = index == 0 ||
                      _shouldShowTimestamp(message, index > 0 ? _messages[index - 1] : null);

                  return Column(
                    children: [
                      if (showTimestamp) _buildTimestampDivider(message.timestamp),
                      _buildMessageItem(message),
                    ],
                  );
                },
              ),
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  bool _shouldShowTimestamp(Message current, Message? previous) {
    if (previous == null) return true;

    final currentTime = current.timestamp;
    final previousTime = previous.timestamp;

    // Show timestamp if messages are more than 15 minutes apart
    return currentTime.difference(previousTime).inMinutes > 15;
  }

  Widget _buildTimestampDivider(DateTime timestamp) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: Colors.grey.shade300,
              thickness: 1,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _formatTimestamp(timestamp),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: Colors.grey.shade300,
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate == today) {
      return 'Hôm nay, ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      return 'Hôm qua, ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}, ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 8, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0),
            _buildDot(1),
            _buildDot(2),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      height: 8,
      width: 8,
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius: BorderRadius.circular(4),
      ),
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: 1),
        duration: Duration(milliseconds: 400 + (index * 200)),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Opacity(
            opacity: math.sin(value * math.pi * 2) * 0.5 + 0.5,
            child: child,
          );
        },
        child: Container(),
      ),
    );
  }

  Widget _buildMessageItem(Message message) {
    final time = '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}';

    return Align(
      alignment: message.isFromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: message.isFromUser ? const Color(0xFF4ECDC4) : Colors.white,
            borderRadius: BorderRadius.circular(18).copyWith(
              bottomRight: message.isFromUser ? const Radius.circular(4) : null,
              bottomLeft: !message.isFromUser ? const Radius.circular(4) : null,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Text(
                  message.text,
                  style: TextStyle(
                    color: message.isFromUser ? Colors.white : Colors.black87,
                    fontSize: 15,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      time,
                      style: TextStyle(
                        color: message.isFromUser
                            ? Colors.white.withOpacity(0.7)
                            : Colors.grey.shade500,
                        fontSize: 10,
                      ),
                    ),
                    if (message.isFromUser) ...[
                      const SizedBox(width: 4),
                      _buildMessageStatus(message.status),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageStatus(MessageStatus status) {
    switch (status) {
      case MessageStatus.sent:
        return Icon(
          Icons.check,
          size: 12,
          color: Colors.white.withOpacity(0.7),
        );
      case MessageStatus.delivered:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check,
              size: 12,
              color: Colors.white.withOpacity(0.7),
            ),
            Icon(
              Icons.check,
              size: 12,
              color: Colors.white.withOpacity(0.7),
            ),
          ],
        );
      case MessageStatus.read:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check,
              size: 12,
              color: Colors.blue.shade300,
            ),
            Icon(
              Icons.check,
              size: 12,
              color: Colors.blue.shade300,
            ),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildMessageInput() {
    // Lấy kích thước màn hình để điều chỉnh responsive
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8), // Giảm padding
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Left action buttons - Sử dụng Wrap thay vì Row để tránh tràn
              Wrap(
                spacing: 4, // Giảm khoảng cách giữa các nút
                children: [
                  _buildCircleIconButton(
                    icon: Icons.add,
                    onPressed: () {
                      // Show attachment options
                    },
                    size: isSmallScreen ? 36 : 40, // Giảm kích thước nút
                  ),
                  _buildCircleIconButton(
                    icon: Icons.camera_alt,
                    onPressed: () {
                      // Open camera
                    },
                    size: isSmallScreen ? 36 : 40, // Giảm kích thước nút
                  ),
                ],
              ),
              const SizedBox(width: 4), // Giảm khoảng cách

              // Text input field
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: 40,
                    maxHeight: 120,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12), // Giảm padding
                    child: TextField(
                      controller: _messageController,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: 'Nhập tin nhắn...',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      style: const TextStyle(fontSize: 14),
                      textCapitalization: TextCapitalization.sentences,
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: TextInputAction.newline,
                      keyboardType: TextInputType.multiline,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4), // Giảm khoảng cách

              // Right action button (send or voice)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: _showSendButton
                    ? _buildCircleIconButton(
                  key: const ValueKey('send'),
                  icon: Icons.send,
                  backgroundColor: const Color(0xFF4ECDC4),
                  iconColor: Colors.white,
                  onPressed: _sendMessage,
                  size: isSmallScreen ? 36 : 40, // Giảm kích thước nút
                )
                    : _buildCircleIconButton(
                  key: const ValueKey('mic'),
                  icon: Icons.mic,
                  backgroundColor: const Color(0xFF4ECDC4),
                  iconColor: Colors.white,
                  onPressed: () {
                    // Start voice recording
                  },
                  size: isSmallScreen ? 36 : 40, // Giảm kích thước nút
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleIconButton({
    Key? key,
    required IconData icon,
    Color backgroundColor = Colors.grey,
    Color iconColor = Colors.white,
    required VoidCallback onPressed,
    double size = 40, // Thêm tham số size để điều chỉnh kích thước
  }) {
    return Container(
      key: key,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor.withOpacity(0.8), size: size / 2),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        splashRadius: size / 2,
      ),
    );
  }
}

