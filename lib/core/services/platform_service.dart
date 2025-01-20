import 'package:flutter/services.dart';
import 'dart:developer' as dev;

class PlatformService {
  static const platform = MethodChannel('com.example.carousel/wallpaper');

  Future<void> startLockScreenWallpaperChange(bool isRandom) async {
    try {
      await platform.invokeMethod('startLockScreenWallpaperChange', {'isRandom': isRandom});
    } catch (e) {
      dev.log('Start Lock Screen Wallpaper Changes: $e');
    }
  }

  Future<void> stopLockScreenWallpaperChange() async {
    try {
      await platform.invokeMethod('stopLockScreenWallpaperChange');
    } catch (e) {
      dev.log('Stop Lock Screen Wallpaper Changes: $e');
    }
  }
}
//Performing hot restart...
// Syncing files to device RMX1901...
// Restarted application in 2,896ms.
// D/ViewRootImpl[MainActivity](27561): processMotionEvent MotionEvent { action=ACTION_DOWN, actionButton=0, id[0]=0, x[0]=995.0, y[0]=186.0, toolType[0]=TOOL_TYPE_FINGER, buttonState=0, classification=NONE, metaState=0, flags=0x0, edgeFlags=0x0, pointerCount=1, historySize=0, eventTime=22580239, downTime=22580239, deviceId=3, source=0x1002, displayId=0 }
// D/ViewRootImpl[MainActivity](27561): dispatchPointerEvent handled=true, event=MotionEvent { action=ACTION_DOWN, actionButton=0, id[0]=0, x[0]=995.0, y[0]=186.0, toolType[0]=TOOL_TYPE_FINGER, buttonState=0, classification=NONE, metaState=0, flags=0x0, edgeFlags=0x0, pointerCount=1, historySize=0, eventTime=22580239, downTime=22580239, deviceId=3, source=0x1002, displayId=0 }
// D/ViewRootImpl[MainActivity](27561): processMotionEvent MotionEvent { action=ACTION_UP, actionButton=0, id[0]=0, x[0]=995.0, y[0]=186.0, toolType[0]=TOOL_TYPE_FINGER, buttonState=0, classification=NONE, metaState=0, flags=0x0, edgeFlags=0x0, pointerCount=1, historySize=0, eventTime=22580327, downTime=22580239, deviceId=3, source=0x1002, displayId=0 }
// D/ViewRootImpl[MainActivity](27561): dispatchPointerEvent handled=true, event=MotionEvent { action=ACTION_UP, actionButton=0, id[0]=0, x[0]=995.0, y[0]=186.0, toolType[0]=TOOL_TYPE_FINGER, buttonState=0, classification=NONE, metaState=0, flags=0x0, edgeFlags=0x0, pointerCount=1, historySize=0, eventTime=22580327, downTime=22580239, deviceId=3, source=0x1002, displayId=0 }
// D/MainActivity(27561): Started service for screen on events.
// D/WallpaperChangeService(27561): Started listening for screen on events.
// D/ViewRootImpl[MainActivity](27561): processMotionEvent MotionEvent { action=ACTION_DOWN, actionButton=0, id[0]=0, x[0]=917.0, y[0]=359.0, toolType[0]=TOOL_TYPE_FINGER, buttonState=0, classification=NONE, metaState=0, flags=0x0, edgeFlags=0x0, pointerCount=1, historySize=0, eventTime=22581376, downTime=22581376, deviceId=3, source=0x1002, displayId=0 }
// D/ViewRootImpl[MainActivity](27561): dispatchPointerEvent handled=true, event=MotionEvent { action=ACTION_DOWN, actionButton=0, id[0]=0, x[0]=917.0, y[0]=359.0, toolType[0]=TOOL_TYPE_FINGER, buttonState=0, classification=NONE, metaState=0, flags=0x0, edgeFlags=0x0, pointerCount=1, historySize=0, eventTime=22581376, downTime=22581376, deviceId=3, source=0x1002, displayId=0 }
// D/ViewRootImpl[MainActivity](27561): processMotionEvent MotionEvent { action=ACTION_UP, actionButton=0, id[0]=0, x[0]=917.0, y[0]=359.0, toolType[0]=TOOL_TYPE_FINGER, buttonState=0, classification=NONE, metaState=0, flags=0x0, edgeFlags=0x0, pointerCount=1, historySize=0, eventTime=22581477, downTime=22581376, deviceId=3, source=0x1002, displayId=0 }
// D/ViewRootImpl[MainActivity](27561): dispatchPointerEvent handled=true, event=MotionEvent { action=ACTION_UP, actionButton=0, id[0]=0, x[0]=917.0, y[0]=359.0, toolType[0]=TOOL_TYPE_FINGER, buttonState=0, classification=NONE, metaState=0, flags=0x0, edgeFlags=0x0, pointerCount=1, historySize=0, eventTime=22581477, downTime=22581376, deviceId=3, source=0x1002, displayId=0 }
// D/MainActivity(27561): Stopped service for screen on events.
// D/WallpaperChangeService(27561): Stopped listening for screen on events.
// [log] Stop Lock Screen Wallpaper Changes: type 'String' is not a subtype of type 'List<dynamic>?' in type cast
// D/ViewRootImpl[MainActivity](27561): processMotionEvent MotionEvent { action=ACTION_DOWN, actionButton=0, id[0]=0, x[0]=921.0, y[0]=350.0, toolType[0]=TOOL_TYPE_FINGER, buttonState=0, classification=NONE, metaState=0, flags=0x0, edgeFlags=0x0, pointerCount=1, historySize=0, eventTime=22582269, downTime=22582269, deviceId=3, source=0x1002, displayId=0 }
// D/ViewRootImpl[MainActivity](27561): dispatchPointerEvent handled=true, event=MotionEvent { action=ACTION_DOWN, actionButton=0, id[0]=0, x[0]=921.0, y[0]=350.0, toolType[0]=TOOL_TYPE_FINGER, buttonState=0, classification=NONE, metaState=0, flags=0x0, edgeFlags=0x0, pointerCount=1, historySize=0, eventTime=22582269, downTime=22582269, deviceId=3, source=0x1002, displayId=0 }
// D/ViewRootImpl[MainActivity](27561): processMotionEvent MotionEvent { action=ACTION_UP, actionButton=0, id[0]=0, x[0]=921.0, y[0]=350.0, toolType[0]=TOOL_TYPE_FINGER, buttonState=0, classification=NONE, metaState=0, flags=0x0, edgeFlags=0x0, pointerCount=1, historySize=0, eventTime=22582336, downTime=22582269, deviceId=3, source=0x1002, displayId=0 }
// D/ViewRootImpl[MainActivity](27561): dispatchPointerEvent handled=true, event=MotionEvent { action=ACTION_UP, actionButton=0, id[0]=0, x[0]=921.0, y[0]=350.0, toolType[0]=TOOL_TYPE_FINGER, buttonState=0, classification=NONE, metaState=0, flags=0x0, edgeFlags=0x0, pointerCount=1, historySize=0, eventTime=22582336, downTime=22582269, deviceId=3, source=0x1002, displayId=0 }
// D/MainActivity(27561): Started service for screen on events.
// D/WallpaperChangeService(27561): Started listening for screen on events.
// D/WallpaperChangeReceiver(27561): Screen is on
// E/ChangeWallpaperWorker(27561): Error parsing string list
// E/ChangeWallpaperWorker(27561): com.google.gson.JsonSyntaxException: com.google.gson.stream.MalformedJsonException: Use JsonReader.setLenient(true) to accept malformed JSON at line 2 column 2 path $
// E/ChangeWallpaperWorker(27561): 	at com.google.gson.Gson.assertFullConsumption(Gson.java:1148)
// E/ChangeWallpaperWorker(27561): 	at com.google.gson.Gson.fromJson(Gson.java:1138)
// E/ChangeWallpaperWorker(27561): 	at com.google.gson.Gson.fromJson(Gson.java:1047)
// E/ChangeWallpaperWorker(27561): 	at com.google.gson.Gson.fromJson(Gson.java:982)
// E/ChangeWallpaperWorker(27561): 	at com.example.carousel.ChangeWallpaperWorker.getStringList(ChangeWallpaperWorker.kt:95)
// E/ChangeWallpaperWorker(27561): 	at com.example.carousel.ChangeWallpaperWorker.changeLockScreenWallpaper(ChangeWallpaperWorker.kt:41)
// E/ChangeWallpaperWorker(27561): 	at com.example.carousel.ChangeWallpaperWorker.doWork(ChangeWallpaperWorker.kt:25)
// E/ChangeWallpaperWorker(27561): 	at androidx.work.Worker$1.run(Worker.java:82)
// E/ChangeWallpaperWorker(27561): 	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1167)
// E/ChangeWallpaperWorker(27561): 	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:641)
// E/ChangeWallpaperWorker(27561): 	at java.lang.Thread.run(Thread.java:923)
// E/ChangeWallpaperWorker(27561): Caused by: com.google.gson.stream.MalformedJsonException: Use JsonReader.setLenient(true) to accept malformed JSON at line 2 column 2 path $
// E/ChangeWallpaperWorker(27561): 	at com.google.gson.stream.JsonReader.syntaxError(JsonReader.java:1659)
// E/ChangeWallpaperWorker(27561): 	at com.google.gson.stream.JsonReader.checkLenient(JsonReader.java:1465)
// E/ChangeWallpaperWorker(27561): 	at com.google.gson.stream.JsonReader.doPeek(JsonReader.java:551)
// E/ChangeWallpaperWorker(27561): 	at com.google.gson.stream.JsonReader.peek(JsonReader.java:433)
// E/ChangeWallpaperWorker(27561): 	at com.google.gson.Gson.assertFullConsumption(Gson.java:1144)
// E/ChangeWallpaperWorker(27561): 	... 10 more
// D/ChangeWallpaperWorker(27561): Wallpaper list is empty
// D/ChangeWallpaperWorker(27561): Wallpaper change task is successful
// I/WM-WorkerWrapper(27561): Worker result SUCCESS for Work [ id=75969ee0-c9e3-4d69-8a51-be5cb3dfe250, tags={ com.example.carousel.ChangeWallpaperWorker } ]
// D/WallpaperChangeReceiver(27561): Screen is on
// E/ChangeWallpaperWorker(27561): Error parsing string list
// E/ChangeWallpaperWorker(27561): com.google.gson.JsonSyntaxException: com.google.gson.stream.MalformedJsonException: Use JsonReader.setLenient(true) to accept malformed JSON at line 2 column 2 path $
// E/ChangeWallpaperWorker(27561): 	at com.google.gson.Gson.assertFullConsumption(Gson.java:1148)
// E/ChangeWallpaperWorker(27561): 	at com.google.gson.Gson.fromJson(Gson.java:1138)
// E/ChangeWallpaperWorker(27561): 	at com.google.gson.Gson.fromJson(Gson.java:1047)
// E/ChangeWallpaperWorker(27561): 	at com.google.gson.Gson.fromJson(Gson.java:982)
// E/ChangeWallpaperWorker(27561): 	at com.example.carousel.ChangeWallpaperWorker.getStringList(ChangeWallpaperWorker.kt:95)
// E/ChangeWallpaperWorker(27561): 	at com.example.carousel.ChangeWallpaperWorker.changeLockScreenWallpaper(ChangeWallpaperWorker.kt:41)
// E/ChangeWallpaperWorker(27561): 	at com.example.carousel.ChangeWallpaperWorker.doWork(ChangeWallpaperWorker.kt:25)
// E/ChangeWallpaperWorker(27561): 	at androidx.work.Worker$1.run(Worker.java:82)
// E/ChangeWallpaperWorker(27561): 	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1167)
// E/ChangeWallpaperWorker(27561): 	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:641)
// E/ChangeWallpaperWorker(27561): 	at java.lang.Thread.run(Thread.java:923)
// E/ChangeWallpaperWorker(27561): Caused by: com.google.gson.stream.MalformedJsonException: Use JsonReader.setLenient(true) to accept malformed JSON at line 2 column 2 path $
// E/ChangeWallpaperWorker(27561): 	at com.google.gson.stream.JsonReader.syntaxError(JsonReader.java:1659)
// E/ChangeWallpaperWorker(27561): 	at com.google.gson.stream.JsonReader.checkLenient(JsonReader.java:1465)
// E/ChangeWallpaperWorker(27561): 	at com.google.gson.stream.JsonReader.doPeek(JsonReader.java:551)
// E/ChangeWallpaperWorker(27561): 	at com.google.gson.stream.JsonReader.peek(JsonReader.java:433)
// E/ChangeWallpaperWorker(27561): 	at com.google.gson.Gson.assertFullConsumption(Gson.java:1144)
// E/ChangeWallpaperWorker(27561): 	... 10 more
// D/ChangeWallpaperWorker(27561): Wallpaper list is empty
// D/ChangeWallpaperWorker(27561): Wallpaper change task is successful
// I/WM-WorkerWrapper(27561): Worker result SUCCESS for Work [ id=47bf8401-6f1b-42bd-8e83-9be1c0486bb0, tags={ com.example.carousel.ChangeWallpaperWorker } ]
// D/WallpaperChangeService(27561): Stopped listening for screen on events.