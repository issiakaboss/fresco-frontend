import 'dart:convert';
import 'dart:typed_data'; // Import indispensable pour Int64List (vibrations)
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

    const androidSettings = AndroidInitializationSettings('icon_tiim');
    const initSettings = InitializationSettings(android: androidSettings);

    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        _handleNavigation(response.payload);
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    final notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      final payload =
          notificationAppLaunchDetails?.notificationResponse?.payload;
      Future.delayed(const Duration(seconds: 1), () {
        _handleNavigation(payload);
      });
    }

    final androidPlugin =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    // 1️⃣ CANAL 1 : Rappels de médicaments standards
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'rappel_product_alarm',
        'Rappels Médicaments',
        description: 'Notifications pour rappels de médicaments',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
    );

    // 2️⃣ CANAL 2 (STYLE WHATSAPP) : Alertes Commandes Urgentes pour les Auxiliaires
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'tiim_orders_alerts', // Nouvel ID unique
        'Alertes Commandes Urgentes', // Nom dans les paramètres du téléphone
        description:
            'Alertes sonores continues pour les nouvelles demandes de produits',
        importance: Importance.max, // Pop-up en haut de l'écran (Heads-up)
        playSound: true,
        enableVibration: true,
        sound: RawResourceAndroidNotificationSound(
            'auxiliaire_alert'), // Décommente si tu ajoutes un son personnalisé dans res/raw
      ),
    );
  }

  void _handleNavigation(String? payload) async {
    if (payload != null) {
      try {
        Map<String, dynamic> args = jsonDecode(payload);
        String? targetRole = args['user_role'];
        if (targetRole != null) {
          if (targetRole == 'client') {
            
          } else if (targetRole == 'auxiliaire') {
          }
        }
      } catch (e) {}
    }
  }

  Future<void> requestPermission() async {
    final androidPlugin =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }
  }

  DateTime _adjustScheduledDate(DateTime date, String frequency) {
    final now = DateTime.now();
    final freqLower = frequency.toLowerCase();
    if (freqLower.contains('une seule fois') ||
        freqLower.contains('one time')) {
      return date;
    }
    if (!date.isAfter(now)) {
      if (freqLower.contains('quotidien')) {
        return date.add(const Duration(days: 1));
      } else if (freqLower.contains('hebdomadaire')) {
        return date.add(const Duration(days: 7));
      } else if (freqLower.contains('mensuel')) {
        int newMonth = date.month + 1;
        int newYear = date.year;
        if (newMonth > 12) {
          newMonth = 1;
          newYear += 1;
        }
        return DateTime(newYear, newMonth, date.day, date.hour, date.minute);
      }
      return date.add(const Duration(days: 1));
    }
    return date;
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String frequency,
  }) async {
    DateTime adjustedDate = _adjustScheduledDate(scheduledDate, frequency);
    final freqLower = frequency.toLowerCase();
    final isOneTime =
        freqLower.contains('une seule fois') || freqLower.contains('one time');
    if (isOneTime && !adjustedDate.isAfter(DateTime.now())) return;
    if (adjustedDate.isBefore(DateTime.now().add(Duration(seconds: 10)))) {
      adjustedDate = DateTime.now().add(Duration(seconds: 10));
    }
    final localDateTime = adjustedDate.toLocal();
    final tzDateTime = tz.TZDateTime.from(localDateTime, tz.local);
    DateTimeComponents? repeatPattern;
    if (freqLower.contains('quotidien')) {
      repeatPattern = DateTimeComponents.time;
    } else if (freqLower.contains('hebdomadaire')) {
      repeatPattern = DateTimeComponents.dayOfWeekAndTime;
    } else if (freqLower.contains('mensuel')) {
      repeatPattern = DateTimeComponents.dayOfMonthAndTime;
    }
    final androidDetails = AndroidNotificationDetails(
      'rappel_product_alarm',
      'Rappels Médicaments',
      channelDescription: 'Notifications pour rappels de médicaments',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: 'icon_tiim',
    );
    final notificationDetails = NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzDateTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: repeatPattern,
      payload: 'medicament_$id',
    );
  }

  // 🚀 COMPORTEMENT STYLE WHATSAPP (SON EN BOUCLE & ACCENTUÉ)
// 1️⃣ Pour le client (Standard - Son unique)
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'rappel_product_alarm', // Canal standard
      'Rappels Médicaments',
      channelDescription: 'Notifications pour les réponses des pharmacies',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      icon: 'icon_tiim',
    );
    const notificationDetails = NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin
        .show(id, title, body, notificationDetails, payload: payload);
  }

// 2️⃣ Pour l'auxiliaire (Style WhatsApp - Son continu en boucle ou coup unique)
  Future<void> showUrgentOrderNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    bool loopAudio = true, // 🎯 Ajout de ce paramètre
  }) async {
    final Int64List vibrationPattern =
        Int64List.fromList([0, 1000, 500, 1000, 500, 1000]);

    // 🎯 Choix dynamique du canal et des flags selon la situation
    final String channelId =
        loopAudio ? 'tiim_orders_alerts' : 'tiim_orders_alerts_once';
    final String channelName = loopAudio
        ? 'Alertes Commandes Urgentes'
        : 'Notifications Flash Commandes';
    final Int32List? flags = loopAudio
        ? Int32List.fromList([4])
        : null; // FLAG_INSISTENT uniquement si loopAudio est vrai

    final androidDetails = AndroidNotificationDetails(
      channelId, // ID du canal adapté
      channelName,
      channelDescription: loopAudio
          ? 'Alertes sonores continues pour les nouvelles demandes'
          : 'Bip unique lorsque l\'application est ouverte sur l\'écran des requêtes',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      vibrationPattern: vibrationPattern,
      ongoing: false,
      additionalFlags:
          flags, // 🎯 N'insiste que si l'utilisateur n'est pas sur l'écran
      sound: const RawResourceAndroidNotificationSound('auxiliaire_alert'),
      icon: 'icon_tiim',
    );

    // Pour iOS, la gestion du loop natif se fait différemment,
    // mais conserver le même son est parfait.
    final iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'auxiliaire_alert.mp3',
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
  print(
      '📱 Notification cliquée en arrière-plan (background) : ${response.payload}');
}
