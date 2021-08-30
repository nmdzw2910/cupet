import 'package:cupet/blocs/auth_bloc.dart';
import 'package:cupet/blocs/user_bloc.dart';
import 'package:cupet/constants.dart';
import 'package:cupet/helper/keyboard.dart';
import 'package:cupet/helper/utils.dart';
import 'package:cupet/size_config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'otp_form.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  @override
  void initState() {
    super.initState();
    sendVerificationCode();
  }

  void sendVerificationCode() {
    final userBloc = Provider.of<UserBloc>(context, listen: false);
    final authBloc = Provider.of<AuthBloc>(context, listen: false);
    String phoneNumber = userBloc.phoneNumber;
    console('Sent verify Req!');
    authBloc.verifyPhone(phoneNumber, context);
  }

  void showInvalidNumberDialog(BuildContext context) {
    final userBloc = Provider.of<UserBloc>(context);

    // set up the button
    Widget okButton = FlatButton(
      child: Text('OK'),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
        KeyboardUtil.hideKeyboard(context);
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text('Invalid phone number'),
      content: Text('${userBloc.phoneNumber} is not a valid phone number!'),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final userBloc = Provider.of<UserBloc>(context);
    final authBloc = Provider.of<AuthBloc>(context);
    String phoneNumber = userBloc.phoneNumber;
    phoneNumber = phoneNumber.substring(0, phoneNumber.length - 3) + '***';

    if (authBloc.hasInvalidPhoneNumber) {
      showInvalidNumberDialog(context);
      authBloc.hasInvalidPhoneNumber = false;
    }

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(20)),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: SizeConfig.screenHeight * 0.05),
              Text(
                "OTP Verification",
                style: headingStyle,
              ),
              Text("We sent your code to $phoneNumber"),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("This code will expired in "),
                  Text(
                    "00:${authBloc.remainingTimeInSeconds}",
                    style: TextStyle(color: kPrimaryColor),
                  ),
                ],
              ),
              OtpForm(),
              SizedBox(height: SizeConfig.screenHeight * 0.1),
              GestureDetector(
                onTap: () {
                  // OTP code resend
                  final authBloc =
                      Provider.of<AuthBloc>(context, listen: false);
                  if (authBloc.remainingTimeInSeconds == 0) {
                    sendVerificationCode();
                  }
                },
                child: Text(
                  "Resend OTP Code",
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Row buildTimer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("This code will expired in "),
        TweenAnimationBuilder(
          tween: Tween(begin: 30.0, end: 0.0),
          duration: Duration(seconds: 30),
          builder: (_, value, child) => Text(
            "00:${value.toInt()}",
            style: TextStyle(color: kPrimaryColor),
          ),
        ),
      ],
    );
  }
}
