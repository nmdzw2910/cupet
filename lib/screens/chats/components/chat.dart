import 'package:cupet/modules/chat_detail_page.dart';
import 'package:flutter/material.dart';

class ChatUsersList extends StatefulWidget {
  ChatUsersList({
    @required this.text,
    @required this.secondaryText,
    @required this.image,
    @required this.time,
    @required this.isMessageRead,
    @required this.groupID,
    @required this.receiverID,
    @required this.receiverData,
    @required this.groupData,
  });

  final String text;
  final String secondaryText;
  final String image;
  final String time;
  final bool isMessageRead;
  final String receiverID;
  final String groupID;
  final Map<String, dynamic> receiverData;
  final Map<String, dynamic> groupData;

  @override
  _ChatUsersListState createState() => _ChatUsersListState();
}

class _ChatUsersListState extends State<ChatUsersList> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return ChatDetailPage(
                groupID: widget.groupID,
                receiverID: widget.receiverID,
                groupData: widget.groupData,
                receiverData: widget.receiverData,
              );
            },
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundImage: NetworkImage(widget.image),
                    maxRadius: 30,
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(widget.text),
                          SizedBox(
                            height: 6,
                          ),
                          Text(
                            widget.secondaryText,
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              widget.time,
              style: TextStyle(
                  fontSize: 12,
                  color: widget.isMessageRead
                      ? Colors.deepOrange
                      : Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
