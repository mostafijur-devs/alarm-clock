import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import '../services/alarm_database.dart';

class AddAlarmScreen extends StatefulWidget {
  final void Function(int hour, int minute)? onTimeSelected;

  final bool? isEdit;
  final Map<String, dynamic>? alarm;

  const AddAlarmScreen({super.key, this.onTimeSelected, this.isEdit, this.alarm});

  @override
  State<AddAlarmScreen> createState() => _AddAlarmScreenState();
}

class _AddAlarmScreenState extends State<AddAlarmScreen> {
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _periodController;

  final List<String> periods = ['AM', 'PM'];
  int selectedPeriodIndex = 0; // 0 = AM, 1 = PM
  int selectedHour = 0;
  int selectedMinute = 0;

  @override
  void initState() {
    super.initState();

    if (widget.isEdit == true) {
      int currentHour = widget.alarm!['hour'];
      int currentMinute = widget.alarm!['minute'];
      // AM বা PM ঠিক করা হচ্ছে
      selectedPeriodIndex = currentHour >= 12 ? 1 : 0;
      _periodController = FixedExtentScrollController(
        initialItem: selectedPeriodIndex,
      );
      _hourController = FixedExtentScrollController(initialItem: currentHour);
      _minuteController = FixedExtentScrollController(
        initialItem: currentMinute,
      );
      selectedHour = currentHour;
      selectedMinute = currentMinute;
    }
    else {
      int currentHour = TimeOfDay.now().hour;
      int currentMinute = TimeOfDay.now().minute;
      // AM বা PM ঠিক করা হচ্ছে
      selectedPeriodIndex = currentHour >= 12 ? 1 : 0;
      _periodController = FixedExtentScrollController(
        initialItem: selectedPeriodIndex,
      );
      _hourController = FixedExtentScrollController(initialItem: currentHour);
      _minuteController = FixedExtentScrollController(
        initialItem: currentMinute,
      );
      selectedHour = currentHour;
      selectedMinute = currentMinute;
    }
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
      // backgroundColor: Colors.black,
      // appBar: AppBar(title: const Text('Alarm Time Picker')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [_buildPeriodWheel()],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          child: Container(
                            width: 200,
                            height: 60,
                            decoration: BoxDecoration(
                              // color: Colors.green,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildWidgetList(
                                selectedIndex: selectedHour,
                                controller: _hourController,
                                items: List.generate(24, (index) => index),
                                onChanged: (value) {
                                  setState(() {
                                    selectedHour = value;
                                    // ⏰ এখানে Hour থেকে AM/PM ঠিক করে নিচ্ছি
                                    if (selectedHour >= 12) {
                                      selectedPeriodIndex = 1; // PM
                                      _periodController.jumpToItem(1);
                                    } else {
                                      selectedPeriodIndex = 0; // AM
                                      _periodController.jumpToItem(0);
                                    }
                                  });
                                  widget.onTimeSelected?.call(
                                    selectedHour,
                                    selectedMinute,
                                  );
                                },
                              ),

                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  ':',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 30,
                                  ),
                                ),
                              ),

                              _buildWidgetList(
                                selectedIndex: selectedMinute,
                                controller: _minuteController,
                                items: List.generate(60, (index) => index),
                                onChanged: (value) {
                                  setState(() {
                                    selectedMinute = value;
                                    if (value > 12) {
                                      _periodController =
                                          FixedExtentScrollController(
                                            initialItem: 0,
                                          );
                                    } else {
                                      _periodController =
                                          FixedExtentScrollController(
                                            initialItem: 1,
                                          );
                                    }
                                  });
                                  widget.onTimeSelected?.call(
                                    selectedHour,
                                    selectedMinute,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(selectedHour.toString(), style: TextStyle(fontSize: 25)),
                  ElevatedButton(
                    onPressed: () async {
                      final now = DateTime.now();
                      DateTime alarmDateTime = DateTime(
                        now.year,
                        now.month,
                        now.day,
                        selectedHour,
                        selectedMinute,
                      );
                      if(widget.isEdit!){
                        final db = AlarmDatabase();
                        final alarmSettings = AlarmSettings(
                          id: widget.alarm?['id'],
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
                        // Sqflite-এ save
                        await db.updateAlarm({
                          'id': widget.alarm?['id'],
                          'hour': selectedHour,
                          'minute': selectedMinute,
                          'am_pm': selectedPeriodIndex == 0 ? 'AM' : 'PM',
                          'is_active': 1, // 1 = active, 0 = inactive
                        });
                      }
                      else{
                        final db = AlarmDatabase();
                        final allAlarms = await AlarmDatabase().getAlarms();
                        final newId = allAlarms.isEmpty
                            ? 1
                            : allAlarms.last['id'] + 1;

                        final alarmSettings = AlarmSettings(
                          id: newId,
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
                        // Sqflite-এ save

                        await db.insertAlarm({
                          'id': newId,
                          'hour': selectedHour,
                          'minute': selectedMinute,
                          'am_pm': selectedPeriodIndex == 0 ? 'AM' : 'PM',
                          'is_active': 1, // 1 = active, 0 = inactive
                        });
                      }
                      Navigator.pop(context);
                    },
                    child: widget.isEdit!
                        ? Text('Update Alarm')
                        : Text('Save alarm'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWidgetList({
    required FixedExtentScrollController controller,
    required List<int> items,
    required Function(int) onChanged,
    required int selectedIndex,
  }) {
    return SizedBox(
      width: 80,
      child: ListWheelScrollView.useDelegate(
        physics: FixedExtentScrollPhysics(),
        perspective: 0.001,
        diameterRatio: 2.0,
        itemExtent: 70,
        controller: controller,
        onSelectedItemChanged: onChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: items.length,
          builder: (context, index) {
            final isSelected = index == selectedIndex;

            return AnimatedContainer(
              duration: Duration(milliseconds: 200),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? Colors.green : Colors.transparent,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                '${items[index]}'.padLeft(2, '0'),
                style: TextStyle(
                  fontSize: 45,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPeriodWheel() {
    return SizedBox(
      width: 70,
      child: ListWheelScrollView.useDelegate(
        controller: _periodController,
        physics: FixedExtentScrollPhysics(),
        itemExtent: 60,
        onSelectedItemChanged: (index) {
          setState(() {
            selectedPeriodIndex = index;
          });
        },
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: periods.length,
          builder: (context, index) {
            final isSelected = index == selectedPeriodIndex;
            return AnimatedContainer(
              duration: Duration(milliseconds: 200),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? Colors.green : Colors.transparent,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                periods[index],
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
