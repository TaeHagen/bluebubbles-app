import 'dart:convert';
import 'dart:ui';

import 'package:bluebubbles/helpers/mappings.dart';
import "package:bluebubbles/helpers/string_extension.dart";
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:bluebubbles/helpers/utils.dart';
import 'package:bluebubbles/layouts/settings/scheduling_panel.dart';
import 'package:bluebubbles/layouts/theming/theming_panel.dart';
import 'package:bluebubbles/layouts/widgets/CustomCupertinoTextField.dart';
import 'package:bluebubbles/layouts/widgets/scroll_physics/custom_bouncing_scroll_physics.dart';
import 'package:bluebubbles/managers/settings_manager.dart';
import 'package:bluebubbles/repository/database.dart';
import 'package:bluebubbles/repository/models/fcm_data.dart';
import 'package:bluebubbles/repository/models/settings.dart';
import 'package:bluebubbles/socket_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import '../../helpers/hex_color.dart';
import 'package:flutter/material.dart';

import '../setup/qr_code_scanner.dart';

class SettingsPanel extends StatefulWidget {
  SettingsPanel({Key key}) : super(key: key);

  @override
  _SettingsPanelState createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  Settings _settingsCopy;
  FCMData _fcmDataCopy;
  bool needToReconnect = false;
  List<DisplayMode> modes;
  DisplayMode currentMode;
  bool showUrl = false;

