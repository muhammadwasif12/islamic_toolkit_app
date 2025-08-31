// services/fcm_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/notification_popup_dialog.dart';

class FCMService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Store notification context globally
  static BuildContext? _context;

  // ADD THIS: Stream controller for real-time notification updates
  static final StreamController<List<Map<String, dynamic>>>
  _notificationStreamController =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  // ADD THIS: Method to get the notification stream
  static Stream<List<Map<String, dynamic>>> getNotificationStream() {
    return _notificationStreamController.stream;
  }

  // ADD THIS: Method to trigger stream update
  static Future<void> _updateNotificationStream() async {
    try {
      final notifications = await getStoredNotifications();
      _notificationStreamController.add(notifications);
    } catch (e) {
      print('Error updating notification stream: $e');
    }
  }

  // ADD THIS: Initialize stream with current notifications
  static Future<void> initializeNotificationStream() async {
    await _updateNotificationStream();
  }

  // ADD THIS: Dispose stream controller
  static void dispose() {
    _notificationStreamController.close();
  }

  static Future<void> initialize() async {
    // Request notification permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('Notification permission status: ${settings.authorizationStatus}');

    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap from local notification
        if (response.payload != null) {
          Map<String, dynamic> data = jsonDecode(response.payload!);
          _handleNotificationTap(data);
        }
      },
    );

    // Get FCM token
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received foreground message: ${message.data}');
      print(
        'Message notification: ${message.notification?.title} - ${message.notification?.body}',
      );
      _handleMessage(message, inForeground: true);
    });

    // Handle notification tap when app is in background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification tapped from background: ${message.data}');
      _handleMessage(message, fromTap: true);
    });

    // Check if app was launched from notification
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      print('App launched from notification: ${initialMessage.data}');
      // Delay to ensure context is available
      Future.delayed(const Duration(milliseconds: 500), () {
        _handleMessage(initialMessage, fromTap: true);
      });
    }

    // ADDED: Initialize notification stream
    await initializeNotificationStream();
  }

  // Set context for showing popups
  static void setContext(BuildContext context) {
    _context = context;
  }

  // Handle background messages - UPDATED
  static Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    print('Background message received: ${message.data}');
    await _storeNotification(message);
    // ADD THIS: Update stream after storing
    await _updateNotificationStream();
  }

  // Main message handler - UPDATED
  static void _handleMessage(
    RemoteMessage message, {
    bool inForeground = false,
    bool fromTap = false,
  }) async {
    // Store notification in local storage
    await _storeNotification(message);

    // ADD THIS: Update stream after storing
    await _updateNotificationStream();

    // If notification is tapped, show popup based on content type
    if (fromTap) {
      _showDynamicPopup(
        message.data,
        title: message.notification?.title ?? 'Notification',
        body: message.notification?.body ?? '',
      );
    } else if (inForeground) {
      // Show local notification when in foreground
      _showLocalNotification(message);
    }
  }

  // Handle notification tap from stored data
  static void _handleNotificationTap(Map<String, dynamic> data) {
    _showDynamicPopup(
      data,
      title: data['title'] ?? 'Notification',
      body: data['body'] ?? '',
    );
  }

  // Show local notification when app is in foreground
  static void _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'islamic_toolkit_channel',
          'Islamic Toolkit Notifications',
          channelDescription: 'Notifications for Islamic Toolkit App',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: false,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      message.notification?.title ?? 'Islamic Toolkit',
      message.notification?.body ?? '',
      platformChannelSpecifics,
      payload: jsonEncode({
        ...message.data,
        'title': message.notification?.title ?? 'Islamic Toolkit',
        'body': message.notification?.body ?? '',
      }),
    );
  }

  // Show dynamic popup based on Firebase data
  static void _showDynamicPopup(
    Map<String, dynamic> data, {
    String? title,
    String? body,
  }) {
    if (_context == null) {
      print('Context is null, cannot show popup');
      return;
    }

    // Check for isDua flag first
    bool isDua = data['isDua'] == 'true' || data['isDua'] == true;
    bool isHadees = data['isHadees'] == 'true' || data['isHadees'] == true;

    print('Firebase Data: $data');
    print('isDua: $isDua, isHadees: $isHadees');

    if (isDua) {
      // Show Dua popup
      _showDuaPopup(data, title: title, body: body);
    } else if (isHadees) {
      // Show Hadees popup
      _showHadeesPopup(data, title: title, body: body);
    } else {
      // Show general notification popup
      _showGeneralPopup(data, title: title, body: body);
    }
  }

  // Show Dua popup
  static void _showDuaPopup(
    Map<String, dynamic> data, {
    String? title,
    String? body,
  }) {
    showDialog(
      context: _context!,
      builder:
          (context) => ContentPopupDialog(
            title: title ?? 'Dua',
            content: body ?? data['content'] ?? '',
            arabicText:
                data['arabic_text'] ?? data['arabic'] ?? data['arabicText'],
            transliteration: data['transliteration'],
            translation: data['translation'],
            type: 'dua',
          ),
    );
  }

  // Show Hadees popup
  static void _showHadeesPopup(
    Map<String, dynamic> data, {
    String? title,
    String? body,
  }) {
    showDialog(
      context: _context!,
      builder:
          (context) => ContentPopupDialog(
            title: title ?? 'Hadees',
            content: body ?? data['content'] ?? '',
            arabicText:
                data['arabic_text'] ?? data['arabic'] ?? data['arabicText'],
            transliteration: data['transliteration'],
            translation: data['translation'],
            type: 'hadees',
          ),
    );
  }

  // Show general notification popup
  static void _showGeneralPopup(
    Map<String, dynamic> data, {
    String? title,
    String? body,
  }) {
    showDialog(
      context: _context!,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
                maxWidth: MediaQuery.of(context).size.width * 0.9,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromRGBO(62, 180, 137, 1),
                          Color.fromRGBO(81, 187, 149, 1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            title ?? 'Notification',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white24,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(
                          body ?? data['message'] ?? 'General notification',
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Action Buttons
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: const Text(
                        "OK",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(62, 180, 137, 1),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  // Store notification in local storage - UPDATED
  static Future<void> _storeNotification(RemoteMessage message) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get existing notifications
    List<String> notifications =
        prefs.getStringList('stored_notifications') ?? [];

    // Create notification object with better data handling
    Map<String, dynamic> notification = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': message.notification?.title ?? 'Notification',
      'body': message.notification?.body ?? '',
      'data': message.data, // Store complete Firebase data
      'timestamp': DateTime.now().toIso8601String(),
      'isRead': false,
    };

    print('Storing notification: ${jsonEncode(notification)}');

    // Add to list (keep only last 50 notifications)
    notifications.insert(0, jsonEncode(notification));
    if (notifications.length > 50) {
      notifications = notifications.take(50).toList();
    }

    // Save back to storage
    await prefs.setStringList('stored_notifications', notifications);

    // ADD THIS: Update stream after storing
    await _updateNotificationStream();
  }

  // Get stored notifications
  static Future<List<Map<String, dynamic>>> getStoredNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> notifications =
        prefs.getStringList('stored_notifications') ?? [];

    return notifications
        .map((notif) => Map<String, dynamic>.from(jsonDecode(notif)))
        .toList();
  }

  // Mark notification as read - UPDATED
  static Future<void> markAsRead(String notificationId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> notifications =
        prefs.getStringList('stored_notifications') ?? [];

    List<String> updatedNotifications =
        notifications.map((notifStr) {
          Map<String, dynamic> notif = jsonDecode(notifStr);
          if (notif['id'] == notificationId) {
            notif['isRead'] = true;
          }
          return jsonEncode(notif);
        }).toList();

    await prefs.setStringList('stored_notifications', updatedNotifications);

    // ADD THIS: Update stream after marking as read
    await _updateNotificationStream();
  }

  // Clear all notifications - UPDATED
  static Future<void> clearAllNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('stored_notifications');

    // ADD THIS: Update stream after clearing
    await _updateNotificationStream();
  }

  // Get unread count
  static Future<int> getUnreadCount() async {
    List<Map<String, dynamic>> notifications = await getStoredNotifications();
    return notifications.where((notif) => !notif['isRead']).length;
  }

  // Get FCM token (utility method)
  static Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }
}
