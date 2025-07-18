import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fuel_delivery_app/generated/app_localizations.dart';

class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({Key? key}) : super(key: key);

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    if (currentUser == null) {
      // Handle case where user is not logged in, perhaps navigate to login
      return;
    }

    await _firestore.collection('support_chats').add({
      'text': _messageController.text.trim(),
      'senderId': currentUser!.uid,
      'senderEmail': currentUser!.email,
      'timestamp': Timestamp.now(),
    });
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.customerSupport),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('support_chats')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs.reversed.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return MessageBubble(
                    text: data['text'],
                    isMe: data['senderId'] == currentUser?.uid,
                    sender: data['senderEmail'],
                  );
                }).toList();

                return ListView(
                  reverse: false,
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                  children: messages,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: localizations.enterYourMessage,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  child: Icon(Icons.send),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    Key? key,
    required this.text,
    required this.isMe,
    required this.sender,
  }) : super(key: key);

  final String text;
  final bool isMe;
  final String? sender;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender ?? 'Unknown',
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.black54,
            ),
          ),
          Material(
            borderRadius: BorderRadius.only(
              topLeft: isMe ? const Radius.circular(30.0) : const Radius.circular(0.0),
              topRight: isMe ? const Radius.circular(0.0) : const Radius.circular(30.0),
              bottomLeft: const Radius.circular(30.0),
              bottomRight: const Radius.circular(30.0),
            ),
            elevation: 5.0,
            color: isMe ? Theme.of(context).primaryColor : Colors.grey[300],
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                text,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
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


