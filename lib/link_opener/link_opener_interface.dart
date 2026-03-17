abstract class LinkOpener {
  Future<bool> openExternalUrl(
    String url, {
    String target,
  });

  Future<bool> openMailto({
    required String email,
    String? subject,
    String? body,
  });

  Future<bool> downloadPath(
    String path, {
    String? suggestedFileName,
  });
}
