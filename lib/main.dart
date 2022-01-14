//Packages
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:messenger_app/pages/registration_page.dart';
import 'package:provider/provider.dart';
import './firebase_options.dart';
//Providers
import './providers/authentication_provider.dart';
//Services
import './services/navigation_service.dart';
//Pages
import './pages/splash_page.dart';
import './pages/login_page.dart';
import './pages/home_page.dart';

void main() {
  runApp(SplashPage(
    key: UniqueKey(),
    onInitializationComplete: () {
      runApp(MainApp());
    },
  ));
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthenticationProvider>(create: (context) {
          return AuthenticationProvider();
        })
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Messenger',
        theme: ThemeData(
          backgroundColor: Colors.grey[250],
          scaffoldBackgroundColor: Colors.grey[250],
          primarySwatch: Colors.blue,
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.black54,
          ),
        ),
        navigatorKey: NavigationService.navigatorKey,
        initialRoute: '/login',
        routes: {
          '/login': (ctx) => LoginPage(),
          '/registration': (ctx) => RegistrationPage(),
          '/home': (ctx) => HomePage(),
        },
      ),
    );
  }
}
