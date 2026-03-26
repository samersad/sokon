import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sokon/core/cache/cubit_manger/user_view_model.dart';
import 'package:sokon/core/di/di.dart';
import 'package:sokon/core/utils/app_colors.dart';
import 'package:sokon/core/utils/app_styles.dart';
import 'package:sokon/features/ui/pages/tabs/message_tab/cubit/chat_states.dart';
import 'package:sokon/features/ui/pages/tabs/message_tab/cubit/chat_view_model.dart';

import '../../../../../core/utils/app_assets.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late String receiverId;
  late String receiverName;
  String? receiverPhotoUrl;
  late ChatViewModel viewModel;
  bool isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isInitialized) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      receiverId = args['receiverId'];
      receiverName = args['receiverName'];
      receiverPhotoUrl = args['receiverPhotoUrl'];

      final senderId = context.read<UserViewModel>().user?.id ?? '';
      String chatId = getChatId(senderId, receiverId);

      viewModel = getIt<ChatViewModel>();
      viewModel.getMessages(chatId);
      isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = context.read<UserViewModel>();
    final senderId = userViewModel.user?.id ?? '';
    final senderName = userViewModel.user?.name ?? 'User';
    final senderPhotoUrl = userViewModel.user?.photoUrl;
    String chatId = getChatId(senderId, receiverId);

    return BlocProvider(
      create: (context) => viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              CircleAvatar(
                radius: 18.r,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: (receiverPhotoUrl != null && receiverPhotoUrl!.isNotEmpty)
                    ? NetworkImage(receiverPhotoUrl!)
                    : AssetImage(AppAssets.avatar) as ImageProvider,
              ),
              SizedBox(width: 10.w),
              Expanded(
                  child: Text(receiverName,
                      style: AppStyles.bold20black,
                      overflow: TextOverflow.ellipsis)),
            ],
          ),
          backgroundColor: AppColors.white,
          elevation: 1,
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatViewModel, ChatState>(
                builder: (context, state) {
                  if (state is ChatLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ChatError) {
                    return Center(child: Text("Error: ${state.message}"));
                  } else if (state is ChatMessagesLoaded) {
                    var messages = state.messages;
                    return ListView.builder(
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        var data = messages[index].data() as Map<String, dynamic>;
                        bool isMe = data['senderId'] == senderId;
                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
                            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
                            decoration: BoxDecoration(
                              color: isMe ? AppColors.primaryColor : Colors.grey[300],
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                            child: Text(
                              data['message'] ?? "",
                              style: TextStyle(color: isMe ? Colors.white : Colors.black),
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0.sp),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: AppColors.primaryColor),
                    onPressed: () {
                      if (_messageController.text.trim().isNotEmpty) {
                        viewModel.sendMessage(
                          chatId: chatId,
                          senderId: senderId,
                          senderName: senderName,
                          senderPhotoUrl: senderPhotoUrl,
                          receiverId: receiverId,
                          receiverName: receiverName,
                          receiverPhotoUrl: receiverPhotoUrl,
                          message: _messageController.text,
                        );
                        _messageController.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getChatId(String u1, String u2) {
    return u1.compareTo(u2) < 0 ? "${u1}_$u2" : "${u2}_$u1";
  }
}
