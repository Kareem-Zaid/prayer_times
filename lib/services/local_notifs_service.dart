import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:prayer_times/models/prayer_models.dart';
import 'package:prayer_times/models/user_settings.dart';
import 'package:prayer_times/services/api_service.dart';
import 'package:prayer_times/utils/string_extensions.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

// If not added, an exception occurs
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  debugPrint('onDidReceiveBackgroundNotifResp: $notificationResponse');
}

class LocalNotifsService {
  // int id = 0;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationDetails _androidNotificationDetails =
      AndroidNotificationDetails(
    'KZ-PT',
    'حان وقت الصلاة',
    channelDescription: 'تنبيهات دخول وقت الصلاة',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
    // android/app/src/main/res/raw/sound_file_name
    sound: RawResourceAndroidNotificationSound('prayer_time'),
  );

  final NotificationDetails _notificationDetails =
      const NotificationDetails(android: _androidNotificationDetails);

  Future<void> _configureLocalTimeZone() async {
    if (kIsWeb || Platform.isLinux) return;

    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  Future<void> initLocalNotifs() async {
    WidgetsFlutterBinding.ensureInitialized();
    await _configureLocalTimeZone();

    // android/app/src/main/res/drawable/app_icon.png
    // If not added, an exception occurs
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          // Next callback fires when a notification has been tapped on
          (NotificationResponse notificationResponse) {
        debugPrint('onDidReceiveNotificationResponse: $notificationResponse');
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  // Request permissions either on the initialization of the first page
  // or on activating (switching on) notifications from settings
  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      // Check whether permission is granted
      bool granted = await _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.areNotificationsEnabled() ??
          false;

      // Request permission for notifications if not granted yet
      if (!granted) {
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
            _flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                    AndroidFlutterLocalNotificationsPlugin>();

        await androidImplementation?.requestNotificationsPermission();
      }
    }
  }

  tz.TZDateTime _getScheduledTime(String timeStr) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    final DateTime dateTime = timeStr.parseTime();
    final int hours = dateTime.hour;
    final int mins = dateTime.minute;
    final tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hours, mins);
    return scheduledDate;
  }

  // Schedule notification to appear in 5 seconds based on local time zone
  Future<void> zonedScheduleNotification(
      int id, String title, String body, String timeStr) async {
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id, title, body, _getScheduledTime(timeStr), _notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      // matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
      matchDateTimeComponents: DateTimeComponents.dateAndTime, // Repeat yearly
    );
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  void schedulePrayerNotifications(UserSettings settings) async {
    // Reschedule notifications only if on
    if (!settings.isNotifsOn) return;

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    final List<Future<void>> futures = [];

    // Loop a week starting from today
    for (var i = 0; i < 7; i++) {
      final tz.TZDateTime date = now.add(Duration(days: i));

      // Assign API request to get PrayerDay
      PrayerDay prayerDay = await ApiService.getPrayerDay(
        date: date,
        apiPars: settings,
      );

      // Get prayers list of each day and remove 'sunrise'
      final prayerList = prayerDay.datum.prayers.prayerList..removeAt(1);

      // Loop through prayers of the day and add to futures
      for (int i = 0; i < prayerList.length; i++) {
        final Prayer prayer = prayerList[i];
        final int id = int.parse('${date.year}${date.month}${date.day}$i');

        futures.add(
          zonedScheduleNotification(
            id,
            'صلاة ${prayer.name}',
            'حان الآن موعد صلاة ${prayer.name} بتوقيت ${settings.country?.name}، ${settings.city?.name}',
            prayer.time,
          ),
        );
      }
    }

    await Future.wait(futures);
    debugPrint('Done scheduling notifications for a week starting from $now');
  }
}
