import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:ui' show PlatformDispatcher;

import 'package:http/http.dart' as http;

import 'brandingbeam_attribution_platform_interface.dart';

export 'brandingbeam_attribution_platform_interface.dart';

/// The resolved attribution payload returned from [BrandingbeamAttribution.trackOpen].
class AttributionResult {
  AttributionResult({
    required this.installId,
    required this.status,
    required this.matchType,
    this.clickId,
    this.deepLink,
    this.campaign,
    this.data,
  });

  /// Server-side install id (also used to poll for a deferred iOS match).
  final String installId;

  /// `matched` when a click was attributed, otherwise `pending`.
  final String status;

  /// `deterministic` (Android referrer / direct link), `probabilistic` (iOS), or `none`.
  final String matchType;

  /// The attributed click id — persisted and forwarded with conversions.
  final String? clickId;

  /// The in-app destination to route the user to.
  final String? deepLink;

  final String? campaign;

  /// Arbitrary key-values configured on the link (Branch-style payload).
  final Map<String, dynamic>? data;

  bool get isMatched => status == 'matched';

  factory AttributionResult.fromJson(Map<String, dynamic> j) {
    return AttributionResult(
      installId: (j['installId'] ?? '') as String,
      status: (j['status'] ?? 'pending') as String,
      matchType: (j['matchType'] ?? 'none') as String,
      clickId: j['clickId'] as String?,
      deepLink: j['deepLink'] as String?,
      campaign: j['campaign'] as String?,
      data: (j['data'] as Map?)?.cast<String, dynamic>(),
    );
  }
}

/// BrandingBeam deep linking + attribution SDK.
///
/// ```dart
/// final sdk = BrandingbeamAttribution();
/// sdk.init(publishableKey: 'pk_live_xxx', baseUrl: 'https://api.example.com');
/// final result = await sdk.trackOpen();          // deferred deep link on first open
/// if (result.deepLink != null) router.go(result.deepLink!);
/// await sdk.trackLead(customerExternalId: user.id, customerEmail: user.email);
/// await sdk.trackSale(customerExternalId: user.id, amount: 1999, currency: 'USD');
/// ```
class BrandingbeamAttribution {
  BrandingbeamAttribution({http.Client? client}) : _client = client ?? http.Client();

  String? _publishableKey;
  Uri? _baseUri;
  String? _clickId;
  final http.Client _client;

  /// Initialise with the workspace PUBLISHABLE key (`pk_...`) — never the secret API key.
  void init({required String publishableKey, required String baseUrl}) {
    _publishableKey = publishableKey;
    final trimmed =
        baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    _baseUri = Uri.parse(trimmed);
  }

  /// The click id resolved by the last [trackOpen], if any.
  String? get clickId => _clickId;

  Future<String?> getPlatformVersion() {
    return BrandingbeamAttributionPlatform.instance.getPlatformVersion();
  }

  Map<String, String> get _headers => {
        'content-type': 'application/json',
        'x-publishable-key': _publishableKey ?? '',
      };

  Uri _endpoint(String path) {
    final base = _baseUri;
    if (base == null || _publishableKey == null) {
      throw StateError('BrandingbeamAttribution.init() must be called before use.');
    }
    return base.resolve(path);
  }

  /// Call on app start (and when opened via a deep link). Resolves deferred deep linking,
  /// persists the resulting [clickId], and returns the attribution payload.
  ///
  /// For iOS the match runs asynchronously server-side; this polls briefly while it resolves.
  Future<AttributionResult> trackOpen({String? deepLink}) async {
    final context = await BrandingbeamAttributionPlatform.instance.getInstallContext();
    final platform = Platform.isIOS ? 'ios' : 'android';

    final body = <String, dynamic>{
      'platform': platform,
      if (deepLink != null) 'deepLink': deepLink,
      if (context['installReferrer'] != null) 'referrer': context['installReferrer'],
      if (context['deviceModel'] != null) 'deviceModel': context['deviceModel'],
      if (context['osVersion'] != null) 'osVersion': context['osVersion'],
      if (context['idfv'] != null) 'idfv': context['idfv'],
      'screen': _screen(),
      'locale': PlatformDispatcher.instance.locale.toLanguageTag(),
      'timezone': DateTime.now().timeZoneName,
    };

    final res = await _client.post(
      _endpoint('/resolve-install'),
      headers: _headers,
      body: jsonEncode(body),
    );
    var result = AttributionResult.fromJson(_decode(res));
    if (result.clickId != null) _clickId = result.clickId;

    // iOS probabilistic match completes asynchronously — poll a few times.
    if (!result.isMatched && result.installId.isNotEmpty) {
      result = await _pollInstall(result.installId) ?? result;
      if (result.clickId != null) _clickId = result.clickId;
    }
    return result;
  }

  Future<AttributionResult?> _pollInstall(String installId, {int attempts = 4}) async {
    for (var i = 0; i < attempts; i++) {
      await Future<void>.delayed(const Duration(seconds: 1));
      final res = await _client.get(
        _endpoint('/install/$installId'),
        headers: _headers,
      );
      final result = AttributionResult.fromJson(_decode(res));
      if (result.isMatched) return result;
    }
    return null;
  }

  /// Track a signup. References the persisted [clickId] from [trackOpen].
  Future<void> trackLead({
    required String customerExternalId,
    String? customerName,
    String? customerEmail,
    String? eventName,
    Map<String, dynamic>? metadata,
  }) async {
    await _client.post(
      _endpoint('/track/lead'),
      headers: _headers,
      body: jsonEncode({
        if (_clickId != null) 'clickId': _clickId,
        'customerExternalId': customerExternalId,
        if (customerName != null) 'customerName': customerName,
        if (customerEmail != null) 'customerEmail': customerEmail,
        if (eventName != null) 'eventName': eventName,
        if (metadata != null) 'metadata': metadata,
      }),
    );
  }

  /// Track a purchase. [amount] is in the smallest currency unit (e.g. cents).
  Future<void> trackSale({
    required String customerExternalId,
    required int amount,
    required String currency,
    String? eventName,
    String? invoiceId,
    Map<String, dynamic>? metadata,
  }) async {
    await _client.post(
      _endpoint('/track/sale'),
      headers: _headers,
      body: jsonEncode({
        if (_clickId != null) 'clickId': _clickId,
        'customerExternalId': customerExternalId,
        'amount': amount,
        'currency': currency,
        if (eventName != null) 'eventName': eventName,
        if (invoiceId != null) 'invoiceId': invoiceId,
        if (metadata != null) 'metadata': metadata,
      }),
    );
  }

  String _screen() {
    final view = PlatformDispatcher.instance.implicitView;
    if (view == null) return '';
    final s = view.physicalSize;
    return '${s.width.toInt()}x${s.height.toInt()}';
  }

  Map<String, dynamic> _decode(http.Response res) {
    if (res.statusCode >= 400) {
      throw http.ClientException(
        'BrandingbeamAttribution request failed (${res.statusCode}): ${res.body}',
      );
    }
    if (res.body.isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(res.body);
    return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
  }
}
