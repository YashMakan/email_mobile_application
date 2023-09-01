import 'package:hive_flutter/hive_flutter.dart';
import 'local_db_routes.dart';

class LocalDB {
  static Future<void> initialize() async {
    await Hive.initFlutter();
    await Future.wait(LocalDBRoutes.routes.map((e) => Hive.openBox(e)));
  }

  static String? get email => Hive.box(LocalDBRoutes.userRoute).get('email');

  static String? get name => Hive.box(LocalDBRoutes.userRoute).get('name');

  static String? get photo => Hive.box(LocalDBRoutes.userRoute).get('photo');


  static void setEmail(String email) =>
      Hive.box(LocalDBRoutes.userRoute).put('email', email);

  static void setName(String name) =>
      Hive.box(LocalDBRoutes.userRoute).put('name', name);

  static void setPhoto(String photo) =>
      Hive.box(LocalDBRoutes.userRoute).put('photo', photo);
}
