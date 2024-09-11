import 'package:flutter/material.dart';
import 'package:habitua/components/my_drawer.dart';
import 'package:habitua/components/my_habit_tile.dart';
import 'package:habitua/components/my_heat_map.dart';
import 'package:habitua/database/habit_database.dart';
import 'package:habitua/models/habit.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    readHabitsDB();
  }

  final TextEditingController myController = TextEditingController();

  void readHabitsDB() {
    context.read<HabitDatabase>().readHabits();
  }

  bool isHabitCompletedToday(List<DateTime> completedDays) {
    final today = DateTime.now();
    return completedDays.any((date) =>
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day);
  }

  void checkHabitOnOff(bool? value, Habit habit) {
    // updating the habit completion status
    if (value != null) {
      context.read<HabitDatabase>().updateHabitCompletion(habit.id, value);
    }
  }

  void editHabitBox(Habit habit) {
    myController.text = habit.name;

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                controller: myController,
              ),
              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    myController.clear();
                  },
                  child: const Text('Cancel'),
                ),
                MaterialButton(
                  onPressed: () {
                    context
                        .read<HabitDatabase>()
                        .updateHabitName(habit.id, myController.text);
                    myController.clear();
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                )
              ],
            ));
  }

  void deleteHabit(Habit habit) {
    context.read<HabitDatabase>().deleteHabit(habit.id);
  }

  // prepare heatmap dataset
  Map<DateTime, int> prepHeatMapDataset(List<Habit> habits) {
    Map<DateTime, int> dataset = {};

    for (var habit in habits) {
      for (var date in habit.completedDays) {
        // normalize date to avoid time mismatch
        final normalizedDate = DateTime(date.year, date.month, date.day);

        // if the date already exists in the dataset, increment its count
        if (dataset.containsKey(normalizedDate)) {
          dataset[normalizedDate] = dataset[normalizedDate]! + 1;
        } else {
          // else initialize it with a count of 1
          dataset[normalizedDate] = 1;
        }
      }
    }

    return dataset;
  }

  void createNewHabit() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                controller: myController,
              ),
              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    myController.clear();
                  },
                  child: const Text('Cancel'),
                ),
                MaterialButton(
                  onPressed: () {
                    context.read<HabitDatabase>().addHabit(myController.text);
                    myController.clear();
                    Navigator.pop(context);
                  },
                  child: const Text('Create'),
                )
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    final habitDatabase = context.watch<HabitDatabase>();
    List<Habit> currenthabits = habitDatabase.currentHabits;
    return Scaffold(
        appBar: AppBar(),
        drawer: const MyDrawer(),
        floatingActionButton: FloatingActionButton(
          onPressed: createNewHabit,
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          shape: const CircleBorder(),
          child: Icon(
            Icons.add,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        body: ListView(
          children: [
            FutureBuilder(
                future: habitDatabase.getFirstLaunchDate(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return MyHeatMap(
                        startDate: snapshot.data!,
                        datasets: prepHeatMapDataset(currenthabits));
                  } else {
                    return Container();
                  }
                }),
            ListView.builder(
                itemCount: currenthabits.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final habit = currenthabits[index];

                  // checking if the habit is completed today or not
                  bool isCompletedToday =
                      isHabitCompletedToday(habit.completedDays);

                  return MyHabitTile(
                    isCompleted: isCompletedToday,
                    text: habit.name,
                    onChanged: (value) => checkHabitOnOff(value, habit),
                    editHabit: (context) => editHabitBox(habit),
                    deleteHabit: (context) => deleteHabit(habit),
                  );
                }),
          ],
        ));
  }
}
