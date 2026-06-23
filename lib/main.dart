import 'src/app.dart';
import 'src/core/imports/core_imports.dart';
import 'src/core/imports/packages_imports.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  
  await dotenv.load(fileName: '.env');
  
  await AppConfig.init();
  await HiveService.instance.init();

  runApp(
    const StateWrapper(
      child: App(),
    ),
  );
}