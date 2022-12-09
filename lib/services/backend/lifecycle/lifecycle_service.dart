import 'dart:isolate';
import 'dart:ui' hide window;

import 'package:bluebubbles/main.dart';
import 'package:bluebubbles/services/services.dart';
import 'package:bluebubbles/helpers/helpers.dart';
import 'package:bluebubbles/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:universal_html/html.dart';

LifecycleService ls = Get.isRegistered<LifecycleService>() ? Get.find<LifecycleService>() : Get.put(LifecycleService());

class LifecycleService extends GetxService with WidgetsBindingObserver {
  bool isBubble = false;
  bool isUiThread = true;
  bool get isAlive => kIsWeb ? !(window.document.hidden ?? false)
      : (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed
        || IsolateNameServer.lookupPortByName('bg_isolate') != null);

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state != AppLifecycleState.resumed) {
      SystemChannels.textInput.invokeMethod('TextInput.hide').catchError((e) {
        Logger.error("Error caught while hiding keyboard: ${e.toString()}");
      });
      if (isBubble) {
        closeBubble();
      } else {
        close();
      }
    } else if (state == AppLifecycleState.resumed) {
      await storeStartup.future;
      open();
    }
  }

  void open() {
    cm.setActiveToAlive();
    if (cm.activeChat != null) {
      cm.clearChatNotifications(cm.activeChat!.chat);
    }

    if (!kIsDesktop && !kIsWeb) {
      // clever trick so we can see if the app is active in an isolate or not
      if (!isBubble) {
        final port = ReceivePort();
        IsolateNameServer.removePortNameMapping('bg_isolate');
        IsolateNameServer.registerPortWithName(port.sendPort, 'bg_isolate');
      }
      socket.reconnect();
    }
  }

  void close() {
    cm.setActiveToDead();
    if (!kIsDesktop && !kIsWeb) {
      IsolateNameServer.removePortNameMapping('bg_isolate');
      socket.disconnect();
    }
  }

  void closeBubble() {
    cm.setAllInactive();
    socket.disconnect();
  }
}