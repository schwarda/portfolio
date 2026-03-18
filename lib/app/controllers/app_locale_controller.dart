import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';

class AppLocaleController extends ChangeNotifier {
  AppLocaleController(Locale initialLocale)
      : _locale = AppLocalizations.normalizeLocale(initialLocale);

  Locale _locale;

  Locale get locale => _locale;

  void updateLocale(Locale locale) {
    final normalized = AppLocalizations.normalizeLocale(locale);
    if (_locale == normalized) {
      return;
    }

    _locale = normalized;
    notifyListeners();
  }
}

class AppLocaleScope extends InheritedNotifier<AppLocaleController> {
  const AppLocaleScope({
    super.key,
    required AppLocaleController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppLocaleController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppLocaleScope>();
    assert(scope != null, 'Missing AppLocaleScope in widget tree.');
    return scope!.notifier!;
  }
}
