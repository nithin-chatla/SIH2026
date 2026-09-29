import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/disaster_data_service.dart';
import 'theme/app_theme.dart';
import 'screens/main_navigation_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FluviaApp());
}


class FluviaApp extends StatelessWidget {
  const FluviaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DisasterDataService()),
      ],
      child: MaterialApp(
        title: 'FLUVIA - Catchment-Aware Flash-Flood Intelligence',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MainNavigationShell(),
      ),
    );
  }
}

