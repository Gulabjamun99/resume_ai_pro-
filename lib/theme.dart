// lib/theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bg = Color(0xFF07090E);          // Deep Space Dark
  static const bg2 = Color(0xFF101420);         // Glass Card Base
  static const bg3 = Color(0xFF171C2E);         // Elevated Card Surface
  static const bg4 = Color(0xFF20263C);         // Active Element Background
  static const border = Color(0xFF242C44);      // Subtle Glass Border
  static const border2 = Color(0xFF3B476C);     // Glowing Border Accent
  static const text = Color(0xFFF8FAFC);        // Crisp White
  static const text2 = Color(0xFF94A3B8);       // Cool Gray Subtext
  static const text3 = Color(0xFF64748B);       // Muted Label
  static const accent = Color(0xFF10B981);      // Electric Emerald
  static const accent2 = Color(0xFF34D399);     // Emerald Glow
  static const green = Color(0xFF10B981);       // Emerald Green Alias
  static const red = Color(0xFFEF4444);         // Warning Red
  static const gold = Color(0xFFF59E0B);        // ATS Gold Accent
  static const blue = Color(0xFF3B82F6);        // Royal Blue
  static const cyan = Color(0xFF06B6D4);        // Quantum Cyan
  static const purple = Color(0xFF8B5CF6);      // Cyber Purple
}

ThemeData appTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      surface: AppColors.bg2,
      secondary: AppColors.purple,
    ),
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg2,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.text,
        fontSize: 17,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.3,
      ),
      iconTheme: IconThemeData(color: AppColors.text),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bg3,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      labelStyle: const TextStyle(color: AppColors.text2, fontSize: 12.5),
      hintStyle: const TextStyle(color: AppColors.text3, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.2),
        elevation: 6,
        shadowColor: AppColors.accent.withValues(alpha: 0.35),
      ),
    ),
    dividerColor: AppColors.border,
  );
}

// Premium Glassmorphic Cards & Common UI Components
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? borderColor;
  final Color? color;
  final Gradient? gradient;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.borderColor,
    this.color,
    this.gradient,
    this.borderRadius = 16.0,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color ?? AppColors.bg2,
        gradient: gradient,
        border: Border.all(color: borderColor ?? AppColors.border, width: 1.2),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String icon, title;
  final String? subtitle;
  const SectionTitle({super.key, required this.icon, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
            ),
            child: Text(icon, style: const TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.text, letterSpacing: -0.2)),
              if (subtitle != null)
                Text(subtitle!, style: const TextStyle(fontSize: 11, color: AppColors.text2)),
            ],
          ),
        ],
      ),
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
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text2, letterSpacing: 0.3),
        children: required ? [const TextSpan(text: ' *', style: TextStyle(color: AppColors.accent))] : [],
      )),
      const SizedBox(height: 6),
      TextFormField(
        controller: controller,
        keyboardType: keyboardType ?? (multiline ? TextInputType.multiline : TextInputType.text),
        maxLines: multiline ? null : 1,
        minLines: multiline ? 3 : 1,
        style: const TextStyle(color: AppColors.text, fontSize: 13.5),
        decoration: InputDecoration(hintText: hint),
      ),
    ]);
  }
}

class AccentBadge extends StatelessWidget {
  final String text;
  final Color? color, bg;
  final IconData? icon;
  const AccentBadge(this.text, {super.key, this.color, this.bg, this.icon});

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? AppColors.accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg ?? textColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withValues(alpha: 0.35), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(text, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: textColor)),
        ],
      ),
    );
  }
}
