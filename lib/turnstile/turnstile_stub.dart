import 'package:flutter/widgets.dart';

import 'turnstile_interface.dart';

class _StubTurnstileController extends TurnstileController {
  _StubTurnstileController({
    required this.isLocalBypass,
    required String siteKey,
  }) : _isEnabled = siteKey.trim().isNotEmpty;

  final bool _isEnabled;

  @override
  final bool isLocalBypass;

  @override
  bool get isEnabled => _isEnabled;

  @override
  bool get isLoading => false;

  @override
  bool get isReady => isLocalBypass || !_isEnabled;

  @override
  String? get statusMessage {
    if (isLocalBypass) {
      return null;
    }
    if (!_isEnabled) {
      return 'Turnstile nie je nakonfigurovaný.';
    }
    return 'Turnstile funguje iba vo web buildoch.';
  }

  @override
  String? get token => null;

  @override
  void ensureRendered() {}

  @override
  void reset() {}

  @override
  void close() {}
}

TurnstileController createTurnstileController({
  required String siteKey,
  required bool isLocalBypass,
}) {
  return _StubTurnstileController(
    isLocalBypass: isLocalBypass,
    siteKey: siteKey,
  );
}

Widget buildTurnstileView({
  required TurnstileController controller,
}) {
  return const SizedBox.shrink();
}
