import 'package:flutter/widgets.dart';

abstract class TurnstileController extends ChangeNotifier {
  bool get isEnabled;
  bool get isLocalBypass;
  bool get isReady;
  bool get isLoading;
  String? get token;
  String? get statusMessage;

  bool get hasValidToken => isLocalBypass || ((token ?? '').trim().isNotEmpty);

  void updateLocaleCode(String localeCode);
  void ensureRendered();
  void reset();
  void close();
}
