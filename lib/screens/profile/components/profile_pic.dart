import 'package:cupet/blocs/user_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePic extends StatelessWidget {
  const ProfilePic({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userBloc = Provider.of<UserBloc>(context);

    return SizedBox(
      height: 150,
      width: 150,
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
                image: userBloc.imageUrl != null
                    ? NetworkImage(userBloc.imageUrl)
                    : AssetImage('assets/images/profile_image.jpg'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
