import 'dart:async';

import 'package:flutter/services.dart';

class ZendeskMessaging {
  static const MethodChannel _channel = MethodChannel('zendesk_messaging');

  /// Call method to initialize zendesk. Must be always called first
  ///
  /// throws PlatformException if something went wrong on platform/zendesk side
  static Future<void> initializeZendesk(String channelKey) async =>
      await _channel.invokeMethod('zendeskInitialize', channelKey);

  /// Attempt to login user. Call only after initializing zendesk complete
  ///
  /// throws PlatformException if something went wrong on platform/zendesk side
  static Future<void> loginUser(String jwt) async => await _channel.invokeMethod('zendeskLogin', jwt);

  /// Attempt to logout user. Call only after initializing zendesk complete and if user is logged in
  ///
  /// throws PlatformException if something went wrong on platform/zendesk side
  static Future<void> logoutUser() async => await _channel.invokeMethod('zendeskLogout');

  /// Attempt to show Zendesk View. Call only after initializing zendesk complete
  ///
  /// throws PlatformException if something went wrong on platform/zendesk side
  static Future<void> showZendeskView() async => await _channel.invokeMethod('showZendesk');
}
