import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cupet/helper/utils.dart';
import 'package:flutter/material.dart';

class UserBloc with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String userEmail;
  String userID;
  String firstName;
  String lastName;
  String phoneNumber;
  String address;

  String imageUrl;
  String petName;
  String type;
  String breed;
  String location;
  String description;

  List likedImages = [];
  List dislikedImages = [];

  bool hasCompletedProfile = false;

  Future<void> checkForMatch(String uid) async {
    final userData =
        (await FirebaseFirestore.instance.collection('users').doc(uid).get())
            .data();
    if (((userData['likedImages'] ?? []) as List).contains(userID)) {
      console('Has Match !');
      await FirebaseFirestore.instance
          .collection('chats')
          .doc('${userID}-${uid}')
          .set({
        'senderReceiverID': '${userID}-${uid}',
      });
      notifyListeners();
    }
  }

  Future<void> likeImage(String uid) async {
    likedImages.add(uid);
    checkForMatch(uid);
    await FirebaseFirestore.instance.collection('users').doc(userID).set(
      {
        'likedImages': FieldValue.arrayUnion([uid]),
      },
      SetOptions(merge: true),
    );
    notifyListeners();
  }

  Future<void> dislikeImage(String uid) async {
    dislikedImages.add(uid);
    await FirebaseFirestore.instance.collection('users').doc(userID).set(
      {
        'dislikedImages': FieldValue.arrayUnion([uid]),
      },
      SetOptions(merge: true),
    );
    notifyListeners();
  }

  void rerenderListeners() {
    notifyListeners();
  }

  Future<void> logout() async {
    userEmail = null;
    userID = null;
    firstName = null;
    lastName = null;
    phoneNumber = null;
    address = null;

    imageUrl = null;
    petName = null;
    type = null;
    breed = null;
    location = null;
    description = null;

    likedImages = [];
    dislikedImages = [];

    hasCompletedProfile = false;
  }

  Future<void> completeProfile(
      // @required String firstName,
      // @required String lastName,
      // @required String phoneNumber,
      // @required String address,
      ) async {
    // hasCompletedProfile = true;
    // firstName = firstName;
    // lastName = lastName;
    // phoneNumber = phoneNumber;
    // address = address;

    await _db.collection('users').doc(userID).update({
      'completedProfile': true,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'address': address,
    });
  }

  Future<void> createUserFirestore({@required String email}) async {
    // Create user in firebase 'users' collection here
    userEmail = email;
    await _db.collection('users').doc(userID).set({
      'email': email,
      'completedProfile': false,
    });
  }

  Future<void> getUserDetailsFirebase() async {
    // Get user details from firebase 'users' collection here
    final userData = (await _db.collection('users').doc(userID).get()).data();
    if (userData['completedProfile'] ?? false) {
      hasCompletedProfile = true;
      firstName = userData['firstName'];
      lastName = userData['lastName'];
      phoneNumber = userData['phoneNumber'];
      address = userData['address'];
      userEmail = userData['email'];

      imageUrl = userData['imageUrl'];
      petName = userData['petName'];
      type = userData['type'];
      breed = userData['breed'];
      location = userData['location'];
      description = userData['description'];

      likedImages = userData['likedImages'] ?? [];
      dislikedImages = userData['dislikedImages'] ?? [];
    } else {
      hasCompletedProfile = false;
      userEmail = userData['email'];
    }
  }
}
