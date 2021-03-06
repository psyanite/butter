import 'package:flutter/material.dart';

class Burnt {

  /// Colors
  static const materialPrimary = Colors.lightBlue;
//  static const primary = Color(0xFFFFAB40);
  static const primary = Color(0xFF529EF5);
  static const primaryLight = Color(0xFFFFC86B);
  static const primaryExtraLight = Color(0xFFFFD173);
  static const textBodyColor = Color(0xDD604B41);
  static const hintTextColor = Color(0xBB604B41);
  static const lightTextColor = Color(0x82604B41);
  static const primaryTextColor = Color(0xFFF9AB0F);
  static const paper = Color(0xFFFAFAFA);
  static const separator = Color(0xFFEEEEEE);
  static const separatorBlue = Color(0x16007AFF);
  static const lightGrey = Color(0x44604B41);
  static const iconGrey = Color(0x44604B41);
  static const iconOrange = Color(0xFFFFD173);
  static const splashOrange = Color(0x30FFD173);
  static const imgPlaceholderColor = Color(0x08604B41);
  static const lightBlue = Color(0x6C007AFF);
  static const blue = Color(0xFF007AFF);
  static const darkBlue = Color(0xFF4A83C4);
  static const dullBlue = Color(0xFF22AFE6);
  static const splashButton = Color(0xFF76CFF6);
  static const splashGrad1 = Color(0xFF97DEFC);
  static const splashGrad2 = Color(0xFF5AC1ED);
  static const splashGrad3 = Color(0xFF22AFE6);


  /// Fonts
  static const fontBase = 'PTSans';
  static const fontFancy = 'GrandHotel';
  static const fontLight = FontWeight.w100;
  static const fontLean = FontWeight.w400;
  static const fontBold = FontWeight.w600;
  static const fontExtraBold = FontWeight.w800;
  static var display4 = TextStyle(fontSize: 28.0);
  static var bodyStyle = TextStyle(color: textBodyColor, fontSize: 14.0, fontFamily: Burnt.fontBase, fontWeight: Burnt.fontLight);
  static var appBarTitleStyle =
      TextStyle(color: Burnt.primary, fontSize: 22.0, fontFamily: Burnt.fontBase, fontWeight: Burnt.fontLight, letterSpacing: 3.0);
  static var titleStyle = TextStyle(fontSize: 20.0, fontWeight: Burnt.fontBold);

  /// Gradients
  static const burntGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0, 0.5, 1.0],
    colors: [Color(0xFFFFC86B), Color(0xFFFFAB40), Color(0xFFC45D35)],
  );
  static const buttonGradient = LinearGradient(
    begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    stops: [0, 0.3],
    colors: [Color(0xFFFFC86B), Color(0xFFFFB655)],
  );
  static const splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0, 0.3, 1.0],
    colors: [splashGrad1, splashGrad2, splashGrad3],
  );
  static const splashGradientDuo = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0, 1.0],
    colors: [splashGrad1, splashGrad2],
  );

}
