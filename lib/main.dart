import 'package:flutter/material.dart';

import 'package:belajar_dart/config/app.dart';
import 'package:belajar_dart/config/app_config.dart';

void main() {
  AppConfig.environment = Environment.production;
  runApp(const KostaraApp());
}
