import 'package:isar/isar.dart';

// we'll have to run a cmd command to generate this file : dart run build_runner build
part 'habit.g.dart';

@Collection()
class Habit {
  Id id = Isar.autoIncrement;
  late String name;
  List<DateTime> completedDays = [
    // DateTime(year,month,day),
    // DateTime(year,month,day),
  ];
}
