import 'dart:io';

import 'package:chat_flutter_app/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'chat_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  User? _currentUser;
  bool isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((event) {
      setState(() {
        if (event != null) _currentUser = event;
      });
    });
  }

  Future<User?> _getUser() async {
    if (_currentUser != null) return _currentUser;
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);
      final UserCredential authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = authResult.user;
      return user;
    } catch (e) {
      return null;
    }
  }

  void _sendMessage(String? text, File? fileImg) async {
    final user = await _getUser();
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Não foi possivel fazer o login. Tente novamente!"),
          backgroundColor: Colors.red,
        ),
      );
    }
    try {
      Map<String, dynamic> data = {
        "uid": user!.uid,
        "senderName": user.displayName,
        "senderPhotoUrl": user.photoURL,
        "time": Timestamp.now()
      };
      if (fileImg != null) {
        final task = await FirebaseStorage.instance
            .ref()
            .child(user.uid + DateTime.now().millisecond.toString())
            .putFile(fileImg);
        setState(() {
          isLoading = true;
        });
        data['img'] = await task.ref.getDownloadURL();
        setState(() {
          isLoading = false;
        });
      }
      if (text != null) data["text"] = text;
      if (data.isNotEmpty) {
        FirebaseFirestore.instance.collection("messages").add(data);
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_currentUser != null
            ? "Olá, ${_currentUser!.displayName}"
            : "Chat App"),
        elevation: 0,
        centerTitle: true,
        actions: [
          _currentUser != null
              ? IconButton(
                  icon: const Icon(Icons.exit_to_app),
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    googleSignIn.signOut();
                    const SnackBar(
                      content: Text("Você saiu com sucesso!"),
                    );
                  },
                )
              : Container()
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("messages")
                  .orderBy("time")
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  default:
                    if (snapshot.hasData) {
                      var documents = snapshot.data!.docs;
                      return ListView.builder(
                        itemCount: documents.length,
                        reverse: true,
                        itemBuilder: (context, index) {
                          var data =
                              documents[index].data() as Map<String, dynamic>;
                          return ChatMessage(
                              data, (data["uid"] == _currentUser?.uid));
                        },
                      );
                    }
                    return Container();
                }
              },
            ),
          ),
          isLoading ? const LinearProgressIndicator() : Container(),
          TextComposer(_sendMessage),
        ],
      ),
    );
  }
}
