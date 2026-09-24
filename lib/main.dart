import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velix_core/velix_core.dart';
import 'core/routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await VelixRealtimeService().initialize();
  runApp(
    const ProviderScope(
      child: VelixUserApp(),
    ),
  );
}

class VelixUserApp extends ConsumerWidget {
  const VelixUserApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appThemeModeProvider);
    final locale = ref.watch(appLocaleProvider);

    return MaterialApp.router(
      title: 'Velix - User App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
        Locale('yo'),
        Locale('ha'),
        Locale('ig'),
      ],
      localizationsDelegates: const [
        VelixLocalizationsDelegate(),
      ],
      routerConfig: userAppRouter,
    );
  }
}
