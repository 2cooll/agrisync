import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:flutter/foundation.dart';

enum NotificationPermissionStatus {
  granted,
  denied,
  defaultStatus,
  unsupported,
}

@JS('window')
external JSObject get _window;

class SystemNotificationHelper {
  static Future<void> ensureInitialized() async {
    // Web notifications do not require local notification plugin initialization
  }

  static Future<NotificationPermissionStatus> getPermissionStatus() async {
    try {
      if (!kIsWeb) return NotificationPermissionStatus.unsupported;
      final notifObj = _window.getProperty<JSObject?>('Notification'.toJS);
      if (notifObj == null) return NotificationPermissionStatus.unsupported;

      final perm = notifObj.getProperty<JSString?>('permission'.toJS)?.toDart;
      if (perm == 'granted') return NotificationPermissionStatus.granted;
      if (perm == 'denied') return NotificationPermissionStatus.denied;
      return NotificationPermissionStatus.defaultStatus;
    } catch (e) {
      debugPrint('ℹ️ [SystemNotificationWeb] Permission status error: $e');
      return NotificationPermissionStatus.unsupported;
    }
  }

  static Future<NotificationPermissionStatus> requestPermission() async {
    try {
      if (!kIsWeb) return NotificationPermissionStatus.unsupported;
      final notifObj = _window.getProperty<JSObject?>('Notification'.toJS);
      if (notifObj == null) return NotificationPermissionStatus.unsupported;

      final reqPromise = notifObj.callMethod<JSPromise<JSString>>('requestPermission'.toJS);
      final result = await reqPromise.toDart;
      final perm = result.toDart;
      if (perm == 'granted') return NotificationPermissionStatus.granted;
      if (perm == 'denied') return NotificationPermissionStatus.denied;
      return NotificationPermissionStatus.defaultStatus;
    } catch (e) {
      debugPrint('ℹ️ [SystemNotificationWeb] requestPermission error: $e');
      return NotificationPermissionStatus.unsupported;
    }
  }

  static Future<bool> showSystemNotification({
    required String title,
    required String body,
    String? icon,
    String? tag,
  }) async {
    try {
      if (!kIsWeb) return false;
      final notifObj = _window.getProperty<JSObject?>('Notification'.toJS);
      if (notifObj == null) return false;

      final perm = notifObj.getProperty<JSString?>('permission'.toJS)?.toDart;
      if (perm != 'granted') return false;

      final options = JSObject();
      options.setProperty('body'.toJS, body.toJS);
      if (icon != null && icon.isNotEmpty) {
        options.setProperty('icon'.toJS, icon.toJS);
      } else {
        options.setProperty('icon'.toJS, 'icons/Icon-192.png'.toJS);
      }
      if (tag != null && tag.isNotEmpty) {
        options.setProperty('tag'.toJS, tag.toJS);
      }

      // Instantiate new Notification(title, options) via JS constructor call
      _window.callMethod<JSObject>('eval'.toJS, '''
        (function(title, body, icon, tag) {
          try {
            var n = new Notification(title, {
              body: body,
              icon: icon,
              tag: tag || 'agrisync_push'
            });
            n.onclick = function() {
              window.focus();
              this.close();
            };
            return true;
          } catch(e) {
            console.warn('[AgriSync Web Push Error]', e);
            return false;
          }
        })
      '''.toJS);

      final evalFn = _window.callMethod<JSFunction>('eval'.toJS, '''
        (function() {
          return function(title, body, icon, tag) {
            try {
              var n = new Notification(title, {
                body: body,
                icon: icon,
                tag: tag || 'agrisync_push'
              });
              n.onclick = function() {
                window.focus();
                this.close();
              };
              return true;
            } catch(e) {
              console.warn('[AgriSync Web Push Error]', e);
              return false;
            }
          };
        })()
      '''.toJS);

      evalFn.callAsFunction(
        null,
        title.toJS,
        body.toJS,
        (icon ?? 'icons/Icon-192.png').toJS,
        (tag ?? 'agrisync').toJS,
      );

      return true;
    } catch (e) {
      debugPrint('ℹ️ [SystemNotificationWeb] showSystemNotification error: $e');
      return false;
    }
  }
}
