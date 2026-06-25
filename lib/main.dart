import 'src/app.dart';
import 'src/core/imports/core_imports.dart';
import 'src/core/imports/packages_imports.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: '.env');
  
  await AppConfig.init();
  await HiveService.instance.init();

  runApp(
    const StateWrapper(
      child: App(),
    ),
  );
}