import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class BackgroundService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    final service = FlutterBackgroundService();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(settings: initializationSettings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'timo_focus_channel',
      'Timo Focus Timer',
      description: 'Keeps the focus timer running in the background.',
      importance: Importance.low,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'timo_focus_channel',
        initialNotificationTitle: 'Timo Focus',
        initialNotificationContent: 'Timer is starting...',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  static void start() {
    FlutterBackgroundService().startService();
  }

  static void stop() {
    FlutterBackgroundService().invoke('stopService');
  }
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  service.on('updateTimer').listen((event) {
    if (event != null && event['seconds'] != null) {
      final seconds = event['seconds'] as int;
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      final remainingSeconds = seconds % 60;
      
      String timeStr;
      if (hours > 0) {
        timeStr = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
      } else {
        timeStr = '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
      }
      
      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: 'Timo Focus Timer',
          content: 'Focus time: $timeStr',
        );
      }
    }
  });
}
