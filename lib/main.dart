// import 'dart:io';
//
// import 'package:alarm/alarm.dart';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// void main() async{
//   WidgetsFlutterBinding.ensureInitialized();
//   await Alarm.init();
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//
//   final String title;
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//   }
//   Future<void> checkAndroidScheduleExactAlarmPermission() async {
//     final status = await Permission.scheduleExactAlarm.status;
//     print('Schedule exact alarm permission: $status.');
//     if (status.isDenied) {
//       print('Requesting schedule exact alarm permission...');
//       final res = await Permission.scheduleExactAlarm.request();
//       print('Schedule exact alarm permission ${res.isGranted ? '' : 'not'} granted.');
//     }
//   }
//
//   int _counter = 0;
//
//   void _incrementCounter() {
//     setState(() {
//       _counter++;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//       appBar: AppBar(
//
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//
//         title: Text(widget.title),
//       ),
//       body: Center(
//         // Center is a layout widget. It takes a single child and positions it
//         // in the middle of the parent.
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text('You have pushed the button this many times:'),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed:() {
//
//           final alarmDate = DateTime.now().add(Duration(seconds: 30));
//           final alarmSettings = AlarmSettings(
//             id: 42,
//             dateTime: alarmDate,
//             assetAudioPath: 'assets/alarm.mp3',
//             loopAudio: true,
//             vibrate: true,
//             volumeSettings: VolumeSettings.fade(fadeDuration: Duration(seconds: 3)),
//             notificationSettings: NotificationSettings(title: 'this is tittle', body: 'this is body',),
//           );
//
//         } ,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }
import 'dart:async';
import 'package:alarm/alarm.dart';
import 'package:alarm_clock/home_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Alarm.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Alarm Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<AlarmSettings> alarms = [];

  static StreamSubscription<AlarmSettings>? subscription;

  int pickHours = 0;
  int pickMinute = 0;


  @override
  void initState() {
    super.initState();
    //notifcation permission
    checkAndroidNotificationPermission();
    //schedule alarm permission
    checkAndroidScheduleExactAlarmPermission();
    loadAlarms();
    subscription ??= Alarm.ringStream.stream.listen(navigateToRingScreen);
    //listen alarm if active than navigate to alarm screen
  }

  Future<void> loadAlarms() async {
    final loadedAlarms = await Alarm.getAlarms();
    loadedAlarms.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    setState(() {
      alarms = loadedAlarms;
    });
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
    loadAlarms();
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
      body: ListView(
          children: [
            Column(
              children: List.generate(
                alarms.length,
                    (index) => ListTile(
                  title: Text(DateFormat('hh:mm a').format(alarms[index].dateTime)),
                ),
              ),
            )
          ]

      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.push(context, MaterialPageRoute(builder: (context) =>
              HomeScreen(
                onTimeSelected: (hour, minute) {
                  setState(() {
                    pickHours = hour;
                    pickMinute = minute;
                  });
                  print( "Home Screen time $hour, $minute");
                },
              )));
          loadAlarms();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AlarmNotificationScreen extends StatefulWidget {
  final AlarmSettings alarmSettings;

  const AlarmNotificationScreen({super.key, required this.alarmSettings});

  @override
  State<AlarmNotificationScreen> createState() =>
      _AlarmNotificationScreenState();
}

class _AlarmNotificationScreenState extends State<AlarmNotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Alram is ringing......."),
          Text(widget.alarmSettings.notificationSettings.title),
          Text(widget.alarmSettings.notificationSettings.body),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  //skip alarm for next time
                  final now = DateTime.now();
                  Alarm.set(
                    alarmSettings: widget.alarmSettings.copyWith(
                      dateTime: DateTime(
                        now.year,
                        now.month,
                        now.day,
                        now.hour,
                        now.minute,
                      ).add(const Duration(minutes: 1)),
                    ),
                  ).then((_) => Navigator.pop(context));
                },
                child: const Text("Snooze"),
              ),
              ElevatedButton(
                onPressed: () {
                  //stop alarm
                  Alarm.stop(
                    widget.alarmSettings.id,
                  ).then((_) => Navigator.pop(context));
                },
                child: const Text("Stop"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
