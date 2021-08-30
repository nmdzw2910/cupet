import 'dart:async';

import 'package:cupet/blocs/user_bloc.dart';
import 'package:cupet/helper/utils.dart';
import 'package:cupet/screens/login_success/login_success_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthBloc with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Timer verifyPhoneTimer;
  int remainingTimeInSeconds = 60;

  bool hasInvalidPhoneNumber = false;
  String verificationId;

  get currUser => _auth.currentUser;
  get currUserID => _auth.currentUser.uid;
  get isLoggedIn => _auth.currentUser != null;

  Future<void> logout() async {
    verificationId = null;
    await _auth.signOut();
  }

  Future<String> logIn({
    @required String email,
    @required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return 'ok';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'Incorrect email or password provided';
      } else if (e.code == 'wrong-password') {
        return 'Incorrect email or password provided';
      } else {
        warn(e.toString());
        return e.code;
      }
    } catch (e) {
      warn(e);
      return e.code;
    }
  }

  void startVerifyTimer() {
    if (verifyPhoneTimer != null && verifyPhoneTimer.isActive) {
      return;
    }
    remainingTimeInSeconds = 60;
    verifyPhoneTimer = Timer.periodic(Duration(seconds: 1), (Timer) {
      remainingTimeInSeconds--;
      notifyListeners();
      if (remainingTimeInSeconds == 0) {
        verifyPhoneTimer.cancel();
      }
    });
  }

  Future<bool> verifyOTPCode(String code, BuildContext context) async {
    final _authCredential = await PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: code,
    );
    try {
      await _auth.currentUser.linkWithCredential(_authCredential);
      final userBloc = Provider.of<UserBloc>(context, listen: false);
      await userBloc.completeProfile();
      return true;
    } catch (e) {
      console(e);
      return false;
    }
  }

  Future<bool> sendEmailReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      console(e);
      return false;
    }
  }

  Future<void> verifyPhone(String number, BuildContext context) async {
    if (verifyPhoneTimer != null && verifyPhoneTimer.isActive) {
      return;
    }
    remainingTimeInSeconds = 60;
    notifyListeners();

    await _auth.verifyPhoneNumber(
      phoneNumber: '+${number.replaceAll('+', '')}',
      timeout: const Duration(seconds: 60),
      verificationCompleted: (phoneAuthCredential) async {
        console('===========');
        console('Completed !:');
        console(phoneAuthCredential);
        console('===========');
        try {
          await _auth.currentUser.linkWithCredential(phoneAuthCredential);
          final userBloc = Provider.of<UserBloc>(context, listen: false);
          await userBloc.completeProfile();
          Navigator.pushNamedAndRemoveUntil(
              context, LoginSuccessScreen.routeName, (route) => false);
        } catch (e) {}
      },
      verificationFailed: (error) {
        console('===========');
        console('Error');
        console(error);
        console('===========');
        if (error.code == 'invalid-phone-number') {
          console('The provided phone number is not valid.');
          hasInvalidPhoneNumber = true;
          notifyListeners();
        }
      },
      codeSent: (verificationId, forceResendingToken) {
        startVerifyTimer();

        console('===========');
        console('Code Sent:');
        console(verificationId);
        this.verificationId = verificationId;
        console(forceResendingToken);
        console('===========');
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Auto-resolution timed out...
        console('===========');
        this.verificationId = verificationId;

        console('Auto-resolution timed out...');
        console(verificationId);
        console('===========');
      },
    );
  }

  Future<String> register({
    @required String email,
    @required String password,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return 'ok';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak';
      } else if (e.code == 'email-already-in-use') {
        return 'Account already exists for that email';
      } else if (e.code == 'invalid-email') {
        return 'Invalid email';
      } else {
        warn(e.toString());
        return e.code;
      }
    } catch (e) {
      warn(e);
      return e.code;
    }
  }
}
