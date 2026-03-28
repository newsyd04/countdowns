/// Application-wide constants.
class AppConstants {
  AppConstants._();

  static const String appName = 'Countdowns';
  static const String hiveBoxName = 'countdowns_box';
  static const String hiveSettingsBoxName = 'settings_box';

  // Animation durations (milliseconds)
  static const int animationFast = 200;
  static const int animationNormal = 350;
  static const int animationSlow = 500;
  static const int animationSpring = 600;

  // Default notification offsets (minutes before event)
  static const List<int> defaultNotificationOffsets = [
    0, // At the time
    1440, // 1 day before
  ];

  // Max items before we suggest archiving
  static const int maxVisibleCountdowns = 50;

  // Emoji defaults
  static const String defaultEmoji = '\u{1F389}'; // Party popper
  static const List<String> suggestedEmojis = [
    '\u{1F389}', // Party popper
    '\u{1F382}', // Birthday cake
    '\u{2708}\u{FE0F}', // Airplane
    '\u{1F3D6}\u{FE0F}', // Beach
    '\u{1F393}', // Graduation cap
    '\u{1F48D}', // Ring
    '\u{1F3C6}', // Trophy
    '\u{2B50}', // Star
    '\u{1F381}', // Gift
    '\u{1F3B5}', // Music note
    '\u{2764}\u{FE0F}', // Heart
    '\u{1F680}', // Rocket
    '\u{1F384}', // Christmas tree
    '\u{1F31F}', // Glowing star
    '\u{1F37E}', // Champagne
    '\u{1F4DA}', // Books
    '\u{1F3E0}', // House
    '\u{1F451}', // Crown
    '\u{1F308}', // Rainbow
    '\u{1F525}', // Fire
    '\u{26BD}', // Soccer ball
    '\u{1F3AE}', // Game controller
    '\u{1F4BC}', // Briefcase
    '\u{1F6E9}\u{FE0F}', // Small airplane
    '\u{1F30E}', // Globe
    '\u{1F436}', // Dog face
    '\u{1F431}', // Cat face
    '\u{1F33B}', // Sunflower
    '\u{2600}\u{FE0F}', // Sun
    '\u{2744}\u{FE0F}', // Snowflake
  ];
}
