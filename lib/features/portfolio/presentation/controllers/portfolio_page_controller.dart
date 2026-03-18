import 'package:flutter/foundation.dart';

class PortfolioPageController extends ChangeNotifier {
  bool _isMobileChatOpen = false;

  bool get isMobileChatOpen => _isMobileChatOpen;

  void toggleMobileChat() {
    _isMobileChatOpen = !_isMobileChatOpen;
    notifyListeners();
  }

  void closeMobileChat() {
    if (!_isMobileChatOpen) {
      return;
    }

    _isMobileChatOpen = false;
    notifyListeners();
  }
}
