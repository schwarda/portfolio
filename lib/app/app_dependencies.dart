import '../core/services/asset_loader.dart';
import '../features/chat/application/chat_controller.dart';
import '../features/chat/data/http_chat_repository.dart';
import '../features/chat/data/localized_profile_context_builder.dart';
import '../features/chat/domain/chat_repository.dart';
import '../features/chat/domain/profile_context_builder.dart';
import '../features/portfolio/application/portfolio_action_controller.dart';
import '../features/portfolio/data/link_portfolio_action_service.dart';
import '../features/portfolio/data/static_portfolio_content_repository.dart';
import '../features/portfolio/domain/portfolio_content_repository.dart';
import '../link_opener/link_opener.dart';
import '../turnstile/turnstile.dart';

class AppDependencies {
  AppDependencies({
    required this.portfolioContentRepository,
    required this.portfolioActionController,
    required ChatRepository chatRepository,
    required ProfileContextBuilder profileContextBuilder,
  })  : _chatRepository = chatRepository,
        _profileContextBuilder = profileContextBuilder;

  factory AppDependencies.create() {
    const contentRepository = StaticPortfolioContentRepository();
    final actionService = LinkPortfolioActionService(
      linkOpener: createLinkOpener(),
      assetLoader: const RootBundleAssetLoader(),
    );

    return AppDependencies(
      portfolioContentRepository: contentRepository,
      portfolioActionController: PortfolioActionController(actionService),
      chatRepository: const HttpChatRepository(),
      profileContextBuilder: const LocalizedProfileContextBuilder(
        contentRepository: contentRepository,
      ),
    );
  }

  final PortfolioContentRepository portfolioContentRepository;
  final PortfolioActionController portfolioActionController;
  final ChatRepository _chatRepository;
  final ProfileContextBuilder _profileContextBuilder;

  ChatController createChatController() {
    return ChatController(
      chatRepository: _chatRepository,
      profileContextBuilder: _profileContextBuilder,
      turnstileController: createTurnstileController(
        siteKey: _chatRepository.turnstileSiteKey,
        isLocalBypass: _chatRepository.isLocalHost,
      ),
    );
  }
}
