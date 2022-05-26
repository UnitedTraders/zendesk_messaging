import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:zendesk_messaging/user_ids.dart';

class ZendeskMessaging {
  static const MethodChannel _channel = MethodChannel('zendesk_messaging');
  static const EventChannel _unreadMessageCountChangeEvent =
      EventChannel('zendesk_messaging/unread_message_count_change');

  /// Call method to initialize zendesk. Must be always called first
  ///
  /// throws PlatformException if something went wrong on platform/zendesk side
  static Future<void> initializeZendesk({String? androidChannelKey, String? iosChannelKey}) async {
    String? channelKey;
    if (Platform.isIOS) {
      channelKey = iosChannelKey;
    }
    if (Platform.isAndroid) {
      channelKey = androidChannelKey;
    }

    await _channel.invokeMethod('zendeskInitialize', channelKey);
  }

  /// Attempt to login user. Call only after initializing zendesk complete
  ///
  /// throws PlatformException if something went wrong on platform/zendesk side
  static Future<UserIds> loginUser(String jwt) async {
    final Map<Object?, Object?> result = await _channel.invokeMethod('zendeskLogin', jwt);

    return UserIds(result['id'] as String, result['externalId'] as String);
  }

  /// Attempt to logout user. Call only after initializing zendesk complete and if user is logged in
  ///
  /// throws PlatformException if something went wrong on platform/zendesk side
  static Future<void> logoutUser() async => await _channel.invokeMethod('zendeskLogout');

  /// Attempt to show Zendesk View. Call only after initializing zendesk complete
  ///
  /// throws PlatformException if something went wrong on platform/zendesk side
  static Future<void> showZendeskView() async => await _channel.invokeMethod('showZendesk');

  static Future<bool> checkIfNotificationArrivedWhileAppWasClosed() async =>
      await _channel.invokeMethod('checkIfNotificationArrivedWhileAppWasClosed');

  static Stream<int> get unreadMessageCountStream => _unreadMessageCountChangeEvent
      .receiveBroadcastStream()
      .map((dynamic event) => _parseNativeUnreadeMessageCountEvent(event));

  static int _parseNativeUnreadeMessageCountEvent(dynamic event) {
    try {
      return int.parse(event);
    } catch (e) {
      return 0;
    }
  }
}
