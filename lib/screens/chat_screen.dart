import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;
User loggedInUser;

class ChatScreen extends StatefulWidget {
  static String id = "chat_screen";
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final _auth = FirebaseAuth.instance;

  String message;
  final messageTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async{
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);

      }
    }
      catch(e){
        print(e);
      }
    }

  //for taking input on a button and not spontaneous
    // void getMessages() async{
    //   final message = await _firestore.collection('messages').get();
    //   for(var msg in message.docs){
    //     print(msg.data());
    //   }
    // }

  // void messagesStream() async{
  //   await for(var snapshot in _firestore.collection('messages').snapshots()){
  //     for (var msg in snapshot.docs){
  //       print(msg.data());
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
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
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        message = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      _firestore.collection('messages').add({
                        'sender' : loggedInUser.email,
                        'message' : message
                      });
                      messageTextController.clear();
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
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('messages').snapshots(),
        builder: (context,snapshot){
          if(!snapshot.hasData){
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.red,
              ),
            );
          }
          final messages = snapshot.data.docs.reversed;
          List<Messagebubble> messageWidgets = [];
          for(var message in messages){
            final messageText = message.data()['message'];
            final messageSender = message.data()['sender'];
            final currentUser = loggedInUser.email;
            final messageWidget = Messagebubble(
              sender: messageSender,
              message: messageText,
              isMe:currentUser == messageSender,
            );
            messageWidgets.add(messageWidget);
          }
          return Expanded(
            child: ListView(
              reverse: true,
              padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 20.0 ),
              children: messageWidgets,
            ),
          );
        }
    );
  }
}


class Messagebubble extends StatelessWidget {
  Messagebubble({this.message,this.sender,this.isMe});

  final String message;
  final String sender;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
          sender,
          style: TextStyle(
            fontSize: 12.0,
            color: Colors.black45,
          ),
      ),
          Material(
            borderRadius: isMe ? BorderRadius.only(
                topLeft:Radius.circular(30.0),
                bottomLeft: Radius.circular(30.0),
                bottomRight:Radius.circular(30.0)
            ) : BorderRadius.only(
                topRight:Radius.circular(30.0),
                bottomLeft: Radius.circular(30.0),
                bottomRight:Radius.circular(30.0)
            ),
            elevation: 5.0,
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0,horizontal: 20.0),
              child: Text(
                '$message',
                style: TextStyle(
                    fontSize: 15.0,
                  color: isMe ? Colors.white : Colors.lightBlueAccent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
