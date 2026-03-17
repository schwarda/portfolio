// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';

import 'turnstile_interface.dart';

int _turnstileCounter = 0;

class _WebTurnstileController extends TurnstileController {
  _WebTurnstileController({
    required this.siteKey,
    required this.isLocalBypass,
  })  : _containerId = 'portfolio-turnstile-${_turnstileCounter++}',
        _viewType = 'portfolio-turnstile-view-${_turnstileCounter++}' {
    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (viewId) => _element,
    );
    _subscribeToWindowEvents();
  }

  final String siteKey;
  @override
  final bool isLocalBypass;
  final String _containerId;
  final String _viewType;
  final html.DivElement _element = html.DivElement()
    ..style.width = '100%'
    ..style.minHeight = '68px'
    ..style.display = 'block';

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
  String? _statusMessage;

  @override
  bool get isEnabled => siteKey.trim().isNotEmpty;

  @override
  bool get isLoading => _isLoading;

  @override
  bool get isReady => isLocalBypass || _isRendered;

  @override
  String? get token => _token;

  @override
  String? get statusMessage => _statusMessage;

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
        _statusMessage = null;
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
        _statusMessage = 'Bezpečnostný token expiroval. Overenie sa obnovuje.';
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
        _statusMessage =
            'Antibot ochrana sa nepodarila načítať. Obnov stránku a skús to znova.';
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
  void ensureRendered() {
    if (_isDisposed || isLocalBypass || !isEnabled || _isRendered) {
      return;
    }

    _element.id = _containerId;
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

    final rendered = helper.callMethod('render', [_containerId, siteKey]) == true;

    if (rendered) {
      _isRendered = true;
      _isLoading = false;
      _statusMessage = null;
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
      _statusMessage =
          'Antibot ochrana sa nepodarila načítať. Obnov stránku a skús to znova.';
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

    final token = helper.callMethod('getToken', [_containerId])?.toString() ?? '';
    final normalizedToken = token.trim();

    if (normalizedToken.isNotEmpty && normalizedToken != (_token ?? '')) {
      _token = normalizedToken;
      _statusMessage = null;
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
    return HtmlElementView(viewType: widget.controller._viewType);
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
