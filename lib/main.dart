import 'package:cupet/blocs/auth_bloc.dart';
import 'package:cupet/blocs/user_bloc.dart';
import 'package:cupet/routes.dart';
import 'package:cupet/screens/real_splash/splash_screen.dart';
import 'package:cupet/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ✅ 1. authentication
// ✅ 2. edit user profile
// 3. Chatting
// 4. matching
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => AuthBloc()),
        ChangeNotifierProvider(create: (ctx) => UserBloc()),
        // ChangeNotifierProvider(create: (context) => di.sl<ThemeProvider>()),
        // ChangeNotifierProvider(create: (context) => di.sl<SplashProvider>()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cupet',
      theme: theme(),
      // home: SplashScreen(),
      // We use routeName so that we dont need to remember the name
      initialRoute: RealSplashScreen.routeName,
      routes: routes,
    );
  }
}
