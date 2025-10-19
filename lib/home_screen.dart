import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final void Function(int hour, int minute)? onTimeSelected;

  const HomeScreen({super.key, this.onTimeSelected});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  int selectedHour = TimeOfDay.now().hour;
  int selectedMinute = TimeOfDay.now().minute;


  @override
  void initState() {
    super.initState();
    _hourController = FixedExtentScrollController(initialItem: selectedHour);
    _minuteController = FixedExtentScrollController(initialItem: selectedMinute);
    print("time $selectedMinute , ,, $selectedHour");
  }

  @override
  void dispose() {
    super.dispose();

    _hourController.dispose();
    _minuteController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // appBar: AppBar(title: const Text('Alarm Time Picker')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(

                alignment: Alignment.center,
                children: [
                  Positioned(child: Container(
                    width: 200,
                    height: 60,
                    decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20)
                    ),
                  )),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildWidgetList(
                          controller: _hourController,
                          items: List.generate(24, (index) => index),
                          onChanged: (value) {
                            setState(() {
                              selectedHour = value;
                            });
                            widget.onTimeSelected?.call(selectedHour, selectedMinute);
                          },
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(':',style: TextStyle(color: Colors.red,fontSize: 30),),
                        ),

                        _buildWidgetList(
                          controller: _minuteController,
                          items: List.generate(60, (index) => index),
                          onChanged: (value) {
                            setState(() {
                              selectedMinute = value;
                            });
                            widget.onTimeSelected?.call(selectedHour, selectedMinute);
                          },
                        ),
                      ],
                    ),
                  )

                ],
              ),
            ),
            Text(selectedHour.toString(),style: TextStyle(fontSize: 25),),
            ElevatedButton(onPressed: () async {
              print("conform date $selectedHour ,   $selectedMinute");

              final now = DateTime.now();
              DateTime alarmDateTime = DateTime(
                now.year,
                now.month,
                now.day,
                selectedHour,
                selectedMinute,
              );

// যদি নির্বাচিত সময় আগের হয়, তাহলে পরের দিনের জন্য সেট করো
//               if (alarmDateTime.isBefore(now)) {
//                 alarmDateTime = alarmDateTime.add(const Duration(days: 1));
//               }

              final alarmSettings = AlarmSettings(
                id: 42,
                dateTime: alarmDateTime,
                assetAudioPath: 'assets/alarm.mp3',
                loopAudio: true,
                vibrate: true,
                volumeSettings: VolumeSettings.fade(
                  volume: 0.8,
                  fadeDuration: Duration(seconds: 5),
                  volumeEnforced: true,
                ),
                notificationSettings: NotificationSettings(
                  title: 'This is the title',
                  body: 'This is the body',
                  stopButton: 'Stop the alarm',
                  icon: 'notification_icon',
                  iconColor: const Color(0xff862778),
                ),
              );

              await Alarm.set(alarmSettings: alarmSettings);


              // loadAlarms();
              Navigator.pop(context);
            }, child: Text('Save alarm'))
          ],
        ),
      ),
    );
  }

  Widget _buildWidgetList({
    required FixedExtentScrollController controller,
    required List<int> items,
    required Function(int) onChanged,
  }) {
    return SizedBox(
      width: 70,
      child: ListWheelScrollView.useDelegate(
        physics: FixedExtentScrollPhysics(),
        perspective: 0.009,
        diameterRatio: 2.0,
        itemExtent: 80,
        onSelectedItemChanged: onChanged,
        childDelegate: ListWheelChildBuilderDelegate(

          childCount: items.length,
          builder: (context, index) {
            return Center(
              child: Text(
                items[index].toString().padLeft(2, '0'),
                style: TextStyle(
                  fontSize: 60,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
