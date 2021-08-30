import 'package:cupet/blocs/auth_bloc.dart';
import 'package:cupet/blocs/user_bloc.dart';
import 'package:cupet/components/custom_surfix_icon.dart';
import 'package:cupet/components/form_error.dart';
import 'package:cupet/helper/keyboard.dart';
import 'package:cupet/screens/complete_profile/complete_profile_screen.dart';
import 'package:cupet/screens/forgot_password/forgot_password_screen.dart';
import 'package:cupet/screens/login_success/login_success_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../../../constants.dart';
import '../../../size_config.dart';

class SignForm extends StatefulWidget {
  @override
  _SignFormState createState() => _SignFormState();
}

class _SignFormState extends State<SignForm> {
  final _formKey = GlobalKey<FormState>();
  final _btnController = RoundedLoadingButtonController();

  String email;
  String password;
  bool remember = false;
  final List<String> errors = [];

  void addError({String error}) {
    if (!errors.contains(error))
      setState(() {
        errors.add(error);
      });
  }

  void removeError({String error}) {
    if (errors.contains(error))
      setState(() {
        errors.remove(error);
      });
  }

  bool isLoading = false;

  Future<bool> login() async {
    final authBloc = Provider.of<AuthBloc>(context, listen: false);

    setState(() {
      isLoading = true;
    });
    // start loading the button
    _btnController.start();

    final result =
        await authBloc.logIn(email: email.trim(), password: password);
    if (result == 'ok') {
      final userBloc = Provider.of<UserBloc>(context, listen: false);
      userBloc.userEmail = email.trim();
      userBloc.userID = authBloc.currUserID;
      await userBloc.getUserDetailsFirebase();

      // show success checnk mard
      _btnController.success();
      // delay to show success check mark
      await Future.delayed(Duration(milliseconds: 300));
      return true;
    } else {
      // Some error, show the error
      setState(() {
        isLoading = false;
      });
      addError(error: result);
      _btnController.reset();

      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          buildEmailFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildPasswordFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          Row(
            children: [
              Checkbox(
                value: remember,
                activeColor: kPrimaryColor,
                onChanged: (value) {
                  setState(() {
                    remember = value;
                  });
                },
              ),
              Text("Remember me"),
              Spacer(),
              GestureDetector(
                onTap: () => Navigator.pushNamed(
                    context, ForgotPasswordScreen.routeName),
                child: Text(
                  "Forgot Password",
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              )
            ],
          ),
          FormError(errors: errors),
          SizedBox(height: getProportionateScreenHeight(20)),
          RoundedLoadingButton(
            loaderSize: getProportionateScreenHeight(44),
            loaderStrokeWidth: 4,
            height: getProportionateScreenHeight(56),
            // width: double.infinity,
            width: MediaQuery.of(context).size.width -
                (getProportionateScreenWidth(20) * 2),
            borderRadius: isLoading
                ? MediaQuery.of(context).size.width -
                    (getProportionateScreenWidth(20) * 2) / 2
                : 20,

            animateOnTap: false,
            controller: _btnController,
            color: kPrimaryColor,
            onPressed: () async {
              if (isLoading) {
                return;
              }
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                final result = await login();
                if (!result) {
                  return;
                }
                // if all are valid then go to success screen

                KeyboardUtil.hideKeyboard(context);
                final userBloc = Provider.of<UserBloc>(context, listen: false);
                if (userBloc.hasCompletedProfile) {
                  Navigator.pushNamedAndRemoveUntil(
                      context, LoginSuccessScreen.routeName, (route) => false);
                } else {
                  Navigator.pushNamedAndRemoveUntil(context,
                      CompleteProfileScreen.routeName, (route) => false);
                }
              }
            },
            child: Text(
              'Continue',
              style: TextStyle(
                fontSize: getProportionateScreenWidth(18),
                color: Colors.white,
              ),
              maxLines: 1,
            ),
          ),
          // Old Flat button:
          // DefaultButton(
          //   text: "Continue",
          //   press: () {
          //     if (_formKey.currentState.validate()) {
          //       _formKey.currentState.save();
          //       // if all are valid then go to success screen

          //       KeyboardUtil.hideKeyboard(context);
          //       Navigator.pushNamed(context, LoginSuccessScreen.routeName);
          //     }
          //   },
          // ),
        ],
      ),
    );
  }

  TextFormField buildPasswordFormField() {
    return TextFormField(
      obscureText: true,
      onSaved: (newValue) => password = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kPassNullError);
        } else if (value.length >= 8) {
          removeError(error: kShortPassError);
        }
        return null;
      },
      validator: (value) {
        if (value.isEmpty) {
          addError(error: kPassNullError);
          return "";
        } else if (value.length < 8) {
          addError(error: kShortPassError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Password",
        hintText: "Enter your password",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Lock.svg"),
      ),
    );
  }

  TextFormField buildEmailFormField() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      onSaved: (newValue) => email = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kEmailNullError);
        } else if (emailValidatorRegExp.hasMatch(value)) {
          removeError(error: kInvalidEmailError);
        }
        return null;
      },
      validator: (value) {
        if (value.isEmpty) {
          addError(error: kEmailNullError);
          return "";
        } else if (!emailValidatorRegExp.hasMatch(value)) {
          addError(error: kInvalidEmailError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Email",
        hintText: "Enter your email",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Mail.svg"),
      ),
    );
  }
}
