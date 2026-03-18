enum PortfolioActionFailure {
  linkOpenFailed,
  resumeMissing,
  resumeOpenFailed,
}

abstract interface class PortfolioActionService {
  Future<PortfolioActionFailure?> openEmail({
    required String subject,
  });

  Future<PortfolioActionFailure?> openExternalProfile(String url);

  Future<PortfolioActionFailure?> downloadResume();
}
