import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color primary = Color(0xFF064E3B);
  static const Color onPrimary = Color(0xFFFCFCF5);
  static const Color primaryContainer = Color(0xFF064E3B);
  static const Color onPrimaryContainer = Color(0xFF80BEA6);
  static const Color primaryFixed = Color(0xFFB0F0D6);
  static const Color primaryFixedDim = Color(0xFF95D3BA);

  static const Color secondary = Color(0xFF006591);
  static const Color onSecondary = Color(0xFFFCFCF5);
  static const Color secondaryContainer = Color(0xFFE5F6FF);
  static const Color onSecondaryContainer = Color(0xFF004666);

  static const Color tertiary = Color(0xFF273034);
  static const Color tertiaryContainer = Color(0xFFDEE4E8);

  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);

  static const Color surface = Color(0xFFF7FAF4);
  static const Color onSurface = Color(0xFF141C12);
  static const Color onSurfaceVariant = Color(0xFF3E4839);
  static const Color outline = Color(0xFF6F7A69);
  static const Color outlineVariant = Color(0xFFBEC8B7);
  static const Color inverseSurface = Color(0xFF213145);
  static const Color inversePrimary = Color(0xFF95D3BA);

  static const Color surfaceDim = Color(0xFFD2E1D0);
  static const Color surfaceBright = Color(0xFFF7FAF4);
  static const Color surfaceContainerLow = Color(0xFFEEF3E9);
  static const Color surfaceContainer = Color(0xFFE5ECE0);
  static const Color surfaceContainerHigh = Color(0xFFDCE5D6);
  static const Color surfaceContainerHighest = Color(0xFFD2DECC);

  static const Color darkSurface = Color(0xFF0F1A14);
  static const Color darkOnSurface = Color(0xFFE0E6DC);
  static const Color darkOnSurfaceVariant = Color(0xFFBEC8B7);
  static const Color darkSurfaceContainerLow = Color(0xFF1A261E);
  static const Color darkSurfaceContainer = Color(0xFF1F2C23);
  static const Color darkSurfaceContainerHigh = Color(0xFF29382E);
  static const Color darkSurfaceContainerHighest = Color(0xFF34443A);
  static const Color darkOutline = Color(0xFF88947F);
  static const Color darkOutlineVariant = Color(0xFF3E4839);

  static const Color chartFajr = Color(0xFFD4A843);
  static const Color chartDhuhr = Color(0xFF5B8C5A);
  static const Color chartAsr = Color(0xFFC4674B);
  static const Color chartMaghrib = Color(0xFF8B6B4D);
  static const Color chartIsha = Color(0xFF4A6FA5);

  static Color prayerColor(int index) {
    return [chartFajr, chartDhuhr, chartAsr, chartMaghrib, chartIsha][index % 5];
  }

  static const double radiusSm = 6;
  static const double radiusMd = 10;
  static const double radiusLg = 16;
  static const double radiusXl = 24;

  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 12;
  static const double spaceLg = 16;
  static const double spaceXl = 24;
  static const double spaceXxl = 32;
  static const double spaceXxxl = 48;
  static const double spaceXxxxl = 64;

  static const Duration durationFast = Duration(milliseconds: 200);
  static const Duration durationBase = Duration(milliseconds: 350);
  static const Duration durationSlow = Duration(milliseconds: 600);

  static const Curve springOut = Curves.easeOutBack;
  static const Curve smoothEase = Curves.easeInOutCubic;

  static const Color chartFajrDark = Color(0xFFE8C76A);
  static const Color chartDhuhrDark = Color(0xFF7EB07D);
  static const Color chartAsrDark = Color(0xFFD4896F);
  static const Color chartMaghribDark = Color(0xFFA68B6A);
  static const Color chartIshaDark = Color(0xFF6E93C9);

  static Color prayerColorDark(int index) {
    return [chartFajrDark, chartDhuhrDark, chartAsrDark, chartMaghribDark, chartIshaDark][index % 5];
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondary,
        onSecondary: onSecondary,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,
        tertiary: tertiary,
        tertiaryContainer: tertiaryContainer,
        error: error,
        errorContainer: errorContainer,
        surface: surface,
        onSurface: onSurface,
        surfaceContainerLow: surfaceContainerLow,
        surfaceContainer: surfaceContainer,
        surfaceContainerHigh: surfaceContainerHigh,
        surfaceContainerHighest: surfaceContainerHighest,
        outline: outline,
        outlineVariant: outlineVariant,
        inverseSurface: inverseSurface,
        inversePrimary: inversePrimary,
      ),
      scaffoldBackgroundColor: surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: onSurface,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: surfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withValues(alpha: 0.12),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: primary,
              letterSpacing: 0.3,
            );
          }
          return const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primary, size: 22);
          }
          return const IconThemeData(color: onSurfaceVariant, size: 22);
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: spaceXl,
            vertical: spaceMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spaceLg, vertical: spaceMd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 14,
          color: onSurfaceVariant,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondary: Color(0xFF7FC3EC),
        onSecondary: Color(0xFF00344D),
        secondaryContainer: Color(0xFF004D6E),
        onSecondaryContainer: Color(0xFFC8E6FF),
        tertiary: Color(0xFFD5E2E7),
        tertiaryContainer: Color(0xFF3D484C),
        error: Color(0xFFFFB4AB),
        errorContainer: Color(0xFF93000A),
        surface: darkSurface,
        onSurface: darkOnSurface,
        surfaceContainerLow: darkSurfaceContainerLow,
        surfaceContainer: darkSurfaceContainer,
        surfaceContainerHigh: darkSurfaceContainerHigh,
        surfaceContainerHighest: darkSurfaceContainerHighest,
        outline: darkOutline,
        outlineVariant: darkOutlineVariant,
        inverseSurface: surfaceBright,
        inversePrimary: primary,
      ),
      scaffoldBackgroundColor: darkSurface,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: darkOnSurface,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: darkSurfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkSurface,
        indicatorColor: primary.withValues(alpha: 0.2),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: primary,
              letterSpacing: 0.3,
            );
          }
          return const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: darkOnSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primary, size: 22);
          }
          return const IconThemeData(color: darkOnSurfaceVariant, size: 22);
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: spaceXl,
            vertical: spaceMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceContainer,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spaceLg, vertical: spaceMd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: darkOutlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: darkOutlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 14,
          color: darkOnSurfaceVariant,
        ),
      ),
    );
  }
}

class Spring {
  static const standard = SpringDescription(
    mass: 1, stiffness: 200, damping: 20,
  );

  static const snappy = SpringDescription(
    mass: 1, stiffness: 300, damping: 25,
  );

  static const gentle = SpringDescription(
    mass: 1, stiffness: 150, damping: 18,
  );
}
