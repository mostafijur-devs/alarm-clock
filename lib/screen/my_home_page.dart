import 'dart:async';
import 'package:alarm/alarm.dart';
import 'package:alarm_clock/provider/provider_services.dart';
import 'package:alarm_clock/services/alarm_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'alarm_notification_screen.dart';
import 'add_alarm_screen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  static StreamSubscription<AlarmSettings>? subscription;

  int pickHours = 0;
  int pickMinute = 0;

@override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    context.watch<ProviderServices>().loadAlarms();


  }
  @override
  void initState() {
    super.initState();
    //notification permission
    checkAndroidNotificationPermission();
    //schedule alarm permission
    checkAndroidScheduleExactAlarmPermission();
    // context.watch<ProviderServices>().loadAlarms();
    subscription ??= Alarm.ringStream.stream.listen(navigateToRingScreen);
    //listen alarm if active than navigate to alarm screen
    }

  Future<void> checkAndroidNotificationPermission() async {
    final status = await Permission.notification.status;
    if (status.isDenied) {
      print('Requesting notification permission...');
      final res = await Permission.notification.request();
      print('Notification permission ${res.isGranted ? '' : 'not '}granted');
    }
  }

  Future<void> navigateToRingScreen(AlarmSettings alarmSettings) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) =>
            AlarmNotificationScreen(alarmSettings: alarmSettings),
      ),
    );
    context.read<ProviderServices>().loadAlarms();

  }

  Future<void> checkAndroidScheduleExactAlarmPermission() async {
    final status = await Permission.scheduleExactAlarm.status;
    if (kDebugMode) {
      print('Schedule exact alarm permission: $status.');
    }
    if (status.isDenied) {
      if (kDebugMode) {
        print('Requesting schedule exact alarm permission...');
      }
      final res = await Permission.scheduleExactAlarm.request();
      if (kDebugMode) {
        print(
          'Schedule exact alarm permission ${res.isGranted
              ? ''
              : 'not'} granted.',
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .inversePrimary,
        title: Text(widget.title),
      ),
      body: Consumer<ProviderServices>(
        builder: (context, value, child) {
      final alarms = value.alarms;

      if (alarms.isEmpty) {
        return const Center(child: Text('No alarm set'));
      }

      return ListView.builder(
        itemCount: alarms.length,
        itemBuilder: (context, index) {
          final alarm = alarms[index];
          return GestureDetector(
            onLongPress: () {
              showDialog(context: context, builder: (context) {
                return AlertDialog(
                  icon: FlutterLogo(),
                  content: Text("Are you sure.\nYou can delete your message "),
                  actions: [
                    ElevatedButton(onPressed: () async{
                      final db = AlarmDatabase();
                      await  db.deleteAlarm(alarm['id']);
                      Navigator.pop(context);
                    }, child: Text('Delete')),
                    ElevatedButton(onPressed: () async{
                      Navigator.pop(context);
                    }, child: Text('close')),
                  ],
                );
                  
                  AboutDialog(
                  
                  

                  children: [
                    ElevatedButton(onPressed: () async{
                      final db = AlarmDatabase();
                      await  db.deleteAlarm(alarm['id']);
                    }, child: Text('data'))
                  ],
                );
              },);


            },
            child: ListTile(

              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) =>
                    AddAlarmScreen(
                      alarm: alarm,
                      isEdit: true,
                      onTimeSelected: (hour, minute) {
                        setState(() {
                          pickHours = hour;
                          pickMinute = minute;
                        });
                        print( "Home Screen time $hour, $minute");
                      },
                    )));
                context.read<ProviderServices>().loadAlarms();
              },
              title: Text(
                '${alarm['hour'].toString().padLeft(2, '0')}:${alarm['minute'].toString().padLeft(2, '0')} ${alarm['am_pm']}',
              ),
              trailing: Switch(
                value: alarm['is_active'] == 1,
                onChanged: (val) async{
                  value.toggleAlarm(alarm['id'], val);
                  if(val){
                    final now = DateTime.now();
                    DateTime alarmDateTime = DateTime(
                      now.year,
                      now.month,
                      now.day,
                      alarm['hour'],
                      alarm['minute'],
                    );
                    if (alarmDateTime.isBefore(now)) {
                      alarmDateTime = alarmDateTime.add(const Duration(days: 1));
                      final alarmSettings = AlarmSettings(
                        id: alarm['id'],
                        dateTime: alarmDateTime,
                        assetAudioPath: 'assets/black.mp3',
                        loopAudio: true,
                        vibrate: true,
                        notificationSettings: NotificationSettings(
                          title: 'Alarm',
                          body: 'Time to wake up!',
                          stopButton: 'Stop Alarm',
                        ),
                        volumeSettings: VolumeSettings.fade(
                          volume: 0.8,
                          fadeDuration: Duration(seconds: 5),
                          volumeEnforced: true,
                        ),
                      );
                      await Alarm.set(alarmSettings: alarmSettings);
                    }
                  }else{
                    await Alarm.stop(alarm['id']);

                  }
                },
              ),
            ),
          );
        },
      );
    },
    ),


      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.push(context, MaterialPageRoute(builder: (context) =>
              AddAlarmScreen(
                isEdit: false,
                onTimeSelected: (hour, minute) {

                  setState(() {
                    pickHours = hour;
                    pickMinute = minute;
                  });
                  print( "Home Screen time $hour, $minute");
                },
              )));
          context.read<ProviderServices>().loadAlarms();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}