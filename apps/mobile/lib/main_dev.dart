import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/gallery/ui/screen_gallery_screen.dart';

void main() {
  runApp(const DietPlannerDevApp());
}

class DietPlannerDevApp extends StatefulWidget {
  const DietPlannerDevApp({super.key});

  @override
  State<DietPlannerDevApp> createState() => _DietPlannerDevAppState();
}

class _DietPlannerDevAppState extends State<DietPlannerDevApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diet Planner (Dev Gallery)',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      home: Builder(
        builder: (ctx) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Diet Planner · Dev Gallery'),
              actions: [
                IconButton(
                  tooltip: 'Toggle Light / Dark',
                  icon: Icon(_themeMode == ThemeMode.light ? Icons.dark_mode : Icons.light_mode),
                  onPressed: _toggleTheme,
                ),
              ],
            ),
            body: const ScreenGalleryScreen(),
          );
        },
      ),
    );
  }
}
