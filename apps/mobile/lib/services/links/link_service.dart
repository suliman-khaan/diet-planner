import 'package:url_launcher/url_launcher.dart';

/// Opens links and the user's email app. Feedback goes through their own email app, so the
/// app sends nothing itself.
abstract interface class LinkService {
  Future<bool> openUrl(String url);
  Future<bool> composeEmail({required String to, required String subject});
}

class NoopLinkService implements LinkService {
  const NoopLinkService();

  @override
  Future<bool> openUrl(String url) async => false;

  @override
  Future<bool> composeEmail(
          {required String to, required String subject}) async =>
      false;
}

class PlatformLinkService implements LinkService {
  const PlatformLinkService();

  @override
  Future<bool> openUrl(String url) =>
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

  @override
  Future<bool> composeEmail({required String to, required String subject}) =>
      launchUrl(Uri(
          scheme: 'mailto', path: to, queryParameters: {'subject': subject}));
}
