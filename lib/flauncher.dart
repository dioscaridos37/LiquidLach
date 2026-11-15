/*
 * FLauncher
 * Copyright (C) 2021  Г‰tienne Fesser
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
              builder: (_, wallpaper, __) => _wallpaper(context, wallpaper.wallpaperBytes, wallpaper.gradient.gradient),
            ),
            Scaffold(backgroundColor: Colors.transparent, body: SafeArea(child: Column(children: [
              _header(context),
              Expanded(child: Padding(
                padding: EdgeInsets.fromLTRB(38, 18, 38, 0),
                child: Consumer<AppsService>(
                  builder: (context, appsService, _) => appsService.initialized
                      ? SingleChildScrollView(child: _categories(appsService.categoriesWithApps))
                      : _emptyState(context),
                ),
              )),
            ]))),
          ],
        ),
      );

  Widget _categories(List<CategoryWithApps> categoriesWithApps) => Column(
        children: categoriesWithApps.map((categoryWithApps) {
          switch (categoryWithApps.category.type) {
            case CategoryType.row:
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: CategoryRow(
                    key: Key(categoryWithApps.category.id.toString()),
                    category: categoryWithApps.category,
                    applications: categoryWithApps.applications),
              );
            case CategoryType.grid:
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: AppsGrid(
                    key: Key(categoryWithApps.category.id.toString()),
                    category: categoryWithApps.category,
                    applications: categoryWithApps.applications),
              );
          }
        }).toList(),
      );

  Widget _header(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(38, 24, 38, 0),
        child: Row(children: [
          Text('LiquidLach', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -1)),
          SizedBox(width: 8),
          Text('ЛАУНЧЕР', style: TextStyle(fontSize: 12, letterSpacing: 2, color: Colors.white60)),
          SizedBox(width: 34),
          Expanded(child: _glassNav(context)),
          SizedBox(width: 22),
          TimeWidget(),
          SizedBox(width: 22),
          _glassButton(context, Icons.download_rounded, () => context.read<AppsService>().openApkInstaller()),
          SizedBox(width: 10),
          _glassButton(context, Icons.settings_outlined, () => showDialog(context: context, builder: (_) => SettingsPanel())),
        ]),
      );

  Widget _glassNav(BuildContext context) => Container(
        height: 58,
        padding: EdgeInsets.all(5),
        decoration: _glassDecoration(Colors.white.withOpacity(.12)),
        child: Row(children: [
          _navItem(context, 0, Icons.home_outlined, 'Главная'),
          _navItem(context, 1, Icons.sports_esports_outlined, 'Игры'),
          _navItem(context, 2, Icons.layers_outlined, 'Приложения'),
          _navItem(context, 3, Icons.grid_view_rounded, 'Медиатека'),
          _glassButton(context, Icons.search, () {}),
        ]),
      );

  Widget _navItem(BuildContext context, int index, IconData icon, String label) => Expanded(
        child: AnimatedContainer(duration: Duration(milliseconds: 350), curve: Curves.easeOutBack,
          decoration: _tab == index ? _glassDecoration(Color(0xff318cff).withOpacity(.70)) : null,
          child: FocusableActionDetector(
            autofocus: index == 0,
            onFocusChange: (focused) { if (focused) setState(() => _tab = index); },
            child: InkWell(onTap: () => setState(() => _tab = index), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, size: 20), SizedBox(width: 8), Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
            ])),
          ),
        ),
      );

  Widget _glassButton(BuildContext context, IconData icon, VoidCallback onPressed) =>
      Container(decoration: _glassDecoration(Colors.white.withOpacity(.10)), child: IconButton(onPressed: onPressed, icon: Icon(icon)));

  BoxDecoration _glassDecoration(Color color) => BoxDecoration(
        color: color, borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(.28)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.22), blurRadius: 18, offset: Offset(0, 8))],
      );

  Widget _wallpaper(BuildContext context, Uint8List? wallpaperImage, Gradient gradient) => wallpaperImage != null
      ? Stack(fit: StackFit.expand, children: [Image.memory(
          wallpaperImage,
          key: Key("background"),
          fit: BoxFit.cover,
          height: window.physicalSize.height,
          width: window.physicalSize.width,
        ), _backgroundShade()])
      : Stack(fit: StackFit.expand, children: [Container(key: Key("background"), decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xff05050a), Color(0xff10142e), Color(0xff020207)]))), _backgroundGlow()]);

  Widget _backgroundShade() => Container(color: Colors.black.withOpacity(.28));

  Widget _backgroundGlow() => IgnorePointer(child: Stack(children: [
        Positioned(left: -120, top: 80, child: _glow(Color(0xff285fff), 260)),
        Positioned(right: -130, bottom: -100, child: _glow(Color(0xffb34dff), 320)),
      ]));

  Widget _glow(Color color, double size) => Container(width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(.18),
          boxShadow: [BoxShadow(color: color.withOpacity(.24), blurRadius: 100, spreadRadius: 30)]));

  Widget _emptyState(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
             Text("Загрузка…", style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      );
}

