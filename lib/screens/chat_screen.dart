import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';

class ChatScreen extends StatefulWidget {
  static const id = "ChatScreen";
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final msgTextController = TextEditingController();

  User currentUser;
  String messageText;
  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      print(currentUser.email);
    }
  }

  Future<void> addUser() {
    CollectionReference messages =
        FirebaseFirestore.instance.collection('messages');
    return messages
        .add(
          {
            'sender': currentUser.email,
            'text': messageText,
            'created': FieldValue.serverTimestamp(),
          },
        )
        .then(
          (value) => print(value),
        )
        .catchError(
          (error) => print(error),
        );
  }

  void getMessageStream() async {
    await for (QuerySnapshot snapshot
        in FirebaseFirestore.instance.collection('messages').snapshots()) {
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        String sender = doc.data()['sender'];
        String message = doc.data()['text'];
        print('$message from $sender');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                //Implement logout functionality
                FirebaseAuth.instance.signOut();
                Navigator.pop(context);
                // getMessageStream();
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(currentUser),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: msgTextController,
                      onChanged: (value) {
                        //Do something with the user input.
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      msgTextController.clear();
                      addUser();
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  MessageStream(this.currentUser);

  final User currentUser;

  void getListItems(QuerySnapshot snapshot) {
    for (QueryDocumentSnapshot doc in snapshot.docs) {
      String sender = doc.data()['sender'];
      String message = doc.data()['text'];
      print('$message from $sender');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('messages')
          .orderBy('created', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final messages = snapshot.data.docs;
        List<MessageBubble> messageBubbles = [];
        for (var message in messages) {
          final messageText = message.data()['text'];
          final messageSender = message.data()['sender'];

          final messageBubble = MessageBubble(
            sender: messageSender,
            message: messageText,
            isMe: currentUser.email == messageSender,
          );

          messageBubbles.add(messageBubble);
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: messageBubbles,
          ),
        );
        // return ListView.builder(
        //     reverse: true,
        //     padding: const EdgeInsets.all(8),
        //     itemCount:
        //         snapshot.data.docs != null ? snapshot.data.docs.length : 0,
        //     itemBuilder: (BuildContext context, int index) {
        //       List<QueryDocumentSnapshot> documents =
        //           snapshot.data.docs.reversed.toList();
        //       String sender = documents[index]['sender'] ?? "";
        //       String message = documents[index]['text'] ?? "";
        //       bool isMe = currentUser.email == sender;
        //       return MessageBubble(isMe: isMe, sender: sender, message: message);
        //     });
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    Key key,
    @required this.isMe,
    @required this.sender,
    @required this.message,
  }) : super(key: key);

  final bool isMe;
  final String sender;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 10.0, bottom: 5.0),
          child: Text(
            sender,
            style: TextStyle(fontSize: 12.0, color: Colors.black45),
          ),
        ),
        Material(
          color: isMe ? Colors.lightBlueAccent : Colors.white,
          borderRadius: isMe
              ? BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  bottomLeft: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0),
                )
              : BorderRadius.only(
                  bottomLeft: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
          elevation: 5.0,
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 10.0,
              horizontal: 20.0,
            ),
            child: Text(
              message,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
                fontSize: 15.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
