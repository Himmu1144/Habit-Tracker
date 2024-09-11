import 'package:flutter/material.dart';
import 'package:habitua/models/app_settings.dart';
import 'package:habitua/models/habit.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class HabitDatabase extends ChangeNotifier {
  static late Isar isar; // initialize the Isar onject as isar

  // setup and a method to initialize the database
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar =
        await Isar.open([HabitSchema, AppSettingsSchema], directory: dir.path);
  }

  // save and fetch the start date of the app for heat map
  Future<void> saveFirstLaunchDate() async {
    final existingSettings = await isar.appSettings.where().findFirst();
    if (existingSettings == null) {
      // this means the first date settings hasn't been set so save it for current date
      final settings = AppSettings()..firstLaunchDate = DateTime.now();
      await isar.writeTxn(() => isar.appSettings.put(settings));
    }
  }

  // a function to fetch first launch date

  Future<DateTime?> getFirstLaunchDate() async {
    final settings = await isar.appSettings.where().findFirst();
    return settings?.firstLaunchDate;
  }

  // CRUD Operations on Habit Model

  // Creating a Habit
  Future<void> addHabit(String habitName) async {
    final habit = Habit()..name = habitName;
    await isar.writeTxn(() => isar.habits.put(habit));

    readHabits();
  }

  List<Habit> currentHabits = [];

  // Reading Habits
  Future<void> readHabits() async {
    final habits = await isar.habits.where().findAll();
    currentHabits.clear();
    currentHabits.addAll(habits);
    notifyListeners();
  }

  // Updating a Habit
  // 1. Updating CompletionDays
  Future<void> updateHabitCompletion(int id, bool isCompleted) async {
    final habit = await isar.habits.get(id);

    if (habit != null) {
      // if isCompleted then add today to completed days list
      final today = DateTime.now();
      if (isCompleted && !habit.completedDays.contains(DateTime.now())) {
        // add today to completed days list
        habit.completedDays.add(DateTime(today.year, today.month, today.day));
      } else {
        // if not completed than remove today from completed days list
        habit.completedDays.removeWhere((date) =>
            date.year == today.year &&
            date.month == today.month &&
            date.day == today.day);
      }
      await isar.writeTxn(() => isar.habits.put(habit));
    }
    readHabits();
  }

  // 2. Updating Habit Name
  Future<void> updateHabitName(int id, String newName) async {
    final habit = await isar.habits.get(id);
    if (habit != null) {
      await isar.writeTxn(() async {
        habit.name = newName;
        await isar.habits.put(habit);
      });
    }
    readHabits();
  }

  // Deleting a Habit
  Future<void> deleteHabit(int id) async {
    await isar.writeTxn(() async {
      await isar.habits.delete(id);
    });
    readHabits();
  }
}
