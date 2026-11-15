import 'package:flauncher/database.dart';
import 'package:flauncher/flauncher_app.dart';
import 'package:flauncher/flauncher_channel.dart';
import 'package:flauncher/unsplash_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unsplash_client/unsplash_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Paint.enableDithering = true;

  final preferences = await SharedPreferences.getInstance();
  final unsplash = UnsplashService(UnsplashClient(
    settings: ClientSettings(
      debug: false,
      credentials: AppCredentials(accessKey: '', secretKey: ''),
    ),
  ));

  runApp(FLauncherApp(
    preferences,
    ImagePicker(),
    FLauncherChannel(),
    FLauncherDatabase(connect()),
    unsplash,
  ));
}
