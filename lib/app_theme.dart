import 'package:flutter/material.dart';

/// 🎨 YKS Cepte - Dinamik Tema Sistemi
/// 
/// Görsel Ödüllendirme (Visual Gratification):
/// - FREE: Kütüphane Modu (Sakin & Odaklı) 🌿
/// - PRO: Turbo Modu (Enerjik & Premium) 🚀
class AppThemes {
  
  // ═══════════════════════════════════════════════════════════════
  // 🌿 FREE KULLANICI TEMASI - "Kütüphane Modu"
  // Amaç: Göz yormasın, sakinleştirsin, odaklanmayı desteklesin
  // ═══════════════════════════════════════════════════════════════
  
  // FREE Tema Renkleri
  static const Color freePrimary = Color(0xFF5C9EAD);      // Adaçayı Yeşili
  static const Color freeBackground = Color(0xFFF4F6F2);   // Kırık Beyaz
  static const Color freeAccent = Color(0xFF88D8B0);       // Pastel Yeşil
  static const Color freeText = Color(0xFF2D3E40);         // Koyu Gri-Yeşil
  static const Color freeTextSecondary = Color(0xFF4A5A5C);

  static final ThemeData freeTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: freePrimary,
    scaffoldBackgroundColor: freeBackground,
    
    colorScheme: ColorScheme.light(
      primary: freePrimary,
      secondary: freeAccent,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: freeText,
    ),
    
    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: freePrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    
    // Kartlar
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 2,
      shadowColor: freePrimary.withAlpha(30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    // Yazılar
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: freeText, fontWeight: FontWeight.bold, fontSize: 28),
      titleLarge: TextStyle(color: freeText, fontWeight: FontWeight.bold, fontSize: 20),
      titleMedium: TextStyle(color: freeText, fontWeight: FontWeight.w600, fontSize: 16),
      bodyLarge: TextStyle(color: freeText, fontSize: 16),
      bodyMedium: TextStyle(color: freeTextSecondary, fontSize: 14),
      bodySmall: TextStyle(color: freeTextSecondary, fontSize: 12),
    ),

    // Butonlar
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: freePrimary,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: freePrimary,
        side: const BorderSide(color: freePrimary),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    
    // Bottom Navigation
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: freePrimary.withAlpha(40),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    ),
    
    // Input Fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: freePrimary.withAlpha(50)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: freePrimary.withAlpha(50)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: freePrimary, width: 2),
      ),
    ),
    
    // Icons
    iconTheme: const IconThemeData(color: freePrimary),
    
    // FAB
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: freePrimary,
      foregroundColor: Colors.white,
    ),
  );

  // ═══════════════════════════════════════════════════════════════
  // 🚀 PRO KULLANICI TEMASI - "Turbo Modu"
  // Amaç: Heyecanlandırsın, motive etsin, premium hissettirsin
  // ═══════════════════════════════════════════════════════════════
  
  // PRO Tema Renkleri
  static const Color proPrimary = Color(0xFF6C63FF);       // Derin Mor
  static const Color proAccent = Color(0xFFFF6584);        // Elektrik Turuncusu
  static const Color proBackground = Color(0xFFFAFAFA);    // Tertemiz Beyaz
  static const Color proText = Color(0xFF1A1A2E);          // Koyu Lacivert
  static const Color proTextSecondary = Color(0xFF4A4A6A);
  static const Color proGradientStart = Color(0xFF6C63FF);
  static const Color proGradientEnd = Color(0xFF9D4EDD);

  static final ThemeData proTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: proPrimary,
    scaffoldBackgroundColor: proBackground,
    
    colorScheme: ColorScheme.light(
      primary: proPrimary,
      secondary: proAccent,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: proText,
    ),
    
    // AppBar - Daha modern
    appBarTheme: const AppBarTheme(
      backgroundColor: proPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    
    // Kartlar - Premium gölgeler
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 8,
      shadowColor: proPrimary.withAlpha(50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    // Yazılar - Daha keskin
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: proText, fontWeight: FontWeight.w900, fontSize: 28),
      titleLarge: TextStyle(color: proText, fontWeight: FontWeight.w900, fontSize: 20),
      titleMedium: TextStyle(color: proText, fontWeight: FontWeight.w700, fontSize: 16),
      bodyLarge: TextStyle(color: proText, fontSize: 16),
      bodyMedium: TextStyle(color: proTextSecondary, fontSize: 14),
      bodySmall: TextStyle(color: proTextSecondary, fontSize: 12),
    ),

    // Butonlar - Daha yuvarlak ve cesur
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: proPrimary,
        foregroundColor: Colors.white,
        elevation: 5,
        shadowColor: proPrimary.withAlpha(100),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: proPrimary,
        side: const BorderSide(color: proPrimary, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    ),
    
    // Bottom Navigation - Mor vurgulu
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: proPrimary.withAlpha(50),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    ),
    
    // Input Fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: proPrimary.withAlpha(50)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: proPrimary.withAlpha(50)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: proPrimary, width: 2),
      ),
    ),
    
    // Icons - Mor
    iconTheme: const IconThemeData(color: proPrimary),
    
    // FAB - Turuncu patlama efekti
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: proAccent,
      foregroundColor: Colors.white,
    ),
  );

  // ═══════════════════════════════════════════════════════════════
  // 🌙 PRO DARK TEMASI (Bonus - Gece Modu)
  // ═══════════════════════════════════════════════════════════════
  
  static const Color proDarkBg = Color(0xFF0D1117);
  static const Color proDarkSurface = Color(0xFF161B22);
  
  static final ThemeData proDarkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: proPrimary,
    scaffoldBackgroundColor: proDarkBg,
    
    colorScheme: ColorScheme.dark(
      primary: proPrimary,
      secondary: proAccent,
      surface: proDarkSurface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
    ),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: proDarkSurface,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    
    cardTheme: CardTheme(
      color: proDarkSurface,
      elevation: 8,
      shadowColor: proPrimary.withAlpha(30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
      titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: proPrimary,
        foregroundColor: Colors.white,
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    ),
    
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: proDarkSurface,
      indicatorColor: proPrimary.withAlpha(50),
    ),
    
    iconTheme: const IconThemeData(color: proPrimary),
    
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: proAccent,
      foregroundColor: Colors.white,
    ),
  );

  // ═══════════════════════════════════════════════════════════════
  // 🔧 YARDIMCI METODLAR
  // ═══════════════════════════════════════════════════════════════
  
  /// Gradient arka plan için (Pro tema)
  static BoxDecoration get proGradientBackground => const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [proGradientStart, proGradientEnd],
    ),
  );
  
  /// Hero kart gradient'i
  static BoxDecoration heroCardDecoration(bool isPro) => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isPro 
          ? [proGradientStart, proGradientEnd]
          : [freePrimary, freeAccent],
    ),
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: (isPro ? proPrimary : freePrimary).withAlpha(60),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  );
  
  /// Temaya göre doğru tema döndür
  static ThemeData getTheme({required bool isPro, bool isDark = false}) {
    if (isPro) {
      return isDark ? proDarkTheme : proTheme;
    }
    return freeTheme;
  }
}
