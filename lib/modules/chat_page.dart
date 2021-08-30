import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cupet/blocs/user_bloc.dart';
import 'package:cupet/models/chat_users.dart';
import 'package:cupet/screens/chats/components/chat.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<ChatUsers> chatUsers = [
    ChatUsers(
        text: 'Kai',
        secondaryText: 'Awesome Setup',
        image: 'assets/images/chat_image1.jpg',
        time: 'Now'),
    ChatUsers(
        text: 'Zero',
        secondaryText: "That's Great",
        image: 'assets/images/chat_image2.jpg',
        time: 'Yesterday'),
    ChatUsers(
        text: 'Inu',
        secondaryText: 'Hey where are you?',
        image: 'assets/images/chat_image3.jpg',
        time: '31 Mar'),
    ChatUsers(
        text: 'Tan',
        secondaryText: 'Busy! Call me in 20 mins',
        image: 'assets/images/chat_image4.jpg',
        time: 'Now'),
    ChatUsers(
        text: 'Gom',
        secondaryText: "Thank you, It's awesome",
        image: 'assets/images/chat_image5.png',
        time: '23 Mar'),
  ];
  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserBloc>(context);

    return Scaffold(
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 70, left: 16, right: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey.shade600,
                    size: 26,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade300,
                  contentPadding: EdgeInsets.all(8),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.grey.shade100),
                  ),
                ),
              ),
            ),
            ListView.builder(
              // itemCount: chatUsers.length,
              itemCount: userData.likedImages.length,
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 16),
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final id = userData.likedImages[index];
                return FutureBuilder<DocumentSnapshot>(
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return SizedBox();
                    }
                    final receiverUserData = snapshot.data.data();
                    final likedUsersLikedList =
                        (receiverUserData['likedImages'] ?? []) as List;
                    if (likedUsersLikedList.contains(userData.userID)) {
                      return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('chats')
                            .where(
                          'senderReceiverID',
                          whereIn: [
                            '${userData.userID}-${id}',
                            '${id}-${userData.userID}'
                          ],
                        ).snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (!snapshot.hasData) {
                            return SizedBox();
                          }
                          final res = snapshot.data.docs.first.data();
                          int diffInDays;
                          DateTime timeInDateTime;
                          if (res['lastMessageTime'] != null) {
                            diffInDays = DateTime.now()
                                .difference(
                                    (res['lastMessageTime'] as Timestamp)
                                        .toDate())
                                .inDays;
                            // final diffInDuration = DateTime.now().difference(
                            //   (res['lastMessageTime'] as Timestamp).toDate(),
                            // );
                            timeInDateTime =
                                (res['lastMessageTime'] as Timestamp).toDate();
                          }
                          return ChatUsersList(
                            text: receiverUserData['firstName'],
                            secondaryText: res['lastMessage'] ?? '',
                            image: receiverUserData['imageUrl'],
                            time: res['lastMessageTime'] == null
                                ? 'New Match Made !'
                                : diffInDays >= 1 && diffInDays < 7
                                    ? DateFormat.EEEE().format(
                                        (res['lastMessageTime'] as Timestamp)
                                            .toDate(),
                                      )
                                    : diffInDays < 1
                                        ? DateFormat.Hm().format(timeInDateTime)
                                        : DateFormat('dd-MM-yyyy')
                                            .format(timeInDateTime),
                            isMessageRead: res['isLastMessageRead'] ?? false,
                            receiverID: id,
                            groupID: res['senderReceiverID'] ??
                                snapshot.data.docs.first.id,
                            groupData: res,
                            receiverData: receiverUserData,
                          );
                        },
                      );
                    }
                    return SizedBox();
                  },
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(id)
                      .get(),
                );
                return ChatUsersList(
                  text: chatUsers[index].text,
                  secondaryText: chatUsers[index].secondaryText,
                  image: chatUsers[index].image,
                  time: chatUsers[index].time,
                  isMessageRead: (index == 0 || index == 3) ? true : false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
