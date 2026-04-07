import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lingolearn/home_module/controller/notification_controller.dart';
import 'package:lingolearn/home_module/models/notification_model.dart';
import 'package:lingolearn/utilities/navigation/navigator.dart';
import 'package:lingolearn/utilities/packages/liquid_pull_to_refresh.dart';
import 'package:lingolearn/utilities/theme/app_colors.dart';
import 'package:intl/intl.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  final controller = Get.put(NotificationController());

  @override
  void initState() {
    controller.getNotifications();
    controller.markAllAsRead();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBeigeBg,
      appBar: AppBar(
        backgroundColor: kBeigeBg,
        surfaceTintColor: kBeigeBg,
        elevation: 0,
        leadingWidth: 70,
        leading: Center(
          child: Container(
            margin: const EdgeInsets.only(left: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kSandyBorder),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: kDarkSlate, size: 18),
              onPressed: () => MyNavigator.pop(),
            ),
          ),
        ),
        centerTitle: true,
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: kDarkSlate,
            fontFamily: 'serif',
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: controller.obx(
        (state) {
          if (state == null ||
              state.notifications == null ||
              state.notifications!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: kCardYellow.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.notifications_none_rounded,
                        size: 64, color: kAmberAccent.withValues(alpha: 0.5)),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Nothing to see here",
                    style: TextStyle(
                        color: kDarkSlate,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'serif'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "We'll notify you when something\nexciting happens!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: kSoftGray.withValues(alpha: 0.8),
                        fontSize: 14,
                        height: 1.5),
                  ),
                ],
              ),
            );
          }

          return LiquidPullToRefresh(
            color: kPrimary,
            backgroundColor: Colors.white,
            animSpeedFactor: 2.0,
            onRefresh: () => controller.getNotifications(),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: state.notifications!.length,
              itemBuilder: (context, index) {
                final notification = state.notifications![index];
                return _NotificationTile(
                    notification: notification, controller: controller);
              },
            ),
          );
        },
        onLoading:
            const Center(child: CircularProgressIndicator(color: kAmberAccent)),
        onError: (err) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 48, color: Colors.orange),
              const SizedBox(height: 16),
              Text("Error loading notifications: $err"),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => controller.getNotifications(),
                style: ElevatedButton.styleFrom(
                    backgroundColor: kAmberAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final NotificationController controller;

  const _NotificationTile(
      {required this.notification, required this.controller});

  @override
  Widget build(BuildContext context) {
    DateTime? updatedAt;
    try {
      updatedAt = DateTime.parse(
          notification.updatedAt ?? DateTime.now().toIso8601String());
    } catch (e) {
      updatedAt = DateTime.now();
    }

    final String timeAgo = DateFormat.yMMMd().add_jm().format(updatedAt!);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notification.isRead == true
            ? Colors.white
            : kCardYellow.withValues(alpha: 0.6),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
          bottomLeft: Radius.circular(8),
        ),
        border: Border.all(
          color: notification.isRead == true
              ? kSandyBorder.withValues(alpha: 0.5)
              : kAmberAccent.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          if (notification.isRead == false)
            BoxShadow(
              color: kAmberAccent.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getIconColor(notification.type),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color:
                      _getIconColor(notification.type).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Icon(
              _getIcon(notification.type),
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title ?? "Update",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: notification.isRead == true
                              ? FontWeight.bold
                              : FontWeight.w900,
                          color: kDarkSlate,
                          fontFamily: 'serif',
                        ),
                      ),
                    ),
                    if (notification.isRead == false)
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: kAmberAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                Text(
                  notification.message ?? "",
                  style: TextStyle(
                    fontSize: 14,
                    color: kDarkSlate.withValues(alpha: 0.7),
                    fontWeight: notification.isRead == true
                        ? FontWeight.w500
                        : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.access_time_rounded,
                        size: 14, color: kSoftGray.withValues(alpha: 0.8)),
                    const SizedBox(width: 4),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        fontSize: 12,
                        color: kSoftGray.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String? type) {
    switch (type) {
      case 'achievement':
        return Icons.emoji_events_rounded;
      case 'follow':
        return Icons.person_add_alt_1_rounded;
      case 'system':
        return Icons.info_outline_rounded;
      case 'lesson':
        return Icons.menu_book_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  Color _getIconColor(String? type) {
    switch (type) {
      case 'achievement':
        return kAmberAccent;
      case 'follow':
        return const Color(0xFF6366F1); // Indigo
      case 'system':
        return const Color(0xFF10B981); // Emerald
      case 'lesson':
        return const Color(0xFFF43F5E); // Rose
      default:
        return kSoftGray;
    }
  }
}
