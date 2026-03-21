import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:sokon/core/cache/provider/user_provider.dart';
import 'package:sokon/core/utils/app_colors.dart';
import 'package:sokon/core/utils/app_styles.dart';

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

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    receiverId = args['receiverId'];
    receiverName = args['receiverName'];
    receiverPhotoUrl = args['receiverPhotoUrl'];
    
    final userProvider = Provider.of<UserProvider>(context);
    final senderId = userProvider.user?.id ?? '';
    final senderName = userProvider.user?.name ?? 'User';
    final senderPhotoUrl = userProvider.user?.photoUrl;

    String chatId = getChatId(senderId, receiverId);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18.r,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: (receiverPhotoUrl != null && receiverPhotoUrl!.isNotEmpty)
                  ? NetworkImage(receiverPhotoUrl!)
                  : AssetImage(AppAssets.profileImage) as ImageProvider,
            ),
            SizedBox(width: 10.w),
            Expanded(child: Text(receiverName, style: AppStyles.bold20black, overflow: TextOverflow.ellipsis)),
          ],
        ),
        backgroundColor: AppColors.white,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var messages = snapshot.data!.docs;
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
                  onPressed: () => sendMessage(senderId, senderName, senderPhotoUrl, chatId),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String getChatId(String u1, String u2) {
    return u1.compareTo(u2) < 0 ? "${u1}_$u2" : "${u2}_$u1";
  }

  void sendMessage(String senderId, String senderName, String? senderPhotoUrl, String chatId) async {
    if (_messageController.text.trim().isEmpty) return;

    String msg = _messageController.text.trim();
    _messageController.clear();

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': senderId,
      'message': msg,
      'timestamp': FieldValue.serverTimestamp(),
    });
    
    // Update chat metadata for list view including photos
    Map<String, dynamic> updateData = {
      'lastMessage': msg,
      'timestamp': FieldValue.serverTimestamp(),
      'users': [senderId, receiverId],
      'displayNames': {
        senderId: senderName,
        receiverId: receiverName,
      },
      'displayPhotos': {
        senderId: senderPhotoUrl,
        receiverId: receiverPhotoUrl,
      }
    };

    await FirebaseFirestore.instance.collection('chats').doc(chatId).set(updateData, SetOptions(merge: true));
  }
}
