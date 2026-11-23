/*
 * FLauncher
 * Copyright (C) 2021 Étienne Fesser
 * Licensed under the GNU General Public License v3.0 or later.
 */

import 'dart:async';

import 'package:flauncher/database.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/providers/ticker_model.dart';
import 'package:flauncher/widgets/application_info_panel.dart';
import 'package:flauncher/widgets/color_helpers.dart';
import 'package:flauncher/widgets/focus_keyboard_listener.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

const _validationKeys = [LogicalKeyboardKey.select, LogicalKeyboardKey.enter, LogicalKeyboardKey.gameButtonA];

class AppCard extends StatefulWidget {
  final Category category;
  final App application;
  final bool autofocus;
  final void Function(AxisDirection) onMove;
  final VoidCallback onMoveEnd;

  AppCard({
    Key? key,
    required this.category,
    required this.application,
    required this.autofocus,
    required this.onMove,
    required this.onMoveEnd,
  }) : super(key: key);

  @override
  _AppCardState createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> with SingleTickerProviderStateMixin {
  bool _moving = false;
  MemoryImage? _imageProvider;
  late final AnimationController _animation = AnimationController(
    vsync: Provider.of<TickerModel>(context, listen: false).tickerProvider ?? this,
    duration: Duration(milliseconds: 1100),
  );
  Color _lastBorderColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animation.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _animation.forward();
      }
    });
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  ImageProvider _cachedMemoryImage(Uint8List bytes) {
    if (!listEquals(bytes, _imageProvider?.bytes)) {
      _imageProvider = MemoryImage(bytes);
    }
    return _imageProvider!;
  }

  @override
  Widget build(BuildContext context) => FocusKeyboardListener(
        onPressed: (key) => _onPressed(context, key),
        onLongPress: (key) => _onLongPress(context, key),
        builder: (context) {
          final focused = Focus.of(context).hasFocus;
          return AspectRatio(
            aspectRatio: 16 / 9,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 360),
              curve: Curves.easeOutBack,
              transformAlignment: Alignment.center,
              transform: Matrix4.diagonal3Values(focused && !_moving ? 1.075 : 1.0, focused && !_moving ? 1.075 : 1.0, 1.0),
              child: Material(
                color: Colors.white.withOpacity(focused ? .19 : .085),
                borderRadius: BorderRadius.circular(23),
                elevation: focused ? 22 : 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(23),
                  side: BorderSide(
                    color: focused ? Color(0xffa4e6ff).withOpacity(.95) : Colors.white.withOpacity(.17),
                    width: focused ? 2.2 : 1,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                shadowColor: Color(0xff4bbfff).withOpacity(.32),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    InkWell(
                      autofocus: widget.autofocus,
                      focusColor: Colors.transparent,
                      onTap: () => _onPressed(context, null),
                      onLongPress: () => _onLongPress(context, null),
                      child: widget.application.banner != null
                          ? Ink.image(image: _cachedMemoryImage(widget.application.banner!), fit: BoxFit.cover)
                          : Padding(
                              padding: EdgeInsets.all(9),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Ink.image(
                                      image: _cachedMemoryImage(widget.application.icon!),
                                      height: double.infinity,
                                    ),
                                  ),
                                  Flexible(
                                    flex: 3,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 9),
                                      child: Text(
                                        widget.application.name,
                                        style: Theme.of(context).textTheme.bodySmall,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                    if (_moving) ..._arrows(),
                    IgnorePointer(
                      child: AnimatedOpacity(
                        duration: Duration(milliseconds: 260),
                        curve: Curves.easeOutCubic,
                        opacity: focused ? 0 : .16,
                        child: Container(color: Colors.black),
                      ),
                    ),
                    if (focused)
                      IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Colors.white.withOpacity(.16), Colors.transparent, Color(0xff60cfff).withOpacity(.08)],
                            ),
                          ),
                        ),
                      ),
                    Selector<SettingsService, bool>(
                      selector: (_, settingsService) => settingsService.appHighlightAnimationEnabled,
                      builder: (context, enabled, __) {
                        if (enabled) {
                          _animation.forward();
                          return AnimatedBuilder(
                            animation: _animation,
                            builder: (context, child) => IgnorePointer(
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 180),
                                curve: Curves.easeOutCubic,
                                decoration: BoxDecoration(
                                  border: focused
                                      ? Border.all(
                                          color: _lastBorderColor = computeBorderColor(_animation.value, _lastBorderColor),
                                          width: 2.4,
                                        )
                                      : null,
                                  borderRadius: BorderRadius.circular(23),
                                ),
                              ),
                            ),
                          );
                        }
                        _animation.stop();
                        return SizedBox();
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );

  List<Widget> _arrows() => [
        _arrow(Alignment.centerLeft, Icons.keyboard_arrow_left),
        _arrow(Alignment.topCenter, Icons.keyboard_arrow_up),
        _arrow(Alignment.bottomCenter, Icons.keyboard_arrow_down),
        _arrow(Alignment.centerRight, Icons.keyboard_arrow_right),
      ];

  Widget _arrow(Alignment alignment, IconData icon) => Align(
        alignment: alignment,
        child: Padding(
          padding: EdgeInsets.all(4),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).primaryColor.withOpacity(.85),
            ),
            child: Icon(icon, size: 16),
          ),
        ),
      );

  KeyEventResult _onPressed(BuildContext context, LogicalKeyboardKey? key) {
    if (_moving) {
      WidgetsBinding.instance.addPostFrameCallback((_) => Scrollable.ensureVisible(
            context,
            alignment: .1,
            duration: Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
          ));
      if (key == LogicalKeyboardKey.arrowLeft) {
        widget.onMove(AxisDirection.left);
      } else if (key == LogicalKeyboardKey.arrowUp) {
        widget.onMove(AxisDirection.up);
      } else if (key == LogicalKeyboardKey.arrowRight) {
        widget.onMove(AxisDirection.right);
      } else if (key == LogicalKeyboardKey.arrowDown) {
        widget.onMove(AxisDirection.down);
      } else if (_validationKeys.contains(key)) {
        setState(() => _moving = false);
        widget.onMoveEnd();
      }
      return KeyEventResult.handled;
    } else if (_validationKeys.contains(key)) {
      context.read<AppsService>().launchApp(widget.application);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  KeyEventResult _onLongPress(BuildContext context, LogicalKeyboardKey? key) {
    if (!_moving && (key == null || longPressableKeys.contains(key))) {
      _showPanel(context);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Future<void> _showPanel(BuildContext context) async {
    final result = await showGeneralDialog<ApplicationInfoPanelResult>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(.42),
      transitionDuration: Duration(milliseconds: 360),
      pageBuilder: (_, __, ___) => ApplicationInfoPanel(
        category: widget.category,
        application: widget.application,
      ),
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
    if (result == ApplicationInfoPanelResult.reorderApp) {
      setState(() => _moving = true);
    }
  }
}
