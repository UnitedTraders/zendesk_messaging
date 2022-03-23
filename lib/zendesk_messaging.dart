import 'dart:io' show Platform;
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:zendesk_messaging/user_ids.dart';

class ZendeskMessaging {
  static const MethodChannel _channel = MethodChannel('zendesk_messaging');

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
    final Map<String, String?> result = await _channel.invokeMethod('zendeskLogin', jwt);

    return UserIds(result['id'], result['externalId']);
  }

  /// Attempt to logout user. Call only after initializing zendesk complete and if user is logged in
  ///
  /// throws PlatformException if something went wrong on platform/zendesk side
  static Future<void> logoutUser() async => await _channel.invokeMethod('zendeskLogout');

  /// Attempt to show Zendesk View. Call only after initializing zendesk complete
  ///
  /// throws PlatformException if something went wrong on platform/zendesk side
  static Future<void> showZendeskView() async => await _channel.invokeMethod('showZendesk');
}
