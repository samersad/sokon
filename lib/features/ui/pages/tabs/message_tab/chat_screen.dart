import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:sokon/cloudinary_service.dart';
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
  final ScrollController _scrollController = ScrollController();
  late String receiverId;
  late String receiverName;
  late String chatId;
  String? receiverPhotoUrl;
  late ChatViewModel viewModel;
  bool isInitialized = false;
  bool _isSendingPhoto = false;
  bool _shouldUpsertChat = false;
  List<Map<String, dynamic>> _lastMessages = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isInitialized) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      receiverId = args['receiverId'];
      receiverName = args['receiverName'];
      receiverPhotoUrl = args['receiverPhotoUrl'];

      final senderId = context.read<UserViewModel>().user?.id ?? '';
      final providedChatId = args['chatId'] as String?;
      _shouldUpsertChat = providedChatId?.trim().isNotEmpty != true;
      chatId = providedChatId?.trim().isNotEmpty == true
          ? providedChatId!
          : getChatId(senderId, receiverId);

      viewModel = getIt<ChatViewModel>();
      _initializeChat(senderId);
      isInitialized = true;
    }
  }

  Future<void> _initializeChat(String senderId) async {
    final userViewModel = context.read<UserViewModel>();
    final senderName = userViewModel.user?.name ?? 'User';
    final senderPhotoUrl = userViewModel.user?.photoUrl;

    try {
      if (_shouldUpsertChat) {
        await viewModel.upsertChat(
          chatId: chatId,
          senderId: senderId,
          senderName: senderName,
          senderPhotoUrl: senderPhotoUrl,
          receiverId: receiverId,
          receiverName: receiverName,
          receiverPhotoUrl: receiverPhotoUrl,
        );
      }
      if (!mounted) return;
      viewModel.getMessages(chatId);
    } catch (_) {
      // The cubit already emits the API error.
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    if (isInitialized) {
      viewModel.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userViewModel = context.read<UserViewModel>();
    final senderId = userViewModel.user?.id ?? '';
    final senderName = userViewModel.user?.name ?? 'User';
    final senderPhotoUrl = userViewModel.user?.photoUrl;

    return BlocConsumer<ChatViewModel, ChatState>(
      bloc: viewModel,
      listener: (context, state) {
        if (state is ChatError) {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message),
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
              ),
            );
        }
      },
      builder: (context, state) {
        if (state is ChatMessagesLoaded) {
          _lastMessages = state.messages;
        }

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(onPressed: (){
              Navigator.pop(context);
            }, icon: Icon(Icons.arrow_back_ios_new,color: theme.primaryColor,),),
            automaticallyImplyLeading: true,
            title: Row(
              children: [
                CircleAvatar(
                  radius: 18.r,
                  backgroundColor: theme.disabledColor,
                  backgroundImage: (receiverPhotoUrl != null && receiverPhotoUrl!.isNotEmpty)
                      ? NetworkImage(receiverPhotoUrl!)
                      : AssetImage(AppAssets.avatar) as ImageProvider,
                ),
                SizedBox(width: 10.w),
                Expanded(
                    child: Text(receiverName,
                        style: theme.textTheme.displaySmall,                        overflow: TextOverflow.ellipsis)),
              ],
            ),
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 1,
          ),
          body: Column(
            children: [
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (state is ChatLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final messages = _lastMessages;
                    if (messages.isEmpty) {
                      return Center(
                        child: Text(
                          "Start the conversation",
                          style: theme.textTheme.bodyMedium,
                        ),
                      );
                    }

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToBottom();
                    });

                    return ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final data = messages[index];
                        final isMe = data['senderId'] == senderId;
                        return _buildMessageItem(data, isMe);
                      },
                    );
                  }
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0.sp),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: _isSendingPhoto
                          ? SizedBox(
                              width: 20.r,
                              height: 20.r,
                              child: const CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              Icons.image_outlined,
                              color: theme.primaryColor,
                            ),
                      onPressed: _isSendingPhoto
                          ? null
                          : () => _pickAndSendPhoto(
                                chatId: chatId,
                                senderId: senderId,
                                senderName: senderName,
                                senderPhotoUrl: senderPhotoUrl,
                                receiverId: receiverId,
                                receiverName: receiverName,
                                receiverPhotoUrl: receiverPhotoUrl,
                              ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style: theme.textTheme.titleMedium ,
                        minLines: 1,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: "Type a message...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 18.w,
                            vertical: 12.h,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send, color: theme.primaryColor),
                      onPressed: () {
                        _sendTextMessage(
                          chatId: chatId,
                          senderId: senderId,
                          senderName: senderName,
                          senderPhotoUrl: senderPhotoUrl,
                          receiverId: receiverId,
                          receiverName: receiverName,
                          receiverPhotoUrl: receiverPhotoUrl,
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h,)
            ],
          ),
        );
      },
    );
  }

  String getChatId(String u1, String u2) {
    return u1.compareTo(u2) < 0 ? "${u1}_$u2" : "${u2}_$u1";
  }

  void _sendTextMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String? senderPhotoUrl,
    required String receiverId,
    required String receiverName,
    required String? receiverPhotoUrl,
  }) {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    viewModel.sendMessage(
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      senderPhotoUrl: senderPhotoUrl,
      receiverId: receiverId,
      receiverName: receiverName,
      receiverPhotoUrl: receiverPhotoUrl,
      message: message,
    );
    _messageController.clear();
  }

  Future<void> _pickAndSendPhoto({
    required String chatId,
    required String senderId,
    required String senderName,
    required String? senderPhotoUrl,
    required String receiverId,
    required String receiverName,
    required String? receiverPhotoUrl,
  }) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.whiteBlue,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text("Take photo"),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text("Choose from gallery"),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source == null || _isSendingPhoto) return;

    try {
      await _requestMediaPermission(source);
      final pickedFile = await ImagePicker().pickImage(
        source: source,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() {
        _isSendingPhoto = true;
      });

      final imageUrl = await CloudinaryService.uploadImage(File(pickedFile.path));
      if (imageUrl == null || imageUrl.isEmpty) {
        throw Exception("Photo upload failed");
      }

      await viewModel.sendMessage(
        chatId: chatId,
        senderId: senderId,
        senderName: senderName,
        senderPhotoUrl: senderPhotoUrl,
        receiverId: receiverId,
        receiverName: receiverName,
        receiverPhotoUrl: receiverPhotoUrl,
        message: "",
        imageUrl: imageUrl,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to send photo")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSendingPhoto = false;
        });
      }
    }
  }

  Future<void> _requestMediaPermission(ImageSource source) async {
    PermissionStatus status;

    if (source == ImageSource.camera) {
      status = await Permission.camera.request();
    } else if (Platform.isIOS) {
      status = await Permission.photos.request();
    } else {
      status = await Permission.photos.request();
      if (status != PermissionStatus.granted &&
          status != PermissionStatus.limited) {
        status = await Permission.storage.request();
      }
    }

    if (status != PermissionStatus.granted &&
        status != PermissionStatus.limited) {
      throw Exception("Permission denied");
    }
  }

  Widget _buildMessageItem(Map<String, dynamic> data, bool isMe) {
    final theme = Theme.of(context);

    final payload = _parseMessagePayload(data);
    final message = payload.text;
    final imageUrl = payload.imageUrl;
    final hasImage = imageUrl.isNotEmpty;
    final sentAt = _parseTimestamp(data['timestamp']);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 260.w),
              child: Container(
                padding: hasImage
                    ? EdgeInsets.all(6.sp)
                    : EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
                decoration: BoxDecoration(
                  color: isMe ? AppColors.whiteBlue :  AppColors.grayColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasImage)
                      GestureDetector(
                        onTap: () => _openImagePreview(imageUrl),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14.r),
                          child: Image.network(
                            imageUrl,
                            width: 248.w,
                            height: 220.h,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 248.w,
                                height: 220.h,
                                color: Colors.black12,
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  color:
                                      isMe ? Colors.white70 : theme.primaryColor,
                                  size: 28.r,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    if (hasImage && message.isNotEmpty) SizedBox(height: 8.h),
                    if (message.isNotEmpty)
                      Text(
                        message,
                        style: TextStyle(
                          color: isMe ? theme.colorScheme.onPrimary : theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (sentAt != null) ...[
              SizedBox(height: 4.h),
              Text(
                DateFormat('h:mm a').format(sentAt.toLocal()),
                style: theme.textTheme.titleMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  DateTime? _parseTimestamp(dynamic value) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  _ChatMessagePayload _parseMessagePayload(Map<String, dynamic> data) {
    final legacyImageUrl = (data['imageUrl'] as String? ?? "").trim();
    final rawMessage = (data['message'] as String? ?? "").trim();

    if (legacyImageUrl.isNotEmpty) {
      return _ChatMessagePayload(
        text: rawMessage,
        imageUrl: legacyImageUrl,
      );
    }

    if (rawMessage.startsWith('__image__:')) {
      final lines = rawMessage.split('\n');
      final firstLine = lines.first;
      final imageUrl = firstLine.replaceFirst('__image__:', '').trim();
      String text = '';

      if (lines.length > 1) {
        final remaining = lines.skip(1).join('\n').trim();
        if (remaining.startsWith('__caption__:')) {
          text = remaining.replaceFirst('__caption__:', '').trim();
        } else {
          text = remaining;
        }
      }

      return _ChatMessagePayload(text: text, imageUrl: imageUrl);
    }

    return _ChatMessagePayload(text: rawMessage, imageUrl: '');
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) {
      return;
    }

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  void _openImagePreview(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          body: PhotoView(
            imageProvider: NetworkImage(imageUrl),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            loadingBuilder: (context, event) =>
                const Center(child: CircularProgressIndicator()),
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  color: Colors.white,
                  size: 36,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ChatMessagePayload {
  final String text;
  final String imageUrl;

  const _ChatMessagePayload({
    required this.text,
    required this.imageUrl,
  });
}
