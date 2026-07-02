import 'dart:convert';
import 'dart:typed_data'; // Nécessaire pour Int64List et Int32List (vibrations et flags)
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzData;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  NotificationService._internal() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  }

  Future<void> initialize() async {
    tzData.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Africa/Ouagadougou'));

    // Utilisation de l'icône de ton application Fresco
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        _handleNavigation(response.payload);
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    final notificationAppLaunchDetails = await flutterLocalNotificationsPlugin
        .getNotificationAppLaunchDetails();
    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      final payload =
          notificationAppLaunchDetails?.notificationResponse?.payload;
      Future.delayed(const Duration(seconds: 1), () {
        _handleNavigation(payload);
      });
    }

    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    // 1️⃣ CANAL 1 : Notifications Standards (Suivi basique)
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'fresco_standard_alerts',
        'Alertes Standards',
        description: 'Notifications pour le suivi classique des commandes',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
    );

    // 2️⃣ CANAL 2 (STYLE WHATSAPP) : Alertes urgentes en cuisine ou distribution
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'fresco_orders_alerts',
        'Alertes Commandes Urgentes',
        description:
            'Alertes sonores continues pour les nouvelles commandes et livraisons',
        importance: Importance.max, // Mode Heads-up (pop-up en haut de l'écran)
        playSound: true,
        enableVibration: true,
      ),
    );
  }

  // Gère la redirection automatique lors du clic sur une notification
  void _handleNavigation(String? payload) async {
    if (payload != null) {
      try {
        Map<String, dynamic> args = jsonDecode(payload);
        String? type = args['type'];

        // La navigation concrète se gère ici via tes routes GetX
        if (type != null) {
          print(
            "🧭 Navigation demandée vers le type : $type avec l'ID : ${args['order_id']}",
          );
        }
      } catch (e) {
        print("Erreur parsing navigation payload: $e");
      }
    }
  }

  Future<void> requestPermission() async {
    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }
  }

  // 🚀 NOTIFICATION STANDARD (Bip unique)
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'fresco_standard_alerts',
      'Alertes Standards',
      channelDescription: 'Notifications pour le suivi classique des commandes',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );
    const notificationDetails = NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // 🚀 COMPORTEMENT STYLE WHATSAPP (Son insistant & vibrations accentuées)
  Future<void> showUrgentOrderNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    bool loopAudio = true,
  }) async {
    // Pattern de vibration lourd : Attend 0ms, vibre 1s, pause 0.5s, vibre 1s...
    final Int64List vibrationPattern = Int64List.fromList([
      0,
      1000,
      500,
      1000,
      500,
      1000,
    ]);

    // FLAG_INSISTENT (valeur 4) force le téléphone à sonner en boucle tant que l'utilisateur n'a pas cliqué ou balayé
    final Int32List? flags = loopAudio ? Int32List.fromList([4]) : null;

    final androidDetails = AndroidNotificationDetails(
      'fresco_orders_alerts',
      'Alertes Commandes Urgentes',
      channelDescription:
          'Alertes sonores continues pour les nouvelles commandes et livraisons',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      vibrationPattern: vibrationPattern,
      ongoing: false,
      additionalFlags: flags,
      icon: '@mipmap/ic_launcher',
    );

    final iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload,
    );
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  print('📱 Notification cliquée en arrière-plan : ${response.payload}');
}
