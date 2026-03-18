import 'package:flutter/material.dart';

part 'app_localizations_en.dart';
part 'app_localizations_sk.dart';

abstract class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('sk'),
  ];

  static Locale normalizeLocale(Locale locale) {
    final languageCode = locale.languageCode.toLowerCase();
    if (languageCode.startsWith('sk')) {
      return const Locale('sk');
    }
    return const Locale('en');
  }

  static AppLocalizations of(BuildContext context) {
    return forLocale(Localizations.localeOf(context));
  }

  static AppLocalizations forLocale(Locale locale) {
    return switch (normalizeLocale(locale).languageCode) {
      'sk' => const SlovakAppLocalizations(),
      _ => const EnglishAppLocalizations(),
    };
  }

  String get chatSectionTitle => 'Chat';

  String get githubLinkLabel => 'GitHub';

  String get linkedInLinkLabel => 'LinkedIn';

  String get languageOptionSk => 'SK';

  String get languageOptionEn => 'EN';

  String get chatPanelTitle => 'Chat';

  String get chatStatusOnline => 'online';

  String get browserTitle;

  String get portfolioBadge;

  String heroGreeting(String name);

  String get contactCtaLabel;

  String get resumeCtaLabel;

  String get focusSectionTitle;

  String get focusSectionSubtitle;

  String get techStackTitle;

  String get techStackSubtitle;

  String get experienceSectionTitle;

  String get experienceSectionSubtitle;

  String get chatSectionSubtitle;

  String get contactSectionTitle;

  String get contactSectionSubtitle;

  String get contactMailSubject;

  String get linkOpenFailedMessage;

  String get resumeMissingMessage;

  String get resumeOpenFailedMessage;

  String get vibeCodedNote;

  String get chatLauncherOpen;

  String get chatLauncherClose;

  String get chatStatusSending;

  String get chatCloseButton;

  String get chatIntroLineOne;

  String get chatIntroLineTwo;

  String get chatNeedsBackendEndpoint;

  String get chatProtectionMisconfigured;

  String get chatVerificationFailed;

  String get chatMissingApiUrl;

  String get chatUnlockFirstError;

  String get chatTypingMessage;

  String get chatProviderTimeout;

  String get chatUnexpectedError;

  String get chatUnlockedForSession;

  String get chatFinishingVerification;

  String get chatUnlockBeforeFirstMessage;

  String get chatUnlockWaiting;

  String get chatUnlockButton;

  String get chatInputHintMissingApi;

  String get chatInputHintUnlockFirst;

  String get chatInputHint;

  String get profileContextNameLabel;

  String get profileContextRoleLabel;

  String get profileContextLocationLabel;

  String get profileContextBioLabel;

  String get profileContextContactLabel;

  String get profileContextStatsLabel;

  String get profileContextInternalNotesLabel;

  String get chatApiUrlInvalid;

  String get chatFirewallBlocked;

  String chatBackendReturnedNonJsonError(int statusCode);

  String get chatBackendInvalidJson;

  String get chatBackendInvalidResponse;

  String chatBackendProxyError(int statusCode);

  String chatBackendConnectionError(String uri);

  String get chatBackendMissingReply;
}
