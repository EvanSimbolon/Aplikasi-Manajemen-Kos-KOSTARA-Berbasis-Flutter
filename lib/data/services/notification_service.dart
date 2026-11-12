import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 1. Inisialisasi timezone lokal (WIB)
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(settings: initSettings);

    // 2. Minta izin notifikasi & exact alarm (wajib untuk Android 13+)
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();
  }

  // Mendengarkan data notifikasi dari Supabase
  void listenToNotifikasi(String userId) {
    Supabase.instance.client
        .from('notifikasi')
        .stream(primaryKey: ['id'])
        .eq('penerima_id', userId)
        .listen((data) async {
      // Simpan daftar ID notifikasi yang masih aktif ('menunggu')
      final activeNotifIds = <int>{};

      for (var item in data) {
        final int notifId = item['id'].hashCode;

        if (item['status'] == 'menunggu') {
          activeNotifIds.add(notifId);

          final String? jadwalStr = item['dijadwalkan_pada'];
          final DateTime waktuJadwal = jadwalStr != null
              ? DateTime.parse(jadwalStr).toLocal()
              : DateTime.now();

          if (waktuJadwal.isAfter(DateTime.now())) {
            // Belum waktunya -> Jadwalkan alarm lokal H-1
            await _scheduleLocalNotification(
              id: notifId,
              title: item['judul'] ?? 'Pengingat KOSTARA',
              body: item['pesan'] ?? '',
              scheduledDate: waktuJadwal,
            );
          } else {
            // Sudah masuk waktu H-1 -> Tampilkan langsung & ubah status ke 'terkirim'
            await _showLocalNotification(
              id: notifId,
              title: item['judul'] ?? 'Pengingat KOSTARA',
              body: item['pesan'] ?? '',
            );

            await Supabase.instance.client.from('notifikasi').update({
              'status': 'terkirim',
              'dikirim_pada': DateTime.now().toUtc().toIso8601String(),
            }).eq('id', item['id']);
          }
        } else if (item['status'] == 'gagal') {
          await _notificationsPlugin.cancel(id: notifId);
        }
      }

      // Batalkan alarm lokal di HP jika baris 'menunggu' sudah dihapus karena tagihan lunas
      final pendingRequests =
      await _notificationsPlugin.pendingNotificationRequests();
      for (var req in pendingRequests) {
        if (!activeNotifIds.contains(req.id)) {
          await _notificationsPlugin.cancel(id: req.id);
        }
      }
    });
  }

  // Menjadwalkan notifikasi untuk muncul tepat di waktu H-1
  Future<void> _scheduleLocalNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'kostara_reminder_channel',
      'Pengingat Pembayaran',
      channelDescription: 'Notifikasi pengingat jatuh tempo pembayaran kos',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);
    final tzScheduled = tz.TZDateTime.from(scheduledDate, tz.local);

    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tzScheduled,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle
    );
  }

  // Menampilkan notifikasi langsung saat itu juga
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
    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }
}
