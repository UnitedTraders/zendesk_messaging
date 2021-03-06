import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:zendesk_messaging/user_ids.dart';

class ZendeskMessaging {
  static const MethodChannel _channel = MethodChannel('zendesk_messaging');
  static const EventChannel _unreadMessageCountChangeEventChannel =
      EventChannel('zendesk_messaging/unread_message_count_change');
  static const EventChannel _urlToHandleInAppEventChannel = EventChannel('zendesk_messaging/url_to_handle_in_app');

  /// Call method to initialize zendesk. Must be always called first
  ///
  /// throws PlatformException if something went wrong on platform/zendesk side
  static Future<void> initializeZendesk({
    String? androidChannelKey,
    String? iosChannelKey,
    bool shouldInterceptUrlHandling = false,
  }) async {
    String? channelKey;
    if (Platform.isIOS) {
      channelKey = iosChannelKey;
    }
    if (Platform.isAndroid) {
      channelKey = androidChannelKey;
    }

    await _channel.invokeMethod('zendeskInitialize', {
      'channelKey': channelKey,
      'shouldInterceptUrlHandling': shouldInterceptUrlHandling,
    });
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

  /// Stream to get count of unreadMessage
  static Stream<int> get unreadMessageCountStream => _unreadMessageCountChangeEventChannel
      .receiveBroadcastStream()
      .map((dynamic event) => _parseNativeUnreadMessageCountEvent(event));

  /// Stream to intercept url's inside zendesk chat to handle them in app
  ///
  /// To use it set [shouldInterceptUrlHandling] to "true" inside "initializeZendesk" method
  static Stream<String> get urlToHandleInAppStream =>
      _urlToHandleInAppEventChannel.receiveBroadcastStream().map((event) => event.toString());

  static int _parseNativeUnreadMessageCountEvent(dynamic event) {
    final eventToParse = event.toString();
    try {
      return int.parse(eventToParse);
    } catch (e) {
      return 0;
    }
  }
}
