part of 'app_localizations.dart';

final class EnglishAppLocalizations extends AppLocalizations {
  const EnglishAppLocalizations() : super(const Locale('en'));

  @override
  String get browserTitle => 'Dávid Schwartz | Frontend Developer';

  @override
  String get portfolioBadge => 'Portfolio';

  @override
  String heroGreeting(String name) => 'Hello, I am $name';

  @override
  String get contactCtaLabel => 'Contact';

  @override
  String get resumeCtaLabel => 'Download resume';

  @override
  String get focusSectionTitle => 'What I focus on';

  @override
  String get focusSectionSubtitle =>
      'From UI/UX design to frontend architecture, integrations, and deployment.';

  @override
  String get techStackTitle => 'Tech stack';

  @override
  String get techStackSubtitle =>
      'Tools and technologies I work with every day.';

  @override
  String get experienceSectionTitle => 'Experience';

  @override
  String get experienceSectionSubtitle =>
      'A concise overview of my recent professional experience.';

  @override
  String get chatSectionSubtitle =>
      'Ask about experience, technologies, projects, or collaboration.';

  @override
  String get contactSectionTitle => 'Let us build something together';

  @override
  String get contactSectionSubtitle =>
      'If you are working on a website, app, redesign, or frontend performance, I would be glad to discuss it.';

  @override
  String get contactMailSubject => 'Collaboration inquiry from portfolio';

  @override
  String get linkOpenFailedMessage => 'The link could not be opened.';

  @override
  String get resumeMissingMessage =>
      'To enable resume download, add the file assets/cv.pdf.';

  @override
  String get resumeOpenFailedMessage => 'The resume could not be opened.';

  @override
  String get vibeCodedNote => 'This site was fully vibe coded.';

  @override
  String get chatLauncherOpen => 'Open chat';

  @override
  String get chatLauncherClose => 'Close chat';

  @override
  String get chatStatusSending => 'replying';

  @override
  String get chatCloseButton => 'Close chat';

  @override
  String get chatIntroLineOne =>
      'Hello, this chat responds as Dávid Schwartz’s portfolio agent.';

  @override
  String get chatIntroLineTwo =>
      'You can ask about experience, tech stack, projects, or collaboration.';

  @override
  String get chatNeedsBackendEndpoint =>
      'The chat needs a backend endpoint. Start the app with --dart-define=CHAT_API_URL=...';

  @override
  String get chatProtectionMisconfigured =>
      'Chat protection is not configured correctly. TURNSTILE_SITE_KEY is missing.';

  @override
  String get chatVerificationFailed =>
      'Security verification failed. Please try again.';

  @override
  String get chatMissingApiUrl =>
      'CHAT_API_URL is missing. The AI service cannot be called without a backend endpoint.';

  @override
  String get chatUnlockFirstError =>
      'Please unlock the chat before sending a message.';

  @override
  String get chatTypingMessage => 'The agent is preparing a reply...';

  @override
  String get chatProviderTimeout =>
      'The AI service did not respond in time. Please try again.';

  @override
  String get chatUnexpectedError =>
      'An unexpected error occurred while calling the AI service.';

  @override
  String get chatUnlockedForSession => 'The chat is unlocked for this session.';

  @override
  String get chatFinishingVerification =>
      'Security verification is being completed...';

  @override
  String get chatUnlockBeforeFirstMessage =>
      'Unlock the chat with a single verification before sending the first message.';

  @override
  String get chatUnlockWaiting => 'Please wait...';

  @override
  String get chatUnlockButton => 'Unlock chat';

  @override
  String get chatInputHintMissingApi => 'Start the app with CHAT_API_URL';

  @override
  String get chatInputHintUnlockFirst => 'Unlock the chat first';

  @override
  String get chatInputHint => 'Write a message...';

  @override
  String get profileContextNameLabel => 'Name';

  @override
  String get profileContextRoleLabel => 'Role';

  @override
  String get profileContextLocationLabel => 'Location';

  @override
  String get profileContextBioLabel => 'Profile';

  @override
  String get profileContextContactLabel => 'Contact';

  @override
  String get profileContextStatsLabel => 'Stats';

  @override
  String get profileContextInternalNotesLabel => 'Internal context';

  @override
  String get chatApiUrlInvalid => 'CHAT_API_URL is not a valid URL.';

  @override
  String get chatFirewallBlocked =>
      'Vercel Firewall is blocking the chat API with a challenge page. In the Vercel project, set Bot Protection to Log Only or create a bypass rule for /api/chat and /api/chat/unlock.';

  @override
  String chatBackendReturnedNonJsonError(int statusCode) {
    return 'The backend returned an error ($statusCode), but not in JSON format.';
  }

  @override
  String get chatBackendInvalidJson => 'The backend returned invalid JSON.';

  @override
  String get chatBackendInvalidResponse =>
      'The backend returned an invalid response.';

  @override
  String chatBackendProxyError(int statusCode) {
    return 'The chat backend proxy returned an error ($statusCode).';
  }

  @override
  String chatBackendConnectionError(String uri) {
    return 'Could not connect to the chat backend at $uri. Check whether the backend is running and whether the endpoint allows CORS.';
  }

  @override
  String get chatBackendMissingReply =>
      'The backend did not return a text response.';
}
