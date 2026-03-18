part of 'app_localizations.dart';

final class SlovakAppLocalizations extends AppLocalizations {
  const SlovakAppLocalizations() : super(const Locale('sk'));

  @override
  String get browserTitle => 'Dávid Schwartz | Frontendový vývojár';

  @override
  String get portfolioBadge => 'Portfólio';

  @override
  String heroGreeting(String name) => 'Dobrý deň, som $name';

  @override
  String get contactCtaLabel => 'Kontakt';

  @override
  String get resumeCtaLabel => 'Stiahnuť CV';

  @override
  String get focusSectionTitle => 'Čomu sa venujem';

  @override
  String get focusSectionSubtitle =>
      'Od návrhu UI/UX po frontend architektúru, integrácie a nasadenie.';

  @override
  String get techStackTitle => 'Technologický stack';

  @override
  String get techStackSubtitle =>
      'Nástroje a technológie, s ktorými pracujem denne.';

  @override
  String get experienceSectionTitle => 'Skúsenosti';

  @override
  String get experienceSectionSubtitle =>
      'Stručný prehľad môjho posledného profesionálneho obdobia.';

  @override
  String get chatSectionSubtitle =>
      'Opýtajte sa na skúsenosti, technológie, projekty alebo spoluprácu.';

  @override
  String get contactSectionTitle => 'Poďme spolu niečo vytvoriť';

  @override
  String get contactSectionSubtitle =>
      'Ak riešite web, aplikáciu, redizajn alebo výkon frontendu, rád sa o tom porozprávam.';

  @override
  String get contactMailSubject => 'Záujem o spoluprácu cez portfólio';

  @override
  String get linkOpenFailedMessage => 'Odkaz sa nepodarilo otvoriť.';

  @override
  String get resumeMissingMessage =>
      'Pre sťahovanie CV stačí pridať súbor assets/cv.pdf.';

  @override
  String get resumeOpenFailedMessage => 'CV sa nepodarilo otvoriť.';

  @override
  String get vibeCodedNote => 'Táto stránka bola celá vibe coded.';

  @override
  String get chatLauncherOpen => 'Otvoriť chat';

  @override
  String get chatLauncherClose => 'Zavrieť chat';

  @override
  String get chatStatusSending => 'odpovedá';

  @override
  String get chatCloseButton => 'Zavrieť chat';

  @override
  String get chatIntroLineOne =>
      'Dobrý deň, odpovedám ako agent portfólia Dávida Schwartza.';

  @override
  String get chatIntroLineTwo =>
      'Môžete sa opýtať na skúsenosti, technologický stack, projekty alebo spoluprácu.';

  @override
  String get chatNeedsBackendEndpoint =>
      'Chat potrebuje backend endpoint. Spustite aplikáciu s parametrom --dart-define=CHAT_API_URL=...';

  @override
  String get chatProtectionMisconfigured =>
      'Ochrana chatu nie je správne nakonfigurovaná. Chýba TURNSTILE_SITE_KEY.';

  @override
  String get chatVerificationFailed =>
      'Bezpečnostné overenie zlyhalo. Skúste to, prosím, ešte raz.';

  @override
  String get chatMissingApiUrl =>
      'Chýba CHAT_API_URL. Bez backend endpointu nie je možné volať AI službu.';

  @override
  String get chatUnlockFirstError =>
      'Pred odoslaním správy najprv odomknite chat.';

  @override
  String get chatTypingMessage => 'Agent pripravuje odpoveď...';

  @override
  String get chatProviderTimeout =>
      'AI služba neodpovedala včas. Skúste to, prosím, ešte raz.';

  @override
  String get chatUnexpectedError =>
      'Pri volaní AI služby nastala neočakávaná chyba.';

  @override
  String get chatUnlockedForSession => 'Chat je pre túto reláciu odomknutý.';

  @override
  String get chatFinishingVerification =>
      'Dokončuje sa bezpečnostné overenie...';

  @override
  String get chatUnlockBeforeFirstMessage =>
      'Pred prvou správou odomknite chat jedným overením.';

  @override
  String get chatUnlockWaiting => 'Čakajte...';

  @override
  String get chatUnlockButton => 'Odomknúť chat';

  @override
  String get chatInputHintMissingApi => 'Spustite aplikáciu s CHAT_API_URL';

  @override
  String get chatInputHintUnlockFirst => 'Najprv odomknite chat';

  @override
  String get chatInputHint => 'Napíšte správu...';

  @override
  String get profileContextNameLabel => 'Meno';

  @override
  String get profileContextRoleLabel => 'Rola';

  @override
  String get profileContextLocationLabel => 'Lokalita';

  @override
  String get profileContextBioLabel => 'Profil';

  @override
  String get profileContextContactLabel => 'Kontakt';

  @override
  String get profileContextStatsLabel => 'Štatistiky';

  @override
  String get profileContextInternalNotesLabel => 'Interný kontext';

  @override
  String get chatApiUrlInvalid => 'CHAT_API_URL nie je platná URL adresa.';

  @override
  String get chatFirewallBlocked =>
      'Vercel Firewall blokuje chat API challenge stránkou. Vo Vercel projekte nastavte Bot Protection na Log Only alebo vytvorte Bypass rule pre /api/chat a /api/chat/unlock.';

  @override
  String chatBackendReturnedNonJsonError(int statusCode) {
    return 'Backend vrátil chybu ($statusCode), ale nie vo formáte JSON.';
  }

  @override
  String get chatBackendInvalidJson => 'Backend vrátil neplatnú JSON odpoveď.';

  @override
  String get chatBackendInvalidResponse => 'Backend vrátil neplatnú odpoveď.';

  @override
  String chatBackendProxyError(int statusCode) {
    return 'Backend chat proxy vrátil chybu ($statusCode).';
  }

  @override
  String chatBackendConnectionError(String uri) {
    return 'Nepodarilo sa spojiť s chat backendom na $uri. Skontrolujte, či backend beží a či endpoint povoľuje CORS.';
  }

  @override
  String get chatBackendMissingReply => 'Backend nevrátil textovú odpoveď.';
}
