
import 'package:flutter/material.dart';

class AppColors{


  static ThemeData themeData(bool isDarkTheme, BuildContext context) {
    return ThemeData(
        accentColor:Color(0xFFa50044) ,
      primarySwatch: Colors.grey,
      primaryColor: isDarkTheme ? Colors.black : Colors.white,
      primaryColorBrightness:isDarkTheme ? Brightness.light: Brightness.dark,
      backgroundColor: isDarkTheme ? Color(0xFF1a1a2e) : Color(0xfff8f8f8),
      scaffoldBackgroundColor: isDarkTheme ? Color(0xFF191b20) : Color(0xffe6ecf0),

      indicatorColor: isDarkTheme ? Color(0xff0E1D36) : Color(0xffCBDCF8),
      buttonColor: isDarkTheme ? Color(0xff3B3B3B) : Color(0xffF1F5FB),

      hintColor: isDarkTheme ? Color(0xff280C0B) : Color(0xff4285F4),

      hoverColor: isDarkTheme ? Color(0xff3A3A3B) : Color(0xff4285F4),

      focusColor: isDarkTheme ? Color(0xff0B2512) : Color(0xffA8DAB5),
      disabledColor: Colors.grey,
      cardColor: isDarkTheme ? Color(0xFF262a35) : Colors.white,
      canvasColor: isDarkTheme ? Colors.black : Colors.grey[50],
      brightness: isDarkTheme ? Brightness.dark : Brightness.light,
      buttonTheme: Theme.of(context).buttonTheme.copyWith(colorScheme: isDarkTheme ? ColorScheme.dark() : ColorScheme.light()),
      appBarTheme: AppBarTheme(
        elevation: 0.0,
      ),
      textTheme:  TextTheme(
        bodyText1: TextStyle(
          color: isDarkTheme ? Colors.white : Colors.black
        ),
        bodyText2: TextStyle(
            color: isDarkTheme ? Colors.grey[300] : Colors.grey[700]
        )
      )
    );

  }

}