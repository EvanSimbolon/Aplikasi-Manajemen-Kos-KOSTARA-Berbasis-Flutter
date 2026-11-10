import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(initSettings);
  }

  // Mendengarkan data notifikasi baru dari Supabase
  void listenToNotifikasi(String userId) {
    Supabase.instance.client
        .from('notifikasi')
        .stream(primaryKey: ['id'])
        .eq('penerima_id', userId)
        .listen((data) {
          for (var item in data) {
            if (item['status'] == 'Pending') {
              _showLocalNotification(
                id: item['id'].hashCode,
                title: item['judul'] ?? 'Pengingat KOSTARA',
                body: item['pesan'] ?? '',
              );

              // Tandai notifikasi sudah dikirim ke HP
              Supabase.instance.client
                  .from('notifikasi')
                  .update({'status': 'Dikirim'})
                  .eq('id', item['id']);
            }
          }
        });
  }

  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'kostara_reminder_channel',
      'Pengingat Pembayaran',
      channelDescription: 'Notifikasi pengingat jatuh tempo pembayaran kos',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(id, title, body, details);
  }
}
