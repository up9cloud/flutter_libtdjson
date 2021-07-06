import 'package:get_it/get_it.dart' show GetIt;

import 'navigation_service.dart' show NavigationService;
import 'telegram_service.dart' show TelegramService;

export 'log_service.dart' show LogService;
export 'navigation_service.dart' show NavigationService;
export 'telegram_service.dart' show TelegramService;

void registerAll() {
  final GetIt g = GetIt.instance;
  g.registerLazySingleton(() => NavigationService());
  g.registerSingleton(TelegramService());
}