  @override
  void initState() {
    super.initState();
    _settingsCopy = SettingsManager().settings;
    _fcmDataCopy = SettingsManager().fcmData;
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    modes = await FlutterDisplayMode.supported;
    currentMode = await _settingsCopy.getDisplayMode();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBodyBehindAppBar: true,
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 80),
        child: ClipRRect(
          child: BackdropFilter(
            child: AppBar(
              toolbarHeight: 100.0,
              elevation: 0,
              brightness: Theme.of(context).brightness,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios,
                    color: Theme.of(context).primaryColor),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              backgroundColor: Theme.of(context).accentColor.withOpacity(0.5),
              title: Text(
                "Settings",
                style: Theme.of(context).textTheme.headline1,
              ),
            ),
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          ),
        ),
      ),
      body: CustomScrollView(
        physics: AlwaysScrollableScrollPhysics(
          parent: CustomBouncingScrollPhysics(),
        ),
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildListDelegate(
              <Widget>[
                StreamBuilder(
                    stream: SocketManager().connectionStateStream,
                    builder: (context, AsyncSnapshot<SocketState> snapshot) {
                      SocketState connectionStatus;
                      if (snapshot.hasData) {
                        connectionStatus = snapshot.data;
                      } else {
                        connectionStatus = SocketManager().state;
                      }
                      String subtitle;

                      switch (connectionStatus) {
                        case SocketState.CONNECTED:
                          if (showUrl) {
                            subtitle =
                                "Connected (${this._settingsCopy.serverAddress})";
                          } else {
                            subtitle = "Connected (Tap to view URL)";
                          }
                          break;
                        case SocketState.DISCONNECTED:
                          subtitle = "Disconnected";
                          break;
                        case SocketState.ERROR:
                          subtitle = "Error";
                          break;
                        case SocketState.CONNECTING:
                          subtitle = "Connecting...";
                          break;
                        case SocketState.FAILED:
                          subtitle = "Failed to connect";
                          break;
                      }

                      return SettingsTile(
                        title: "Connection Status",
                        subTitle: subtitle,
                        onTap: () async {
                          if (![SocketState.CONNECTED]
                              .contains(connectionStatus)) return;
                          if (this.mounted) {
                            setState(() {
                              showUrl = !showUrl;
                            });
                          }
                        },
                        trailing: connectionStatus == SocketState.CONNECTED ||
                                connectionStatus == SocketState.CONNECTING
                            ? Icon(
                                Icons.fiber_manual_record,
                                color: HexColor('32CD32').withAlpha(200),
                              )
                            : Icon(
                                Icons.fiber_manual_record,
                                color: HexColor('DC143C').withAlpha(200),
                              ),
                      );
                    }),
                SettingsTile(
                  title: "Re-configure with MacOS Server",
                  trailing: Icon(Icons.camera,
                      color: Theme.of(context).primaryColor.withAlpha(200)),
                  onTap: () async {
                    var fcmData;
                    try {
                      fcmData = jsonDecode(
                        await Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (BuildContext context) {
                              return QRCodeScanner();
                            },
                          ),
                        ),
                      );
                    } catch (e) {
                      return;
                    }
                    if (fcmData != null) {
                      _fcmDataCopy = FCMData(
                        projectID: fcmData[2],
                        storageBucket: fcmData[3],
                        apiKey: fcmData[4],
                        firebaseURL: fcmData[5],
                        clientID: fcmData[6],
                        applicationID: fcmData[7],
                      );
                      _settingsCopy.guidAuthKey = fcmData[0];
                      _settingsCopy.serverAddress = fcmData[1];

                      SettingsManager().saveSettings(_settingsCopy);
                      SettingsManager().saveFCMData(_fcmDataCopy);
                      SocketManager().authFCM();
                    }
                  },
                ),
                SettingsSlider(
                  startingVal: _settingsCopy.chunkSize.toDouble(),
                  update: (int val) {
                    _settingsCopy.chunkSize = val;
                  },
                ),
                SettingsSwitch(
                  onChanged: (bool val) {
                    _settingsCopy.hideTextPreviews = val;
                  },
                  initialVal: _settingsCopy.hideTextPreviews,
                  title: "Hide Text Previews (in notifications)",
                ),
                SettingsSwitch(
                  onChanged: (bool val) {
                    _settingsCopy.autoOpenKeyboard = val;
                  },
                  initialVal: _settingsCopy.autoOpenKeyboard,
                  title: "Auto-open Keyboard",
                ),
                SettingsSwitch(
                  onChanged: (bool val) {
                    _settingsCopy.autoDownload = val;
                  },
                  initialVal: _settingsCopy.autoDownload,
                  title: "Auto-download Attachments",
                ),
                SettingsSwitch(
                  onChanged: (bool val) {
                    _settingsCopy.onlyWifiDownload = val;
                  },
                  initialVal: _settingsCopy.onlyWifiDownload,
                  title: "Only Auto-download Attachments on WiFi",
                ),
                SettingsSwitch(
                  onChanged: (bool val) {
                    _settingsCopy.lowMemoryMode = val;
                  },
                  initialVal: _settingsCopy.lowMemoryMode,
                  title: "Low Memory Mode",
                ),
                SettingsSwitch(
                  onChanged: (bool val) {
                    _settingsCopy.showIncrementalSync = val;
                  },
                  initialVal: _settingsCopy.showIncrementalSync,
                  title: "Notify when incremental sync complete",
                ),
                Divider(
                  color: Theme.of(context).accentColor.withOpacity(0.5),
                  thickness: 1,
                ),
                SettingsSwitch(
                  onChanged: (bool val) {
                    _settingsCopy.hideDividers = val;
                    saveSettings();
                  },
                  initialVal: _settingsCopy.hideDividers,
                  title: "Hide Dividers",
                ),
                SettingsSwitch(
                  onChanged: (bool val) {
                    _settingsCopy.rainbowBubbles = val;
                    saveSettings();
                  },
                  initialVal: _settingsCopy.rainbowBubbles,
                  title: "Colorful Chats",
                ),
                SettingsOptions<String>(
                  initial: _settingsCopy.emojiFontFamily == null
                      ? "System"
                      : fontFamilyToString[_settingsCopy.emojiFontFamily],
                  onChanged: (val) {
                    _settingsCopy.emojiFontFamily = stringToFontFamily[val];
                  },
                  options: stringToFontFamily.keys.toList(),
                  textProcessing: (dynamic val) => val,
                  title: "Emoji Style",
                  showDivider: false,
                ),
                SettingsOptions<AdaptiveThemeMode>(
                  initial: AdaptiveTheme.of(context).mode,
                  onChanged: (val) {
                    AdaptiveTheme.of(context).setThemeMode(val);
                  },
                  options: AdaptiveThemeMode.values,
                  textProcessing: (dynamic val) =>
                      val.toString().split(".").last,
                  title: "App Theme",
                  showDivider: false,
                ),
                SettingsTile(
                  title: "Theming",
                  trailing: Icon(Icons.arrow_forward_ios,
                      color: Theme.of(context).primaryColor),
                  onTap: () async {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => ThemingPanel(),
                      ),
                    );
                  },
                ),
                if (currentMode != null && modes != null)
                  SettingsOptions<DisplayMode>(
                    initial: currentMode,
                    onChanged: (val) async {
                      currentMode = val;
                      _settingsCopy.displayMode = currentMode.id;
                    },
                    options: modes,
                    textProcessing: (dynamic val) => val.toString(),
                    title: "Display",
                  ),
                // SettingsTile(
                //   title: "Message Scheduling",
                //   trailing: Icon(Icons.arrow_forward_ios,
                //       color: Theme.of(context).primaryColor),
                //   onTap: () async {
                //     Navigator.of(context).push(
                //       CupertinoPageRoute(
                //         builder: (context) => SchedulingPanel(),
                //       ),
                //     );
                //   },
                // ),
                SettingsTile(
                  onTap: () {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(
                            "Are you sure?",
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                          backgroundColor: Theme.of(context).backgroundColor,
                          actions: <Widget>[
                            FlatButton(
                              child: Text("Yes"),
                              onPressed: () async {
                                await DBProvider.deleteDB();
                                Settings temp = SettingsManager().settings;
                                temp.finishedSetup = false;
                                await SettingsManager().saveSettings(temp);
                                SocketManager().finishedSetup.sink.add(false);
                                Navigator.of(context)
                                    .popUntil((route) => route.isFirst);
                              },
                            ),
                            FlatButton(
                              child: Text("Cancel"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  title: "Reset DB",
                ),
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              <Widget>[],
            ),
          )
        ],
      ),
    );
  }

  void saveSettings() {
    SettingsManager().saveSettings(_settingsCopy);
    if (needToReconnect) {
      SocketManager().startSocketIO(forceNewConnection: true);
    }
  }

  @override
  void dispose() {
    saveSettings();
    super.dispose();
  }
}

