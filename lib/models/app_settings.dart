import 'package:isar/isar.dart';

// we'll have to run a cmd command to generate this file : dart run build_runner build
part 'app_settings.g.dart';

@Collection()
class AppSettings {
  Id id = Isar.autoIncrement;
  DateTime? firstLaunchDate;
}
