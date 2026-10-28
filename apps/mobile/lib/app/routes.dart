/// Route constants for the mobile application.
/// Used by GoRouter and UI navigation across all lanes.
abstract class AppRoutes {
  static const String initial = '/';
  
  // Onboarding
  static const String onboarding = '/onboarding';
  
  // Core Tabs
  static const String today = '/today';
  static const String foods = '/foods';
  static const String progress = '/progress';
  static const String more = '/more';
  
  // Meal Detail & Logging
  static const String mealDetail = '/meal/:mealId';
  static const String portionPicker = '/portion-picker';
  static const String quickAdd = '/log/quick-add';
  static const String replaceDish = '/meal/:mealId/replace';
  
  // Features
  static const String foodDetail = '/foods/:foodId';
  static const String history = '/history';
  static const String shopping = '/shopping';
  static const String reminders = '/reminders';
  
  // Settings & Transparency
  static const String settings = '/settings';
  static const String privacy = '/settings/privacy';
  static const String transparency = '/transparency';
  static const String gentleCheckIn = '/check-in';
  
  // Dev-only Screen Gallery
  static const String gallery = '/gallery';

  // Helper methods to construct parameterized routes
  static String mealDetailPath(String mealId) => '/meal/$mealId';
  static String foodDetailPath(String foodId) => '/foods/$foodId';
  static String replaceDishPath(String mealId) => '/meal/$mealId/replace';
}
