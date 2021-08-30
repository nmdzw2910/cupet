import 'package:cupet/blocs/auth_bloc.dart';
import 'package:cupet/blocs/user_bloc.dart';
import 'package:cupet/screens/account/account_screen.dart';
import 'package:cupet/screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'profile_menu.dart';
import 'profile_pic.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userBloc = Provider.of<UserBloc>(context);
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 70),
      child: Column(
        children: [
          ProfilePic(),
          SizedBox(height: 15),
          Align(
            alignment: Alignment.center,
            child: Text(
                '${userBloc.petName ?? 'Hank'}, ${userBloc.type ?? 'Dog'}/${userBloc.breed ?? 'Terrier'}',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Colors.indigo)),
          ),
          SizedBox(height: 20),
          ProfileMenu(
            text: 'Edit User Information',
            icon: 'assets/icons/User Icon.svg',
            press: () => Navigator.pushNamed(context, AccountScreen.routeName),
          ),
          ProfileMenu(
            text: 'Notifications',
            icon: 'assets/icons/Bell.svg',
            press: () {},
          ),
          ProfileMenu(
            text: 'Settings',
            icon: 'assets/icons/Settings.svg',
            press: () {},
          ),
          ProfileMenu(
            text: 'Help Center',
            icon: 'assets/icons/Question mark.svg',
            press: () {},
          ),
          ProfileMenu(
              text: 'Log Out',
              icon: 'assets/icons/Log out.svg',
              press: () async {
                final authBloc = Provider.of<AuthBloc>(context, listen: false);
                final userBloc = Provider.of<UserBloc>(context, listen: false);
                await authBloc.logout();
                await userBloc.logout();
                Navigator.pushNamedAndRemoveUntil(
                    context, SplashScreen.routeName, (route) => false);
              }),
        ],
      ),
    );
  }
}
