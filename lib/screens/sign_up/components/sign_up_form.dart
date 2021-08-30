import 'package:cupet/blocs/auth_bloc.dart';
import 'package:cupet/blocs/user_bloc.dart';
import 'package:cupet/components/custom_surfix_icon.dart';
import 'package:cupet/components/form_error.dart';
import 'package:cupet/screens/complete_profile/complete_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../../../constants.dart';
import '../../../size_config.dart';

class SignUpForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  String email;
  String password;
  String conform_password;
  bool remember = false;
  final List<String> errors = [];
  final _btnController = RoundedLoadingButtonController();

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

  Future<bool> register() async {
    final authBloc = Provider.of<AuthBloc>(context, listen: false);

    setState(() {
      isLoading = true;
    });
    // start loading the button
    _btnController.start();

    final result =
        await authBloc.register(email: email.trim(), password: password);
    if (result == 'ok') {
      final userBloc = Provider.of<UserBloc>(context, listen: false);
      // show success check mark
      _btnController.success();
      userBloc.userID = authBloc.currUserID;
      await userBloc.createUserFirestore(email: email.trim());
      // delay to show success check mark
      await Future.delayed(Duration(milliseconds: 500));
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
          buildConformPassFormField(),
          FormError(errors: errors),
          SizedBox(height: getProportionateScreenHeight(40)),
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
                final result = await register();
                if (!result) {
                  return;
                }
                // if all are valid then go to success screen

                Navigator.pushNamedAndRemoveUntil(
                    context, CompleteProfileScreen.routeName, (route) => false);
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
          // Old button:
          // DefaultButton(
          //   text: "Continue",
          //   press: () {
          // if (isLoading) {
          //     return;
          //   }
          //     if (_formKey.currentState.validate()) {
          //       _formKey.currentState.save();
          // final result = await register();
          //       if (!result) {
          //         return;
          //       }
          //       // if all are valid then go to success screen
          //       Navigator.pushNamed(context, CompleteProfileScreen.routeName);
          //     }
          //   },
          // ),
        ],
      ),
    );
  }

  TextFormField buildConformPassFormField() {
    return TextFormField(
      obscureText: true,
      onSaved: (newValue) => conform_password = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kPassNullError);
        } else if (value.isNotEmpty && password == conform_password) {
          removeError(error: kMatchPassError);
        }
        conform_password = value;
      },
      validator: (value) {
        if (value.isEmpty) {
          addError(error: kPassNullError);
          return "";
        } else if ((password != value)) {
          addError(error: kMatchPassError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Confirm Password",
        hintText: "Re-enter your password",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Lock.svg"),
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
        password = value;
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
