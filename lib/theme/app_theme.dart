import 'package:flutter/material.dart';

/// Central place for brand colors, text styles, and the app's ThemeData.
/// Update values here and they apply everywhere.
class AppColors {
  static const Color primary = Color(0xFF5D94E8);
  static const Color white = Colors.white;
  static const Color background = Colors.white;
  static const Color textDark = Color(0xFF1E1E1E);
  static const Color textMuted = Color(0xFF7A7A7A);
  static const Color error = Color(0xFFE85D5D);
}

/// Named gradient presets. Add new ones here rather than writing
/// LinearGradient(...) inline wherever you need one.
class AppGradients {
  // Main brand gradient — buttons, headers, splash background accents.
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5D94E8), Color(0xFF3E6FC4)],
  );

  // Light wash version — card backgrounds, subtle section highlights.
  static const LinearGradient subtleBg = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), Color(0xFFE3EDFF), Color(0xFFFFFFFF)],
  );

  // Optional darker variant — headers/hero sections that need more contrast.
  static const LinearGradient deep = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3E6FC4), Color(0xFF223A63)],
  );

  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), Color(0xFFAFCEFF), Color(0xFFFFFFFF)]
  );

  static const LinearGradient logotypeGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF5D94E8), Color(0xFF203264)],
  );
}

/// Standard icon sizes. Pick one of these instead of a raw number so
/// icons stay consistent across pages.
class AppIconSizes {
  static const double small = 18;
  static const double medium = 24;
  static const double large = 36;
  static const double xlarge = 64;
}

class AppTextStyles {
  // Headings use Prompt
  static const String headingFont = 'Prompt';
  // Body copy uses Radio Canada
  static const String bodyFont = 'RadioCanada';

  static const TextStyle herotitle = TextStyle(
    fontFamily: headingFont,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  static const TextStyle heading1 = TextStyle(
    fontFamily: headingFont,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: headingFont,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  static const TextStyle body = TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textDark,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontFamily: bodyFont,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  static const TextStyle button = TextStyle(
    fontFamily: headingFont,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: bodyFont,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  static const TextStyle link = TextStyle(
    fontFamily: bodyFont,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
      ),
      fontFamily: AppTextStyles.bodyFont,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF3F6FC),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
