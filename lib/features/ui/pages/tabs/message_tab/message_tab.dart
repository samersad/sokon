import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:sokon/core/cache/provider/user_provider.dart';
import 'package:sokon/core/utils/app_routes.dart';
import 'package:sokon/features/ui/widgets/search_widget.dart';

import '../../../../../core/utils/app_assets.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_styles.dart';

class MessageTab extends StatelessWidget {
  const MessageTab({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userId = userProvider.user?.id ?? '';

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Messages", style: AppStyles.bold24Primary),
              SizedBox(height: 20.h),
              SearchWidget(hintText: "Search"),
              SizedBox(height: 10.h),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('chats')
                      .where('users', arrayContains: userId)
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Error loading chats: ${snapshot.error}"));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No messages yet"));
                    }

                    var chats = snapshot.data!.docs;

                    return ListView.separated(
                      itemCount: chats.length,
                      separatorBuilder: (context, index) => SizedBox(height: 10.h),
                      itemBuilder: (context, index) {
                        var chatData = chats[index].data() as Map<String, dynamic>;
                        List users = chatData['users'] ?? [];
                        String receiverId = users.firstWhere((id) => id != userId, orElse: () => '');
                        
                        return FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance.collection('users').doc(receiverId).get(),
                          builder: (context, userSnapshot) {
                            String displayName = "User";
                            String? photoUrl;
                            
                            if (userSnapshot.hasData && userSnapshot.data!.exists) {
                              var data = userSnapshot.data!.data() as Map<String, dynamic>?;
                              displayName = data?['name'] ?? "User";
                              photoUrl = data?['photoUrl'];
                            } else {
                               Map<String, dynamic>? displayNames = chatData['displayNames'] as Map<String, dynamic>?;
                               Map<String, dynamic>? displayPhotos = chatData['displayPhotos'] as Map<String, dynamic>?;
                               displayName = displayNames?[receiverId] ?? (userSnapshot.connectionState == ConnectionState.waiting ? "Loading..." : "User");
                               photoUrl = displayPhotos?[receiverId];
                            }
                            
                            return buildChatItem(context, receiverId, displayName, chatData['lastMessage'] ?? "", photoUrl);
                          }
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildChatItem(BuildContext context, String receiverId, String displayName, String lastMessage, String? photoUrl) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.chatRoute,
          arguments: {
            'receiverId': receiverId,
            'receiverName': displayName,
            'receiverPhotoUrl': photoUrl,
          },
        );
      },
      child: Container(
        padding: EdgeInsets.all(15.sp),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(color: AppColors.grayColor.withOpacity(0.1)),
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
                      errorBuilder: (context, error, stackTrace) => CircleAvatar(
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
                    style: AppStyles.bold16PrimaryColor,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    lastMessage,
                    style: AppStyles.medium12gray,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
