import 'package:flutter/material.dart';

class C {
  static const accent = Color(0xFF0EC5E8); // Lagoon aqua - the only brand colour
  static const accentDeep = Color(0xFF0A9DBA);
  static const accentSoft = Color(0xFFE3F8FC);
  static const ink = Color(0xFF0B0D12); // near-black
  static const inkSoft = Color(0xFF5B6270);
  static const line = Color(0xFFEDEFF3);
  static const card = Color(0xFFF6F7F9);
  static const bg = Colors.white;
  static const empty = Color(0xFFE9ECF1); // empty character silhouette
  static const coral = Color(0xFFFF8A65);
  static const danger = Color(0xFFE5484D);
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: C.accent,
      primary: C.accent,
      surface: Colors.white,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: C.bg,
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(bodyColor: C.ink, displayColor: C.ink),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      foregroundColor: C.ink,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(color: C.ink, fontSize: 20, fontWeight: FontWeight.w700),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) => Colors.white),
      trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? C.accent : const Color(0xFFD5D9E0)),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      showDragHandle: true,
    ),
    dialogTheme: const DialogThemeData(backgroundColor: Colors.white, surfaceTintColor: Colors.white),
  );
}
