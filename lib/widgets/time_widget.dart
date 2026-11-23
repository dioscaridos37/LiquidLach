/*
 * FLauncher
 * Copyright (C) 2021 Étienne Fesser
 * Licensed under the GNU General Public License v3.0 or later.
 */

import 'dart:async';
import 'dart:ui';

import 'package:flauncher/providers/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TimeWidget extends StatefulWidget {
  @override
  _TimeWidgetState createState() => _TimeWidgetState();
}

class _TimeWidgetState extends State<TimeWidget> {
  late DateTime _now;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(Duration(seconds: 1), (_) => _refreshTime());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Selector<SettingsService, bool>(
        selector: (_, settings) => settings.use24HourTimeFormat,
        builder: (context, use24HourTimeFormat, _) => ClipRRect(
          borderRadius: BorderRadius.circular(23),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              constraints: BoxConstraints(minWidth: 180),
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.105),
                borderRadius: BorderRadius.circular(23),
                border: Border.all(color: Colors.white.withOpacity(.22)),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white.withOpacity(.16), Colors.white.withOpacity(.045)],
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(.16), blurRadius: 24, offset: Offset(0, 9)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    use24HourTimeFormat ? DateFormat.Hm().format(_now) : DateFormat.jm().format(_now),
                    style: TextStyle(fontSize: 29, height: 1.05, fontWeight: FontWeight.w300, letterSpacing: 1.4),
                  ),
                  SizedBox(height: 4),
                  Text(
                    DateFormat.yMMMMd().format(_now),
                    style: TextStyle(fontSize: 10, color: Colors.white70, letterSpacing: 1.1),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  void _refreshTime() {
    if (mounted) {
      setState(() => _now = DateTime.now());
    }
  }
}
