import 'package:flutter/material.dart';
import 'package:media_house/app/provider/content_provider.dart';
import 'package:media_house/app/provider/graphProvider.dart';
import 'package:media_house/app/provider/mediaHouseProvider.dart';
import 'package:media_house/app/provider/settelementProvider.dart';
import 'package:media_house/app/provider/shorts_provider.dart';
import 'package:media_house/app/provider/themeProvider.dart';
import 'package:media_house/app/provider/ticketProvider.dart';
import 'package:media_house/app/provider/user_provider.dart';
import 'package:media_house/app/provider/videoProvider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/config/routes/routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Check theme preference
  final themeBool = prefs.getBool("isDark") ?? true;

  // Initialize Firebase

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(isDark: themeBool),
        ),
        ChangeNotifierProvider(
          create: (context) => UserProvider(),
        ),
        ChangeNotifierProvider(create: (_) => ContentProvider()),
        ChangeNotifierProvider(create: (_) => MediaHouseProvider()),
        ChangeNotifierProvider(create: (_) => VideoProvider()),
        ChangeNotifierProvider(create: (_) => TicketProvider()),
        ChangeNotifierProvider(create: (_) => SettelementProvider()),
        ChangeNotifierProvider(create: (_) => GraphProvider()),
        ChangeNotifierProvider(create: (_) => ShortProvider()),
      ],
      child: MyApp(),
    ),
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'OTT Media House',
      theme: themeProvider.getTheme,
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      // Navigate based on login state
      initialRoute: "/",
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
// latest code
