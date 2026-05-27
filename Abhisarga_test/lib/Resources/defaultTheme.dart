// ignore_for_file: file_names
import 'package:flutter/material.dart';

class DefaultTheme {
  Color _primaryColor;
  Color _secondaryColor;
  Color _surfaceColor;
  Color _inversePrimaryColor;
  Color _tertiaryColor;

  DefaultTheme({
    Color primaryColor = Colors.blue,
    Color secondaryColor = Colors.green,
    Color surfaceColor = Colors.white,
    Color inversePrimaryColor = Colors.black,
    Color tertiaryColor = Colors.orange,
  })  : _primaryColor = primaryColor,
        _secondaryColor = secondaryColor,
        _surfaceColor = surfaceColor,
        _inversePrimaryColor = inversePrimaryColor,
        _tertiaryColor = tertiaryColor;

  // Getters
  Color get primaryColor => _primaryColor;
  Color get secondaryColor => _secondaryColor;
  Color get surfaceColor => _surfaceColor;
  Color get inversePrimaryColor => _inversePrimaryColor;
  Color get tertiaryColor => _tertiaryColor;

  // Setters
  set primaryColor(Color color) => _primaryColor = color;
  set secondaryColor(Color color) => _secondaryColor = color;
  set surfaceColor(Color color) => _surfaceColor = color;
  set inversePrimaryColor(Color color) => _inversePrimaryColor = color;
  set tertiaryColor(Color color) => _tertiaryColor = color;
}
