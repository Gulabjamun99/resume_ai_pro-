// lib/theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bg = Color(0xFF0D0D0D);
  static const bg2 = Color(0xFF161616);
  static const bg3 = Color(0xFF1E1E1E);
  static const bg4 = Color(0xFF252525);
  static const border = Color(0xFF2C2C2C);
  static const border2 = Color(0xFF383838);
  static const text = Color(0xFFEFEFEF);
  static const text2 = Color(0xFF999999);
  static const text3 = Color(0xFF555555);
  static const accent = Color(0xFFC8F542);
  static const accent2 = Color(0xFFB2DC2E);
  static const green = Color(0xFF3ECF8E);
  static const red = Color(0xFFF56565);
  static const gold = Color(0xFFF6C90E);
  static const blue = Color(0xFF60A5FA);
}

ThemeData appTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      surface: AppColors.bg2,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg2,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: AppColors.text,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: AppColors.text),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bg3,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border2),
      ),
      labelStyle: const TextStyle(color: AppColors.text3, fontSize: 12),
      hintStyle: const TextStyle(color: AppColors.text3, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    dividerColor: AppColors.border,
  );
}

// Common widgets
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? borderColor;
  final Color? color;
  const AppCard({super.key, required this.child, this.padding, this.borderColor, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? AppColors.bg2,
        border: Border.all(color: borderColor ?? AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String icon, title;
  const SectionTitle({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
      ]),
    );
  }
}

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label, hint;
  final bool required, multiline;
  final TextInputType? keyboardType;
  const AppTextField({
    super.key, required this.controller, required this.label,
    required this.hint, this.required=false, this.multiline=false, this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      RichText(text: TextSpan(
        text: label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.text3, letterSpacing: 0.5),
        children: required ? [const TextSpan(text: ' *', style: TextStyle(color: AppColors.accent))] : [],
      )),
      const SizedBox(height: 5),
      TextFormField(
        controller: controller,
        keyboardType: keyboardType ?? (multiline ? TextInputType.multiline : TextInputType.text),
        maxLines: multiline ? null : 1,
        minLines: multiline ? 3 : 1,
        style: const TextStyle(color: AppColors.text, fontSize: 13),
        decoration: InputDecoration(hintText: hint),
      ),
    ]);
  }
}

class AccentBadge extends StatelessWidget {
  final String text;
  final Color? color, bg;
  const AccentBadge(this.text, {super.key, this.color, this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg ?? AppColors.accent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: (color ?? AppColors.accent).withOpacity(0.3)),
      ),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color ?? AppColors.accent)),
    );
  }
}