class SettingsTile extends StatelessWidget {
  const SettingsTile(
      {Key key, this.onTap, this.title, this.trailing, this.subTitle})
      : super(key: key);

  final Function onTap;
  final String subTitle;
  final String title;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).backgroundColor,
      child: InkWell(
        onTap: this.onTap,
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text(
                this.title,
                style: Theme.of(context).textTheme.bodyText1,
              ),
              trailing: this.trailing,
              subtitle: subTitle != null
                  ? Text(
                      subTitle,
                      style: Theme.of(context).textTheme.subtitle1,
                    )
                  : null,
            ),
            Divider(
              color: Theme.of(context).accentColor.withOpacity(0.5),
              thickness: 1,
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsTextField extends StatelessWidget {
  const SettingsTextField(
      {Key key,
      this.onTap,
      this.title,
      this.trailing,
      @required this.controller,
      this.placeholder,
      this.maxLines = 14,
      this.keyboardType = TextInputType.multiline,
      this.inputFormatters = const []})
      : super(key: key);

  final TextEditingController controller;
  final Function onTap;
  final String title;
  final String placeholder;
  final Widget trailing;
  final int maxLines;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).backgroundColor,
      child: InkWell(
        onTap: this.onTap,
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text(
                this.title,
                style: Theme.of(context).textTheme.bodyText1,
              ),
              trailing: this.trailing,
              subtitle: Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: CustomCupertinoTextField(
                  cursorColor: Theme.of(context).primaryColor,
                  onLongPressStart: () {
                    Feedback.forLongPress(context);
                  },
                  onTap: () {
                    HapticFeedback.selectionClick();
                  },
                  textCapitalization: TextCapitalization.sentences,
                  inputFormatters: inputFormatters,
                  autocorrect: true,
                  controller: controller,
                  scrollPhysics: CustomBouncingScrollPhysics(),
                  style: Theme.of(context).textTheme.bodyText1.apply(
                      color: ThemeData.estimateBrightnessForColor(
                                  Theme.of(context).backgroundColor) ==
                              Brightness.light
                          ? Colors.black
                          : Colors.white,
                      fontSizeDelta: -0.25),
                  keyboardType: keyboardType,
                  maxLines: maxLines,
                  minLines: 1,
                  placeholder: placeholder ?? "Enter your text here",
                  padding:
                      EdgeInsets.only(left: 10, top: 10, right: 40, bottom: 10),
                  placeholderStyle: Theme.of(context).textTheme.subtitle1,
                  autofocus: SettingsManager().settings.autoOpenKeyboard,
                  decoration: BoxDecoration(
                    color: Theme.of(context).backgroundColor,
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            Divider(
              color: Theme.of(context).accentColor.withOpacity(0.5),
              thickness: 1,
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsSwitch extends StatefulWidget {
  SettingsSwitch({
    Key key,
    this.initialVal,
    this.onChanged,
    this.title,
  }) : super(key: key);
  final bool initialVal;
  final Function(bool) onChanged;
  final String title;

  @override
  _SettingsSwitchState createState() => _SettingsSwitchState();
}

class _SettingsSwitchState extends State<SettingsSwitch> {
  bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialVal;
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(
        widget.title,
        style: Theme.of(context).textTheme.bodyText1,
      ),
      value: _value,
      activeColor: Theme.of(context).primaryColor,
      activeTrackColor: Theme.of(context).primaryColor.withAlpha(200),
      inactiveTrackColor: Theme.of(context).accentColor.withOpacity(0.6),
      inactiveThumbColor: Theme.of(context).accentColor,
      onChanged: (bool val) {
        widget.onChanged(val);

        if (!this.mounted) return;

        setState(() {
          _value = val;
        });
      },
    );
  }
}

class SettingsOptions<T> extends StatefulWidget {
  SettingsOptions({
    Key key,
    this.onChanged,
    this.options,
    this.initial,
    this.textProcessing,
    this.title,
    this.subtitle,
    this.showDivider = true,
  }) : super(key: key);
  final String title;
  final Function(dynamic) onChanged;
  final List<T> options;
  final T initial;
  final String Function(dynamic) textProcessing;
  final bool showDivider;
  final String subtitle;

  @override
  _SettingsOptionsState createState() => _SettingsOptionsState();
}

class _SettingsOptionsState<T> extends State<SettingsOptions<T>> {
  T currentVal;

  @override
  void initState() {
    super.initState();
    currentVal = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ),
                  (widget.subtitle != null)
                      ? Container(
                          child: Padding(
                            padding: EdgeInsets.only(top: 3.0),
                            child: Text(
                              widget.subtitle ?? "",
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                          ),
                        )
                      : Container(),
                ]),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 9),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).accentColor,
              ),
              child: Center(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<T>(
                    dropdownColor: Theme.of(context).accentColor,
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: Theme.of(context).textTheme.bodyText1.color,
                    ),
                    value: currentVal,
                    items: widget.options.map<DropdownMenuItem<T>>((e) {
                      return DropdownMenuItem(
                        value: e,
                        child: Text(
                          widget.textProcessing(e).capitalize(),
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      );
                    }).toList(),
                    onChanged: (T val) {
                      widget.onChanged(val);

                      if (!this.mounted) return;

                      setState(() {
                        currentVal = val;
                      });
                      //
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      (widget.showDivider)
          ? Divider(
              color: Theme.of(context).accentColor.withOpacity(0.5),
              thickness: 1,
            )
          : Container()
    ]);
  }
}

class SettingsSlider extends StatefulWidget {
  SettingsSlider({this.startingVal, this.update, Key key}) : super(key: key);

  final double startingVal;
  final Function update;

  @override
  _SettingsSliderState createState() => _SettingsSliderState();
}

class _SettingsSliderState extends State<SettingsSlider> {
  double currentVal = 500;
  @override
  void initState() {
    super.initState();
    if (widget.startingVal > 1 && widget.startingVal < 5000) {
      currentVal = widget.startingVal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(
            "Attachment Chunk Size: ${getSizeString(currentVal)}",
            style: Theme.of(context).textTheme.bodyText1,
          ),
          subtitle: Slider(
            activeColor: Theme.of(context).primaryColor,
            inactiveColor: Theme.of(context).primaryColor.withOpacity(0.2),
            value: currentVal,
            onChanged: (double value) {
              if (!this.mounted) return;

              setState(() {
                currentVal = value;
                widget.update(currentVal.floor());
              });
            },
            label: getSizeString(currentVal),
            divisions: 29,
            min: 100,
            max: 3000,
          ),
        ),
        Divider(
          color: Theme.of(context).accentColor.withOpacity(0.5),
          thickness: 1,
        ),
      ],
    );
  }
}
