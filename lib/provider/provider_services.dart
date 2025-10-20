import 'package:flutter/foundation.dart';
import '../services/alarm_database.dart';

class ProviderServices extends ChangeNotifier {
  List<Map<String, dynamic>> _alarms = [];

  List<Map<String, dynamic>> get alarms => _alarms;

  Future<void> loadAlarms() async {
    _alarms = await AlarmDatabase().getAlarms();
    notifyListeners(); // 🟢 UI rebuild হবে
  }

  Future<void> toggleAlarm(int id, bool isActive) async {
    await AlarmDatabase().updateAlarm(
      {'id': id, 'is_active': isActive ? 1 : 0},
    );
    await loadAlarms(); // ডাটাবেস থেকে নতুন ডেটা নিয়ে আসা
  }
}