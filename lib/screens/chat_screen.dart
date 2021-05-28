import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart'; //importing 하고 state에서 _auth instance를 생성시켜준다.
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;
User loggedInUser; //원래 FirebaseUser 였는데 버전이 바뀌고 User로 바뀜.

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController(); // enter 누르면 빈칸 주어짐
  final _auth = FirebaseAuth.instance;

  var messageText;

  //messageText랑 loggedInUser를 사용하여 데이터를 클라우드 파이어스토어로 보낸다.

  @override
  void initState() {
    super.initState();

    getCurrentUser();
  }

//밑에 새로운 method를 생성한다. this method doesn't take any inputs or have any outputs. BUt it wil check to see if
  // there is a current user who signed in.
  void getCurrentUser() async {
    try {
      final user = _auth.currentUser; // ()을 뺌
      if (user != null) {
        // this means that we have a currently signed in user
        loggedInUser = user; // in this case, we will create a new variable
      }
    } catch (e) {
      print(e);
    }
  }

  // void getMessages() async {
  //   final messages = await _firestore
  //       .collection('messages').get(); //get method get hold of all the messages inside the collection. get used to be getDocuments and deprecated. and docs used to be documents and deprecated now
  //   for (var message in messages.docs) {  // print out each message inside the list
  //     print(message.data()); //data() used to be data and now deprecated
  //     //and since message is a list, in order to vies individual items in a list, we use for loops
  //   }
  // }

  // void messagesStream() async {
  //   //dosn't take any inputs. use it to listen streams of messages from firebase
  //   await for (var snapshot in _firestore.collection('messages').snapshots()) {
  //     for (var message in snapshot.docs) {
  //       //snapshots returns streams not futures. By subscribing to stream, i will listen and be notified
  //       print(message
  //           .data); //save the result of the stream in something called snapshot
  //       //think of it as a lit
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
            MessagesStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messageTextController.clear();
                      _firestore.collection('messages').add({
                        'text': messageText,
                        'sender': loggedInUser.email,
                      }); //add 는 map 데이터이다.
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

class MessagesStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      //we are listening on our querysnapshots
      stream: _firestore
          .collection('messages')
          .snapshots(), //this is where our data comes from
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          //when there is no data
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        //if it does have data, we are going to use the data
        final messages = snapshot.data.docs
            .reversed; //this is how we access the data inside async snapshot
        List<MessageBubble> messageBubbles = [];
        for (var message in messages) {
          final messageText = message.get('text'); // 원래 data[] 였는데 get()으로 바뀜.
          final messageSender = message.get('sender');

          final currentUser = loggedInUser.email;

          final messageBubble = MessageBubble(
            sender: messageSender,
            text: messageText,
            isMe: currentUser == messageSender,
          );
          messageBubbles.add(messageBubble);
        }

        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: messageBubbles,
          ),
        ); //async snapshot contaning our querysnapshot from firebase. We access querysnapshot through the data property
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble({this.sender, this.text, this.isMe});

  final String sender;
  final String text;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            sender,
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.black54,
            ),
          ),
          Material(
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0))
                : BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
            elevation: 5.0,
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                text,
                style: TextStyle(
                  color: isMe
                      ? Colors.white
                      : Colors
                          .black, //is me is true, then color white, otherwise black
                  fontSize: 15.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
