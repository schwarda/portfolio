import '../../../app/localization/app_localizations.dart';
import '../domain/portfolio_action_service.dart';

class PortfolioActionController {
  const PortfolioActionController(this._actionService);

  final PortfolioActionService _actionService;

  Future<String?> openEmail(AppLocalizations l10n) async {
    final failure = await _actionService.openEmail(
      subject: l10n.contactMailSubject,
    );
    return _messageForFailure(failure, l10n);
  }

  Future<String?> openExternalProfile({
    required String url,
    required AppLocalizations l10n,
  }) async {
    final failure = await _actionService.openExternalProfile(url);
    return _messageForFailure(failure, l10n);
  }

  Future<String?> downloadResume(AppLocalizations l10n) async {
    final failure = await _actionService.downloadResume();
    return _messageForFailure(failure, l10n);
  }

  String? _messageForFailure(
    PortfolioActionFailure? failure,
    AppLocalizations l10n,
  ) {
    switch (failure) {
      case null:
        return null;
      case PortfolioActionFailure.linkOpenFailed:
        return l10n.linkOpenFailedMessage;
      case PortfolioActionFailure.resumeMissing:
        return l10n.resumeMissingMessage;
      case PortfolioActionFailure.resumeOpenFailed:
        return l10n.resumeOpenFailedMessage;
    }
  }
}
