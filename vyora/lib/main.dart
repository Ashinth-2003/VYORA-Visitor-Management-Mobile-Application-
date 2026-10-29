import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/theme_controller.dart';
import 'controllers/visitor_controller.dart';
import 'services/api_service.dart';
import 'theme/app_theme.dart';
import 'views/landing_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeController = await ThemeController.create();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeController),
        ChangeNotifierProvider(
          create: (_) => VisitorController(ApiService())..loadVisitors(),
        ),
      ],
      child: const VyoraApp(),
    ),
  );
}

class VyoraApp extends StatelessWidget {
  const VyoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VYORA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: context.watch<ThemeController>().mode,
      home: const LandingScreen(),
    );
  }
}
