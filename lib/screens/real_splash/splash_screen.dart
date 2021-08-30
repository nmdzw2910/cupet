import 'package:cupet/blocs/auth_bloc.dart';
import 'package:cupet/blocs/user_bloc.dart';
import 'package:cupet/screens/complete_profile/complete_profile_screen.dart';
import 'package:cupet/screens/login_success/login_success_screen.dart';
import 'package:cupet/screens/real_splash/components/body.dart';
import 'package:cupet/screens/splash/splash_screen.dart';
import 'package:cupet/size_config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RealSplashScreen extends StatefulWidget {
  static String routeName = "/realSplash";

  @override
  _RealSplashScreenState createState() => _RealSplashScreenState();
}

class _RealSplashScreenState extends State<RealSplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authBloc = Provider.of<AuthBloc>(context, listen: false);
      final userBloc = Provider.of<UserBloc>(context, listen: false);
      if (authBloc.isLoggedIn) {
        userBloc.userID = authBloc.currUserID;
        await userBloc.getUserDetailsFirebase();
        if (userBloc.hasCompletedProfile) {
          Navigator.pushNamedAndRemoveUntil(
              context, LoginSuccessScreen.routeName, (route) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(
              context, CompleteProfileScreen.routeName, (route) => false);
        }
      } else {
        Navigator.pushNamedAndRemoveUntil(
            context, SplashScreen.routeName, (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // You have to call it on your starting screen

    SizeConfig().init(context);
    return Scaffold(
      body: Body(),
    );
  }
}
