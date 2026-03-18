import '../../../core/constants/app_constants.dart';
import '../../../core/services/asset_loader.dart';
import '../../../link_opener/link_opener.dart';
import '../domain/portfolio_action_service.dart';

class LinkPortfolioActionService implements PortfolioActionService {
  const LinkPortfolioActionService({
    required LinkOpener linkOpener,
    required AssetLoader assetLoader,
    this.contactEmail = PortfolioLinks.contactEmail,
    this.resumeAssetPath = PortfolioAssets.resume,
    this.resumeDownloadPath = PortfolioAssets.resumeDownloadPath,
    this.resumeFileName = PortfolioAssets.resumeFileName,
  })  : _linkOpener = linkOpener,
        _assetLoader = assetLoader;

  final LinkOpener _linkOpener;
  final AssetLoader _assetLoader;
  final String contactEmail;
  final String resumeAssetPath;
  final String resumeDownloadPath;
  final String resumeFileName;

  @override
  Future<PortfolioActionFailure?> openEmail({
    required String subject,
  }) async {
    final opened = await _linkOpener.openMailto(
      email: contactEmail,
      subject: subject,
    );
    if (opened) {
      return null;
    }
    return PortfolioActionFailure.linkOpenFailed;
  }

  @override
  Future<PortfolioActionFailure?> openExternalProfile(String url) async {
    final opened = await _linkOpener.openExternalUrl(url);
    if (opened) {
      return null;
    }
    return PortfolioActionFailure.linkOpenFailed;
  }

  @override
  Future<PortfolioActionFailure?> downloadResume() async {
    final hasResume = await _assetLoader.exists(resumeAssetPath);
    if (!hasResume) {
      return PortfolioActionFailure.resumeMissing;
    }

    final opened = await _linkOpener.downloadPath(
      resumeDownloadPath,
      suggestedFileName: resumeFileName,
    );
    if (opened) {
      return null;
    }
    return PortfolioActionFailure.resumeOpenFailed;
  }
}
