import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  const AppTheme();
  static ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    backgroundColor: AppColors.background,
    primaryColor: AppColors.purple,
    accentColor: AppColors.lightblack,
    primaryColorDark: AppColors.white,
    primaryColorLight: AppColors.brighter,
    cardTheme: CardTheme(color: AppColors.background),
    textTheme: TextTheme(display1: TextStyle(color: AppColors.black)),
    iconTheme: IconThemeData(color: AppColors.lightblack),
    bottomAppBarColor: AppColors.background,
    dividerColor: AppColors.lightGrey,
    colorScheme: ColorScheme(
        primary: AppColors.purple,
        primaryVariant: AppColors.purple,
        secondary: AppColors.lightBlue,
        secondaryVariant: AppColors.darkBlue,
        surface: AppColors.background,
        background: AppColors.background,
        error: Colors.red,
        onPrimary: AppColors.white,
        onSecondary: AppColors.background,
        onSurface: AppColors.white,
        onBackground: AppColors.titleTextColor,
        onError: AppColors.titleTextColor,
        brightness: Brightness.dark),
  );

  static TextStyle titleStyle =
  const TextStyle(color: AppColors.titleTextColor, fontSize: 16);
  static TextStyle subTitleStyle =
  const TextStyle(color: AppColors.subTitleTextColor, fontSize: 12);

  static TextStyle h1Style =
  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
  static TextStyle h2Style = const TextStyle(fontSize: 22);
  static TextStyle h3Style = const TextStyle(fontSize: 20);
  static TextStyle h4Style = const TextStyle(fontSize: 18);
  static TextStyle h5Style = const TextStyle(fontSize: 16);
  static TextStyle h6Style = const TextStyle(fontSize: 14);
}