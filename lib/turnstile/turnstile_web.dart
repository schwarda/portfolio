// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;

import 'package:flutter/widgets.dart';

import 'turnstile_interface.dart';

int _turnstileCounter = 0;

enum _TurnstileStatus {
  expired,
  loadError,
}

class _WebTurnstileController extends TurnstileController {
  _WebTurnstileController({
    required this.siteKey,
    required this.isLocalBypass,
  }) : _containerId = 'portfolio-turnstile-${_turnstileCounter++}' {
    _subscribeToWindowEvents();
  }

  final String siteKey;
  @override
  final bool isLocalBypass;
  final String _containerId;

  StreamSubscription<html.Event>? _tokenSubscription;
  StreamSubscription<html.Event>? _expiredSubscription;
  StreamSubscription<html.Event>? _errorSubscription;
  Timer? _retryTimer;
  Timer? _tokenPollTimer;
  bool _isRendered = false;
  bool _isDisposed = false;
  bool _isLoading = false;
  int _attempts = 0;
  String? _token;
  String _localeCode = 'en';
  _TurnstileStatus? _status;

  @override
  bool get isEnabled => siteKey.trim().isNotEmpty;

  @override
  bool get isLoading => _isLoading;

  @override
  bool get isReady => isLocalBypass || _isRendered;

  @override
  String? get token => _token;

  @override
  String? get statusMessage {
    switch (_status) {
      case _TurnstileStatus.expired:
        return _localeCode == 'sk'
            ? 'Bezpečnostný token expiroval. Overenie sa obnovuje.'
            : 'The security token expired. Verification is refreshing.';
      case _TurnstileStatus.loadError:
        return _localeCode == 'sk'
            ? 'Antibot ochranu sa nepodarilo načítať. Obnovte stránku a skúste to znova.'
            : 'The anti-bot protection could not be loaded. Refresh the page and try again.';
      case null:
        return null;
    }
  }

  String? _detailString(Object? detail, String property) {
    if (detail == null) {
      return null;
    }
    if (detail is Map) {
      final value = detail[property];
      return value?.toString();
    }

    try {
      final object = js.JsObject.fromBrowserObject(detail);
      final value = object[property];
      return value?.toString();
    } catch (_) {
      return null;
    }
  }

  void _subscribeToWindowEvents() {
    _tokenSubscription = html.window.on['portfolio-turnstile-token'].listen(
      (event) {
        final customEvent = event as html.CustomEvent;
        final detail = customEvent.detail;
        final containerId = _detailString(detail, 'containerId');
        if (containerId != _containerId) {
          return;
        }
        _token = _detailString(detail, 'token');
        _status = null;
        notifyListeners();
      },
    );

    _expiredSubscription = html.window.on['portfolio-turnstile-expired'].listen(
      (event) {
        final customEvent = event as html.CustomEvent;
        final detail = customEvent.detail;
        final containerId = _detailString(detail, 'containerId');
        if (containerId != _containerId) {
          return;
        }
        _token = null;
        _status = _TurnstileStatus.expired;
        notifyListeners();
      },
    );

    _errorSubscription = html.window.on['portfolio-turnstile-error'].listen(
      (event) {
        final customEvent = event as html.CustomEvent;
        final detail = customEvent.detail;
        final containerId = _detailString(detail, 'containerId');
        if (containerId != _containerId) {
          return;
        }
        _token = null;
        _status = _TurnstileStatus.loadError;
        notifyListeners();
      },
    );
  }

  js.JsObject? get _helperObject {
    if (!js.context.hasProperty('portfolioTurnstile')) {
      return null;
    }
    final helper = js.context['portfolioTurnstile'];
    if (helper is js.JsObject) {
      return helper;
    }

    try {
      return js.JsObject.fromBrowserObject(helper);
    } catch (_) {
      return null;
    }
  }

  @override
  void updateLocaleCode(String localeCode) {
    final normalized = localeCode.toLowerCase().startsWith('sk') ? 'sk' : 'en';
    if (_localeCode == normalized) {
      return;
    }

    _localeCode = normalized;
    notifyListeners();
  }

  @override
  void ensureRendered() {
    if (_isDisposed || isLocalBypass || !isEnabled) {
      return;
    }

    _isLoading = true;
    notifyListeners();
    _renderOrRetry();
  }

  void _renderOrRetry() {
    if (_isDisposed) {
      return;
    }

    final helper = _helperObject;
    if (helper == null) {
      _scheduleRetry();
      return;
    }

    final rendered =
        helper.callMethod('open', [_containerId, siteKey, _localeCode]) == true;

    if (rendered) {
      _isRendered = true;
      _isLoading = false;
      _status = null;
      _startTokenPolling();
      notifyListeners();
      return;
    }

    _scheduleRetry();
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    _attempts += 1;
    if (_attempts >= 10) {
      _isLoading = false;
      _status = _TurnstileStatus.loadError;
      notifyListeners();
      return;
    }

    _retryTimer = Timer(const Duration(milliseconds: 300), _renderOrRetry);
  }

  void _startTokenPolling() {
    _tokenPollTimer?.cancel();
    _tokenPollTimer = Timer.periodic(
      const Duration(milliseconds: 400),
      (_) => _syncTokenFromDom(),
    );
  }

  void _syncTokenFromDom() {
    if (_isDisposed) {
      return;
    }

    final helper = _helperObject;
    if (helper == null) {
      return;
    }

    final token =
        helper.callMethod('getToken', [_containerId])?.toString() ?? '';
    final normalizedToken = token.trim();

    if (normalizedToken.isNotEmpty && normalizedToken != (_token ?? '')) {
      _token = normalizedToken;
      _status = null;
      notifyListeners();
      return;
    }

    if (normalizedToken.isEmpty && (_token ?? '').isNotEmpty) {
      _token = null;
      notifyListeners();
    }
  }

  @override
  void reset() {
    _token = null;
    _status = null;
    if (!isEnabled || isLocalBypass) {
      notifyListeners();
      return;
    }

    final helper = _helperObject;
    if (helper != null) {
      helper.callMethod('reset', [_containerId]);
    }
    notifyListeners();
  }

  @override
  void close() {
    final helper = _helperObject;
    if (helper != null) {
      helper.callMethod('close');
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _retryTimer?.cancel();
    _tokenPollTimer?.cancel();
    _tokenSubscription?.cancel();
    _expiredSubscription?.cancel();
    _errorSubscription?.cancel();
    super.dispose();
  }
}

class _TurnstileHtmlView extends StatefulWidget {
  const _TurnstileHtmlView({required this.controller});

  final _WebTurnstileController controller;

  @override
  State<_TurnstileHtmlView> createState() => _TurnstileHtmlViewState();
}

class _TurnstileHtmlViewState extends State<_TurnstileHtmlView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.ensureRendered();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

TurnstileController createTurnstileController({
  required String siteKey,
  required bool isLocalBypass,
}) {
  return _WebTurnstileController(
    siteKey: siteKey,
    isLocalBypass: isLocalBypass,
  );
}

Widget buildTurnstileView({
  required TurnstileController controller,
}) {
  if (controller is! _WebTurnstileController ||
      controller.isLocalBypass ||
      !controller.isEnabled) {
    return const SizedBox.shrink();
  }

  return _TurnstileHtmlView(controller: controller);
}
