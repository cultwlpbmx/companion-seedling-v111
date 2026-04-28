import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/local_data_service.dart';
import 'services/user_profile_service.dart';
import 'screens/splash_screen.dart';
import 'themes/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  // 初始化本地数据服务（自动创建匿名用户）
  await LocalDataService().initialize();
  // 初始化用户画像服务
  await UserProfileService().initialize();

  runApp(
    const ProviderScope(
      child: CompanionSeedlingApp(),
    ),
  );
}

class CompanionSeedlingApp extends StatelessWidget {
  const CompanionSeedlingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '陪伴小树苗',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
