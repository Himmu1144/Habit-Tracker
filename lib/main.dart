import 'package:flutter/material.dart';
import 'package:habitua/database/habit_database.dart';
import 'package:habitua/pages/home_page.dart';
import 'package:habitua/theme/theme_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the database
  await HabitDatabase.initialize();
  await HabitDatabase().saveFirstLaunchDate();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<ThemeProvider>(
          create: (context) => ThemeProvider()),
      ChangeNotifierProvider<HabitDatabase>(
          create: (context) => HabitDatabase()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}
