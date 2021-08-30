import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cupet/blocs/user_bloc.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final petNameController = TextEditingController();
  final typeController = TextEditingController();
  final breedController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();
  File _image;
  var data;
  bool _loading = false;
  Future getImage() async {
    final image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
  }

  Future<String> uploadImage(var imageFile, String uId) async {
    Reference ref = FirebaseStorage.instance.ref().child('user/$uId/photo.jpg');
    await ref.putFile(_image);
    var downloadUrl = await ref.getDownloadURL();
    return downloadUrl.toString();
  }

  @override
  Widget build(BuildContext context) {
    final userBloc = Provider.of<UserBloc>(context);
    return ModalProgressHUD(
      inAsyncCall: _loading,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          vertical: 40,
          horizontal: 35,
        ),
        child: Column(
          children: [
            SizedBox(
              height: 120,
              width: 120,
              child: Stack(
                fit: StackFit.expand,
                overflow: Overflow.visible,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                          width: 3,
                          color: Colors.deepOrange,
                        ),
                        boxShadow: [
                          BoxShadow(
                              spreadRadius: 3,
                              blurRadius: 10,
                              color: Colors.black.withOpacity(0.3),
                              offset: Offset(0, 5)),
                        ],
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: _image == null
                              ? userBloc.imageUrl != null
                                  ? NetworkImage(userBloc.imageUrl)
                                  : AssetImage(
                                      'assets/images/profile_image.jpg',
                                    )
                              : FileImage(_image),
                        )),
                  ),
                  Positioned(
                    width: 50,
                    height: 50,
                    right: -10,
                    bottom: -10,
                    child: RaisedButton(
                      padding: EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 0,
                      ),
                      onPressed: getImage,
                      color: Colors.indigo,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0),
                          side: BorderSide(color: Colors.indigo)),
                      child: Icon(
                        Icons.edit,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: SizedBox(
                height: 50,
              ),
            ),
            buildTextField(
              'Pet Name',
              'Pet Name',
              null,
              controller: petNameController,
            ),
            buildTextField(
              'Type',
              'Type',
              null,
              controller: typeController,
            ),
            buildTextField(
              'Breed',
              'Breed',
              null,
              controller: breedController,
            ),
            buildTextField(
              'Location',
              'Location',
              null,
              controller: locationController,
            ),
            buildTextField(
              'Description',
              'Tell something about the pet',
              500,
              controller: descriptionController,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlineButton(
                  padding: EdgeInsets.symmetric(horizontal: 39),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    'CANCEL',
                    style: TextStyle(
                        fontSize: 17, letterSpacing: 2.2, color: Colors.black),
                  ),
                ),
                RaisedButton(
                  padding: EdgeInsets.symmetric(horizontal: 39),
                  onPressed: () async {
                    ///////////////////////////////////////
                    setState(() {
                      _loading = true;
                    });
                    final Map<String, dynamic> updateData = {};

                    if (_image != null) {
                      // await uploadImage(_image, _image.path)
                      await uploadImage(
                              _image,
                              Provider.of<UserBloc>(context, listen: false)
                                  .userID)
                          .then((value) async {
                        //String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);

                        updateData['imageUrl'] = value;
                        userBloc.imageUrl = value;
                        await FirebaseFirestore.instance
                            .collection('Images')
                            .doc(userBloc.userID)
                            .set({
                          'imageUrl': value,
                          'time': DateTime.now(),
                          'uid': Provider.of<UserBloc>(context, listen: false)
                              .userID,
                        });
                      });
                    }
                    if (petNameController.text.trim().isNotEmpty) {
                      updateData['petName'] = petNameController.text.trim();
                      userBloc.petName = petNameController.text.trim();
                    }
                    if (typeController.text.trim().isNotEmpty) {
                      updateData['type'] = typeController.text.trim();
                      userBloc.type = typeController.text.trim();
                    }
                    if (breedController.text.trim().isNotEmpty) {
                      updateData['breed'] = breedController.text.trim();
                      userBloc.breed = breedController.text.trim();
                    }
                    if (locationController.text.trim().isNotEmpty) {
                      updateData['location'] = locationController.text.trim();
                      userBloc.location = locationController.text.trim();
                    }
                    if (descriptionController.text.trim().isNotEmpty) {
                      updateData['description'] =
                          descriptionController.text.trim();
                      userBloc.location = descriptionController.text.trim();
                    }
                    if (updateData.isNotEmpty) {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(Provider.of<UserBloc>(context, listen: false)
                              .userID)
                          .update(updateData);
                    }
                    userBloc.rerenderListeners();
                    setState(() {
                      _loading = false;
                    });
                    Navigator.of(context).pop();
                    //////////////////////////////////////////
                  },
                  color: Colors.indigo,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    'SAVE',
                    style: TextStyle(
                        fontSize: 17, letterSpacing: 2.2, color: Colors.white),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

Widget buildTextField(
  String labelText,
  String placeholder,
  int maxLength, {
  TextEditingController controller,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 30.0),
    child: TextFormField(
      controller: controller,
      cursorColor: Colors.black,
      maxLength: maxLength,
      decoration: InputDecoration(
          icon: Icon(Icons.pets_rounded),
          border: OutlineInputBorder(),
          labelText: labelText,
          labelStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.deepOrange,
          ),
          suffixIcon: Icon(
            Icons.check_circle,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: placeholder,
          hintStyle: TextStyle(
            fontSize: 15,
            color: Colors.grey.withOpacity(0.7),
          )),
    ),
  );
}

Widget buildTextField1(String labelText, String placeholder, int maxLength) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 30.0),
  );
}
