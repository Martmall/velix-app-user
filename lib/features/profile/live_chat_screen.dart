import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../core/routing/routes.dart';
import '../../providers/user_app_providers.dart';

class LiveChatScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? extra;

  const LiveChatScreen({super.key, this.extra});

  @override
  ConsumerState<LiveChatScreen> createState() => _LiveChatScreenState();
}

class _LiveChatScreenState extends ConsumerState<LiveChatScreen> {
  final _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessageModel> _chatMessages = [];

  late bool _isHostChat;
  late String _title;
  late String _subtitle;
  late String _avatar;

  @override
  void initState() {
    super.initState();
    _isHostChat = widget.extra?['isHost'] == true;
    _title = widget.extra?['hostName'] as String? ?? (_isHostChat ? 'Car Host' : 'Velix Live Support');
    final carName = widget.extra?['carName'] as String?;
    _subtitle = carName != null ? 'Host • $carName' : 'Concierge & Fleet Host';
    _avatar = widget.extra?['partnerAvatar'] as String? ?? '';

    // If initial host message not added yet, add one
    if (_isHostChat && _chatMessages.isEmpty) {
      _chatMessages.add(
        ChatMessageModel(
          id: 'host_init_${DateTime.now().millisecondsSinceEpoch}',
          conversationId: 'conv_host',
          senderId: 'host_01',
          senderName: _title,
          text: 'Hello! I am $_title, the host for this ${carName ?? 'vehicle'}. Feel free to ask any questions about pickup, features, or scheduling!',
          timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
          isUser: false,
        ),
      );
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    final user = ref.read(userAuthProvider).user;
    final userName = user?.fullName.isNotEmpty == true ? user!.fullName : 'User';
    final userId = user?.id ?? 'user_${DateTime.now().millisecondsSinceEpoch}';

    if (text.isNotEmpty) {
      final userMsg = ChatMessageModel(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        conversationId: _isHostChat ? 'conv_host' : 'conv_01',
        senderId: userId,
        senderName: userName,
        text: text,
        timestamp: DateTime.now(),
        isUser: true,
      );

      setState(() {
        _chatMessages.add(userMsg);
        _messageController.clear();
      });

      _scrollToBottom();

      // Forward to backend API asynchronously
      try {
        ApiClient().post(
          '/support/messages',
          data: {
            'text': text,
            'senderName': userName,
            'senderId': userId,
            'conversationId': _isHostChat ? 'conv_host' : 'conv_support',
            'isUser': true,
          },
        );
      } catch (_) {}

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          final replyText = _isHostChat
              ? 'Thanks for the message! Yes, the vehicle is available and in pristine condition. I will ensure everything is prepared for your rental period.'
              : 'Thank you for reaching out! A support representative has received your query: "$text" and is reviewing your booking details.';

          final reply = ChatMessageModel(
            id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
            conversationId: _isHostChat ? 'conv_host' : 'conv_01',
            senderId: _isHostChat ? 'host_01' : 'agent_01',
            senderName: _title,
            text: replyText,
            timestamp: DateTime.now(),
            isUser: false,
          );
          setState(() {
            _chatMessages.add(reply);
          });
          _scrollToBottom();
        }
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0C1830);
    final subtextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB);
    final inputBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF4F6F9);
    final iconBtnBg = isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6);

    final messages = _chatMessages;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: iconBtnBg, borderRadius: BorderRadius.circular(12)),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 16),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.helpSupport);
              }
            },
          ),
        ),
        title: Row(
          children: [
            if (_avatar.isNotEmpty)
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(_avatar),
              )
            else
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFC84C00),
                child: Text(
                  _title.isNotEmpty ? _title[0] : 'V',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor)),
                  Text(_subtitle, style: TextStyle(fontSize: 10, color: subtextColor)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? const Color(0xFF059669) : const Color(0xFFA7F3D0)),
            ),
            child: const Row(
              children: [
                CircleAvatar(radius: 3.5, backgroundColor: Color(0xFF10B981)),
                SizedBox(width: 4),
                Text('Online', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: isDark ? const Color(0xFF451A03) : const Color(0xFFFDF0E9),
                          child: const Icon(Icons.chat_bubble, size: 36, color: Color(0xFFC84C00)),
                        ),
                        const SizedBox(height: 16),
                        Text('Start a Conversation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                        const SizedBox(height: 6),
                        Text('Our support team is online and ready to assist you.', style: TextStyle(fontSize: 13, color: subtextColor)),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(20),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isUser = msg.isUser;
                      final otherBubbleBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF3F4F6);
                      final otherTextColor = isDark ? Colors.white : const Color(0xFF0C1830);

                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(14),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                          decoration: BoxDecoration(
                            color: isUser ? const Color(0xFFC84C00) : otherBubbleBg,
                            borderRadius: BorderRadius.circular(16),
                            border: isUser ? null : Border.all(color: borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg.text,
                                style: TextStyle(fontSize: 13, color: isUser ? Colors.white : otherTextColor),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // Input bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: cardBg,
              border: Border(top: BorderSide(color: borderColor)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: inputBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: TextField(
                      controller: _messageController,
                      style: TextStyle(fontSize: 13, color: textColor),
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle: TextStyle(color: isDark ? const Color(0xFF64748B) : const Color(0xFF9CA3AF), fontSize: 13),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFC84C00), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.send, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
