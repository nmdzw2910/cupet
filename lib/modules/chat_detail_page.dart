import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cupet/blocs/user_bloc.dart';
import 'package:cupet/models/chat_message.dart';
import 'package:cupet/models/send_menu_items.dart';
import 'package:cupet/screens/chats/components/chat_bubble.dart';
import 'package:cupet/screens/chats/components/chat_detail_page_appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum MessageType {
  Sender,
  Receiver,
}

class ChatDetailPage extends StatefulWidget {
  ChatDetailPage({
    @required this.receiverID,
    @required this.groupID,
    @required this.receiverData,
    @required this.groupData,
  });

  final String receiverID;
  final String groupID;
  final Map<String, dynamic> receiverData;
  final Map<String, dynamic> groupData;

  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final inputController = TextEditingController();
  final inputFocusNode = FocusNode();

  List<ChatMessage> chatMessage = [
    ChatMessage(message: "Hi Hank's mom", type: MessageType.Receiver),
    ChatMessage(message: 'Hope you are doin good!', type: MessageType.Receiver),
    ChatMessage(
        message: "Hello, We're good, what about you", type: MessageType.Sender),
    ChatMessage(
        message: "I'm fine, working from home", type: MessageType.Receiver),
    ChatMessage(message: 'Oh! Same here', type: MessageType.Sender),
    ChatMessage(message: 'Oh! Same here', type: MessageType.Sender),
    ChatMessage(message: 'Oh! Same here', type: MessageType.Sender),
    ChatMessage(message: 'Oh! Same here', type: MessageType.Sender),
    ChatMessage(message: 'Oh! Same here', type: MessageType.Sender),
    ChatMessage(message: 'Oh! Same here', type: MessageType.Sender),
    ChatMessage(message: 'Oh! Same here', type: MessageType.Sender),
    ChatMessage(message: 'Oh! Same here', type: MessageType.Sender),
    ChatMessage(message: 'Oh! Same here', type: MessageType.Sender),
    ChatMessage(message: 'Oh! Same here', type: MessageType.Sender),
    ChatMessage(message: 'Oh! Same here', type: MessageType.Sender),
    ChatMessage(message: 'Oh! Same here', type: MessageType.Sender),
  ];

  List<SendMenuItems> menuItems = [
    SendMenuItems(
        text: 'Photos & Videos', icons: Icons.image, color: Colors.amber),
    SendMenuItems(
        text: 'Document', icons: Icons.insert_drive_file, color: Colors.blue),
    SendMenuItems(text: 'Audio', icons: Icons.music_note, color: Colors.orange),
    SendMenuItems(
        text: 'Location', icons: Icons.location_on, color: Colors.green),
    SendMenuItems(text: 'Contact', icons: Icons.person, color: Colors.purple),
  ];

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserBloc>(context, listen: false);
    return Scaffold(
      appBar: ChatDetailPageAppBar(
        userImg: widget.receiverData['imageUrl'],
        userName: widget.receiverData['firstName'],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.groupID)
                  .collection('data')
                  .orderBy('time', descending: true)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    !snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final data = snapshot.data.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: data.length,
                  // shrinkWrap: true,
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  itemBuilder: (context, index) {
                    return ChatBubble(
                      // chatMessage: chatMessage[index],
                      chatMessage: ChatMessage(
                        message: data[index].data()['message'],
                        type: data[index].data()['sentBy'] == userData.userID
                            ? MessageType.Sender
                            : MessageType.Receiver,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Stack(
            children: [
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  padding: EdgeInsets.only(left: 16, bottom: 16, right: 16),
                  height: 100,
                  width: double.infinity,
                  color: Colors.white,
                  child: Row(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          showModal();
                        },
                        child: Container(
                          height: 45,
                          width: 45,
                          decoration: BoxDecoration(
                            color: Colors.blueGrey,
                            borderRadius: BorderRadius.circular(35),
                          ),
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      Expanded(
                        child: TextField(
                          onEditingComplete: () async {
                            final text = inputController.text.trim();
                            if (text.isEmpty) {
                              inputFocusNode.unfocus();
                              return;
                            }

                            inputFocusNode.unfocus();
                            inputController.clear();

                            await FirebaseFirestore.instance
                                .collection('chats')
                                .doc(widget.groupID)
                                .collection('data')
                                .doc()
                                .set({
                              'message': text,
                              'sentBy': userData.userID,
                              'time': FieldValue.serverTimestamp(),
                              'localTime': DateTime.now(),
                            });
                            await FirebaseFirestore.instance
                                .collection('chats')
                                .doc(widget.groupID)
                                .set(
                              {
                                'lastMessage': text,
                                'lastMessageTime': FieldValue.serverTimestamp(),
                              },
                              SetOptions(merge: true),
                            );
                          },
                          controller: inputController,
                          focusNode: inputFocusNode,
                          decoration: InputDecoration(
                            hintText: 'Type message...',
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  padding: EdgeInsets.only(right: 20, bottom: 30),
                  child: FloatingActionButton(
                    onPressed: () async {
                      final text = inputController.text.trim();
                      if (text.isEmpty) {
                        // inputFocusNode.unfocus();
                        return;
                      }

                      // inputFocusNode.unfocus();
                      inputController.clear();

                      await FirebaseFirestore.instance
                          .collection('chats')
                          .doc(widget.groupID)
                          .collection('data')
                          .doc()
                          .set({
                        'message': text,
                        'sentBy': userData.userID,
                        'time': FieldValue.serverTimestamp(),
                        'localTime': DateTime.now(),
                      });

                      await FirebaseFirestore.instance
                          .collection('chats')
                          .doc(widget.groupID)
                          .set(
                        {
                          'lastMessage': text,
                          'lastMessageTime': FieldValue.serverTimestamp(),
                        },
                        SetOptions(merge: true),
                      );
                    },
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                    backgroundColor: Colors.indigo,
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void showModal() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height / 2,
            color: Colors.deepOrange,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                ),
              ),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 16,
                  ),
                  Center(
                    child: Container(
                      height: 10,
                      width: 10,
                      color: Colors.grey.shade200,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ListView.builder(
                    itemCount: menuItems.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Container(
                        padding: EdgeInsets.only(top: 5, bottom: 5),
                        child: ListTile(
                          leading: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: menuItems[index].color.shade50,
                            ),
                            height: 100,
                            width: 100,
                            child: Icon(
                              menuItems[index].icons,
                              size: 20,
                              color: menuItems[index].color.shade400,
                            ),
                          ),
                          title: Text(menuItems[index].text),
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
          );
        });
  }
}
