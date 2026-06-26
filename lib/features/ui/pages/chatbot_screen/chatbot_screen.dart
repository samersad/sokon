import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dio/dio.dart';
import 'package:sokon/core/model/ApartmentResponse.dart';
import 'package:sokon/core/utils/app_colors.dart';
import 'package:sokon/core/utils/app_assets.dart';
import 'package:sokon/features/ui/widgets/back_container.dart';
import 'package:sokon/features/ui/widgets/featured_estates_card.dart';
import 'package:sokon/l10n/app_localizations.dart';

class ChatMessage {
  final String text;
  final bool isBot;
  final List<ApartmentResponse> apartments;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isBot,
    this.apartments = const [],
    required this.timestamp,
  });
}

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  final Dio _dio = Dio();

  String get _chatbotUrl {
    // 10.0.2.2 is the gateway to the host machine loopback interface on Android emulators
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:5001/api/chat';
    }
    return 'http://localhost:5001/api/chat';
  }

  @override
  void initState() {
    super.initState();
    // Add default welcoming message
    _messages.add(ChatMessage(
      text: "أهلاً بك في سكن! 👋\nأنا مساعدك الذكي لحجز الشقق. كيف يمكنني مساعدتك اليوم؟ يمكنك البحث عن شقة، الاستفسار عن حجز، أو السؤال عن أي شيء.",
      isBot: true,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      text: text,
      isBot: false,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final response = await _dio.post(
        _chatbotUrl,
        data: {'message': text},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => true,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final String reply = data['reply'] ?? '';
        final rawApartments = data['data'];

        List<ApartmentResponse> apartments = [];
        if (rawApartments is List) {
          apartments = rawApartments
              .map((item) => ApartmentResponse.fromJson(item))
              .toList();
        }

        setState(() {
          _messages.add(ChatMessage(
            text: reply,
            isBot: true,
            apartments: apartments,
            timestamp: DateTime.now(),
          ));
        });
      } else {
        setState(() {
          _messages.add(ChatMessage(
            text: "عذراً، حدث خطأ أثناء الاتصال بالخادم. يرجى المحاولة مرة أخرى.",
            isBot: true,
            timestamp: DateTime.now(),
          ));
        });
      }
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: "غير قادر على الاتصال بمساعد سكن الذكي حالياً. تأكد من تشغيل خادم البوت على منفذ 5001.",
          isBot: true,
          timestamp: DateTime.now(),
        ));
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 70.w,
        leading: Padding(
          padding: EdgeInsets.only(left: 15.w, top: 8.h, bottom: 8.h),
          child: const BackContainer(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primaryColor.withOpacity(0.15),
              radius: 18.r,
              child: Image.asset(
                AppAssets.chatBot,
                width: 22.w,
                color: AppColors.primaryColor,
              ),
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic ? "مساعد سكن الذكي" : "Sokon AI Assistant",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 6.w,
                      height: 6.h,
                      decoration: const BoxDecoration(
                        color: AppColors.greenColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      isArabic ? "نشط الآن" : "Active now",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.greenColor,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return _buildMessageBubble(message, theme);
                },
              ),
            ),
            if (_isLoading) _buildTypingIndicator(theme),
            _buildInputArea(theme, isArabic),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, ThemeData theme) {
    final isBot = message.isBot;
    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        constraints: BoxConstraints(maxWidth: 320.w),
        child: Column(
          crossAxisAlignment:
              isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: isBot
                    ? (theme.brightness == Brightness.dark
                        ? Colors.grey.shade900
                        : Colors.grey.shade100)
                    : AppColors.primaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft: isBot ? Radius.zero : Radius.circular(16.r),
                  bottomRight: isBot ? Radius.circular(16.r) : Radius.zero,
                ),
              ),
              child: Text(
                message.text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isBot
                      ? (theme.brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87)
                      : Colors.white,
                  fontSize: 13.sp,
                ),
              ),
            ),
            if (message.apartments.isNotEmpty) ...[
              SizedBox(height: 8.h),
              SizedBox(
                height: 180.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: message.apartments.length,
                  separatorBuilder: (context, index) => SizedBox(width: 10.w),
                  itemBuilder: (context, index) {
                    final apartment = message.apartments[index];
                    return FeaturedEstatesCard(apartment: apartment);
                  },
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(ThemeData theme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(left: 16.w, bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark
              ? Colors.grey.shade900
              : Colors.grey.shade100,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomRight: Radius.circular(16.r),
          ),
        ),
        child: SizedBox(
          width: 30.w,
          height: 15.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (index) {
              return const SizedBox(
                width: 5,
                height: 5,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryColor,
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme, bool isArabic) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: isArabic ? "اكتب طلبك هنا..." : "Type your message...",
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                filled: true,
                fillColor: theme.brightness == Brightness.dark
                    ? Colors.grey.shade900
                    : Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.r),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: _sendMessage,
            ),
          ),
          SizedBox(width: 8.w),
          CircleAvatar(
            backgroundColor: AppColors.primaryColor,
            radius: 22.r,
            child: IconButton(
              icon: Icon(
                isArabic ? Icons.arrow_back_rounded : Icons.send_rounded,
                color: Colors.white,
                size: 20.sp,
              ),
              onPressed: () => _sendMessage(_controller.text),
            ),
          ),
        ],
      ),
    );
  }
}
