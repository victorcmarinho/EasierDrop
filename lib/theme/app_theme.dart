import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

class AppTheme {
  const AppTheme._();

  static const _sfProDisplay = '.SF Pro Display';
  static const _sfProText = '.SF Pro Text';

  static MacosTypography get _typography {
    const color = MacosColors.labelColor;
    return MacosTypography(
      color: color,
      body: const TextStyle(fontFamily: _sfProText, fontSize: 13, color: color),
      headline: const TextStyle(
        fontFamily: _sfProDisplay,
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      subheadline: const TextStyle(
        fontFamily: _sfProText,
        fontSize: 11,
        color: MacosColors.secondaryLabelColor,
      ),
      largeTitle: const TextStyle(
        fontFamily: _sfProDisplay,
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      title1: const TextStyle(
        fontFamily: _sfProDisplay,
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      title2: const TextStyle(
        fontFamily: _sfProDisplay,
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      title3: const TextStyle(
        fontFamily: _sfProDisplay,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      caption1: const TextStyle(
        fontFamily: _sfProText,
        fontSize: 10,
        color: MacosColors.secondaryLabelColor,
      ),
      caption2: const TextStyle(
        fontFamily: _sfProText,
        fontSize: 10,
        color: MacosColors.secondaryLabelColor,
      ),
      callout: const TextStyle(
        fontFamily: _sfProText,
        fontSize: 12,
        color: color,
      ),
      footnote: const TextStyle(
        fontFamily: _sfProText,
        fontSize: 10,
        color: color,
      ),
    );
  }

  static MacosTypography get _darkTypography {
    // Create a dark version by applying white color
    const color = MacosColors.white;
    return MacosTypography(
      color: color,
      body: const TextStyle(fontFamily: _sfProText, fontSize: 13, color: color),
      headline: const TextStyle(
        fontFamily: _sfProDisplay,
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      subheadline: const TextStyle(
        fontFamily: _sfProText,
        fontSize: 11,
        color: MacosColors.secondaryLabelColor,
      ),
      largeTitle: const TextStyle(
        fontFamily: _sfProDisplay,
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      title1: const TextStyle(
        fontFamily: _sfProDisplay,
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      title2: const TextStyle(
        fontFamily: _sfProDisplay,
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      title3: const TextStyle(
        fontFamily: _sfProDisplay,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      caption1: const TextStyle(
        fontFamily: _sfProText,
        fontSize: 10,
        color: MacosColors.secondaryLabelColor,
      ),
      caption2: const TextStyle(
        fontFamily: _sfProText,
        fontSize: 10,
        color: MacosColors.secondaryLabelColor,
      ),
      callout: const TextStyle(
        fontFamily: _sfProText,
        fontSize: 12,
        color: color,
      ),
      footnote: const TextStyle(
        fontFamily: _sfProText,
        fontSize: 10,
        color: color,
      ),
    );
  }

  static MacosThemeData get light =>
      MacosThemeData.light().copyWith(typography: _typography);

  static MacosThemeData get dark =>
      MacosThemeData.dark().copyWith(typography: _darkTypography);

  /// Returns a CupertinoThemeData adapted for macOS desktop sizing (13pt body).
  static CupertinoThemeData getCupertinoTheme(BuildContext context) {
    final macos = MacosTheme.of(context);
    final isDark = macos.brightness == Brightness.dark;
    final textColor = isDark ? MacosColors.white : MacosColors.black;

    return CupertinoThemeData(
      brightness: macos.brightness,
      primaryColor: macos.primaryColor,
      scaffoldBackgroundColor: macos.canvasColor,
      barBackgroundColor: macos.canvasColor,
      textTheme: CupertinoTextThemeData(
        textStyle: TextStyle(
          fontFamily: _sfProText,
          fontSize: 13,
          color: textColor,
        ),
        actionTextStyle: TextStyle(
          fontFamily: _sfProText,
          fontSize: 13,
          color: macos.primaryColor,
        ),
        tabLabelTextStyle: const TextStyle(
          fontFamily: _sfProText,
          fontSize: 10,
        ),
        navTitleTextStyle: TextStyle(
          fontFamily: _sfProDisplay,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        dateTimePickerTextStyle: TextStyle(
          fontFamily: _sfProDisplay,
          fontSize: 13,
          color: textColor,
        ),
      ),
    );
  }
}
