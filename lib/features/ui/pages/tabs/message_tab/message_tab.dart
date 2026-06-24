import 'package:flutter/material.dart';
import 'package:sokon/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sokon/core/cache/cubit_manger/user_view_model.dart';
import 'package:sokon/core/di/di.dart';
import 'package:sokon/core/utils/app_routes.dart';
import 'package:sokon/features/ui/pages/tabs/message_tab/cubit/message_states.dart';
import 'package:sokon/features/ui/pages/tabs/message_tab/cubit/message_view_model.dart';
import 'package:sokon/features/ui/widgets/search_widget.dart';

import '../../../../../core/utils/app_assets.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_styles.dart';

class MessageTab extends StatefulWidget {
  const MessageTab({super.key});

  @override
  State<MessageTab> createState() => _MessageTabState();
}

class _MessageTabState extends State<MessageTab> {
  final MessageViewModel viewModel = getIt<MessageViewModel>();

  @override
  void initState() {
    super.initState();
    final user = context.read<UserViewModel>().user;
    final userId = user?.id;
    if (userId != null && userId.isNotEmpty) {
      viewModel.getChats(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final userViewModel = context.read<UserViewModel>();
    final userId = userViewModel.user?.id ?? '';

    return BlocBuilder<MessageViewModel, MessageStates>(
      bloc: viewModel,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.messages, style: theme.textTheme.headlineMedium),
                  SizedBox(height: 20.h),
                  SearchWidget(hintText: l10n.search),
                  SizedBox(height: 10.h),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        if (state is MessageLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (state is MessageError) {
                          return Center(
                              child:
                                  Text("Error loading chats: ${state.message}"));
                        }
                        if (state is MessageLoaded) {
                          if (state.chats.isEmpty) {
                            return  Center(child: Text(l10n.noMessages));
                          }

                          var chats = state.chats;

                          return ListView.separated(
                            itemCount: chats.length,
                            separatorBuilder: (context, index) =>
                                SizedBox(height: 10.h),
                            itemBuilder: (context, index) {
                              var chatData = chats[index];
                              final chatId = chatData['id']?.toString() ?? '';
                              List users = chatData['users'] ?? [];
                              String receiverId = users.firstWhere(
                                (id) => id != userId,
                                orElse: () => userId,
                              );

                              final displayNames =
                                  chatData['displayNames'] as Map?;
                              final displayPhotos =
                                  chatData['displayPhotos'] as Map?;
                              final displayName = displayNames?[receiverId] ??
                                  (receiverId == userId ? l10n.savedChat : "User");
                              final photoUrl = displayPhotos?[receiverId];
                              final lastMessage =
                                  (chatData['lastMessage'] as String? ?? "")
                                      .trim();
                              final lastMessageType =
                                  chatData['lastMessageType'] as String?;
                              final previewText = lastMessage.isNotEmpty
                                  ? lastMessage
                                  : (lastMessageType == 'image' ||
                                          lastMessageType == 'mixed'
                                      ? "Photo"
                                      : "");

                              return buildChatItem(
                                context,
                                chatId,
                                receiverId,
                                displayName,
                                previewText,
                                photoUrl,
                              );
                            },
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildChatItem(
    BuildContext context,
    String chatId,
    String receiverId,
    String displayName,
    String lastMessage,
    String? photoUrl,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.chatRoute,
          arguments: {
            'chatId': chatId,
            'receiverId': receiverId,
            'receiverName': displayName,
            'receiverPhotoUrl': photoUrl,
          },
        );
      },
      child: Builder(builder: (context) {
        final theme = Theme.of(context);
        return Container(
          padding: EdgeInsets.all(15.sp),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(
                color: theme.brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.2)
                    : theme.dividerColor.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(28.r),
                child: photoUrl != null && photoUrl.isNotEmpty
                    ? Image.network(
                        photoUrl,
                        width: 56.r,
                        height: 56.r,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            CircleAvatar(
                          radius: 28.r,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: AssetImage(AppAssets.profileImage),
                        ),
                      )
                    : CircleAvatar(
                        radius: 28.r,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: AssetImage(AppAssets.avatar),
                      ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: theme.textTheme.labelMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      lastMessage,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
