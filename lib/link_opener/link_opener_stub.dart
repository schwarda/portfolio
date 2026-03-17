import 'link_opener_interface.dart';

class _StubLinkOpener implements LinkOpener {
  @override
  Future<bool> downloadPath(
    String path, {
    String? suggestedFileName,
  }) async {
    return false;
  }

  @override
  Future<bool> openExternalUrl(
    String url, {
    String target = '_blank',
  }) async {
    return false;
  }

  @override
  Future<bool> openMailto({
    required String email,
    String? subject,
    String? body,
  }) async {
    return false;
  }
}

LinkOpener createLinkOpener() => _StubLinkOpener();
