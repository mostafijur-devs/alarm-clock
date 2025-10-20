import 'package:alarm/alarm.dart';
import 'package:alarm_clock/provider/provider_services.dart';
import 'package:alarm_clock/services/alarm_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screen/my_home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Alarm.init();
  // await AlarmDatabase.da;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProviderServices()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Alarm Demo'),
    );
  }
}
