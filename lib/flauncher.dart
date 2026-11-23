/*
 * FLauncher
 * Copyright (C) 2021 Étienne Fesser
 * Licensed under the GNU General Public License v3.0 or later.
 */

import 'dart:typed_data';
import 'dart:ui';

import 'package:flauncher/custom_traversal_policy.dart';
import 'package:flauncher/database.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/providers/wallpaper_service.dart';
import 'package:flauncher/widgets/apps_grid.dart';
import 'package:flauncher/widgets/category_row.dart';
import 'package:flauncher/widgets/settings/settings_panel.dart';
import 'package:flauncher/widgets/time_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FLauncher extends StatefulWidget {
  @override
  State<FLauncher> createState() => _FLauncherState();
}

class _FLauncherState extends State<FLauncher> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) => FocusTraversalGroup(
        policy: RowByRowTraversalPolicy(),
        child: Stack(
          children: [
            Consumer<WallpaperService>(
              builder: (_, wallpaper, __) => _wallpaper(
                context,
                wallpaper.wallpaperBytes,
                wallpaper.gradient.gradient,
              ),
            ),
            Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                child: Column(
                  children: [
                    _header(context),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(38, 12, 38, 0),
                        child: Consumer<AppsService>(
                          builder: (context, appsService, _) => appsService.initialized
                              ? AnimatedSwitcher(
                                  duration: Duration(milliseconds: 420),
                                  switchInCurve: Curves.easeOutCubic,
                                  switchOutCurve: Curves.easeInCubic,
                                  transitionBuilder: (child, animation) => FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: Offset(0, .035),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: child,
                                    ),
                                  ),
                                  child: SingleChildScrollView(
                                    key: ValueKey(appsService.categoriesWithApps.length),
                                    child: _categories(appsService.categoriesWithApps),
                                  ),
                                )
                              : _emptyState(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget _header(BuildContext context) => SizedBox(
        height: 132,
        child: Stack(
          children: [
            Positioned(
              left: 38,
              top: 17,
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xff9cecff), Color(0xff388dff), Color(0xff7658e8)],
                      ),
                      boxShadow: [
                        BoxShadow(color: Color(0xff409bff).withOpacity(.28), blurRadius: 24, spreadRadius: 1),
                      ],
                    ),
                    child: Icon(Icons.blur_on_rounded, color: Colors.white, size: 27),
                  ),
                  SizedBox(width: 13),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LiquidLach',
                        style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700, letterSpacing: -.8),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'LIQUID GLASS EDITION',
                        style: TextStyle(fontSize: 9, letterSpacing: 2.1, color: Colors.white54),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 7,
              left: 0,
              right: 0,
              child: Center(child: TimeWidget()),
            ),
            Positioned(
              right: 38,
              top: 17,
              child: Row(
                children: [
                  _glassButton(context, Icons.install_mobile_rounded, 'Установить APK',
                      () => context.read<AppsService>().openApkInstaller()),
                  SizedBox(width: 10),
                  _glassButton(context, Icons.tune_rounded, 'Настройки', () => _openSettings(context)),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 9,
              child: Center(child: _glassNav(context)),
            ),
          ],
        ),
      );

  Widget _glassNav(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 51,
            width: 590,
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.095),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withOpacity(.20)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white.withOpacity(.13), Colors.white.withOpacity(.035)],
              ),
            ),
            child: Row(
              children: [
                _navItem(context, 0, Icons.home_rounded, 'Главная'),
                _navItem(context, 1, Icons.sports_esports_rounded, 'Игры'),
                _navItem(context, 2, Icons.apps_rounded, 'Приложения'),
                _navItem(context, 3, Icons.video_library_rounded, 'Медиатека'),
              ],
            ),
          ),
        ),
      );

  Widget _navItem(BuildContext context, int index, IconData icon, String label) => Expanded(
        child: AnimatedContainer(
          duration: Duration(milliseconds: 360),
          curve: Curves.easeOutBack,
          decoration: BoxDecoration(
            color: _tab == index ? Color(0xff69bfff).withOpacity(.25) : Colors.transparent,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: _tab == index ? Color(0xffa9e4ff).withOpacity(.34) : Colors.transparent,
            ),
          ),
          child: FocusableActionDetector(
            onFocusChange: (focused) {
              if (focused) setState(() => _tab = index);
            },
            child: InkWell(
              borderRadius: BorderRadius.circular(17),
              onTap: () => setState(() => _tab = index),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 18, color: _tab == index ? Colors.white : Colors.white70),
                  SizedBox(width: 8),
                  Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _glassButton(BuildContext context, IconData icon, String tooltip, VoidCallback onPressed) =>
      Tooltip(
        message: tooltip,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Material(
              color: Colors.white.withOpacity(.10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17),
                side: BorderSide(color: Colors.white.withOpacity(.20)),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(17),
                onTap: onPressed,
                child: SizedBox(
                  width: 47,
                  height: 47,
                  child: Icon(icon, size: 21, color: Colors.white.withOpacity(.92)),
                ),
              ),
            ),
          ),
        ),
      );

  Future<void> _openSettings(BuildContext context) async {
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(.42),
      transitionDuration: Duration(milliseconds: 420),
      pageBuilder: (_, __, ___) => SettingsPanel(),
      transitionBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(begin: Offset(1, 0), end: Offset.zero).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  Widget _categories(List<CategoryWithApps> categoriesWithApps) => Column(
        children: categoriesWithApps.map((categoryWithApps) {
          switch (categoryWithApps.category.type) {
            case CategoryType.row:
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 9),
                child: CategoryRow(
                  key: Key(categoryWithApps.category.id.toString()),
                  category: categoryWithApps.category,
                  applications: categoryWithApps.applications,
                ),
              );
            case CategoryType.grid:
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 9),
                child: AppsGrid(
                  key: Key(categoryWithApps.category.id.toString()),
                  category: categoryWithApps.category,
                  applications: categoryWithApps.applications,
                ),
              );
          }
        }).toList(),
      );

  Widget _wallpaper(BuildContext context, Uint8List? wallpaperImage, Gradient gradient) =>
      wallpaperImage != null
          ? Stack(
              fit: StackFit.expand,
              children: [
                Image.memory(
                  wallpaperImage,
                  key: Key('background'),
                  fit: BoxFit.cover,
                  height: window.physicalSize.height,
                  width: window.physicalSize.width,
                ),
                Container(color: Colors.black.withOpacity(.34)),
                _ambientGlow(),
              ],
            )
          : Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  key: Key('background'),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xff050811), Color(0xff101c36), Color(0xff080a18)],
                    ),
                  ),
                ),
                _ambientGlow(),
              ],
            );

  Widget _ambientGlow() => IgnorePointer(
        child: Stack(
          children: [
            Positioned(left: -170, top: 90, child: _glow(Color(0xff287dff), 360)),
            Positioned(right: -170, bottom: -150, child: _glow(Color(0xff9c55ff), 420)),
            Positioned(right: 260, top: -230, child: _glow(Color(0xff3ac9e8), 300)),
          ],
        ),
      );

  Widget _glow(Color color, double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(.10),
          boxShadow: [BoxShadow(color: color.withOpacity(.22), blurRadius: 110, spreadRadius: 35)],
        ),
      );

  Widget _emptyState(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Загрузка приложений…', style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      );
}
