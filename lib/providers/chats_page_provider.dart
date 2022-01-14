import 'dart:async';

import 'package:async/async.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/database_service.dart';

import '../providers/authentication_provider.dart';

import '../models/chat.dart';
import '../models/chat_message.dart';
import '../models/chat_user.dart';

class ChatsPageProvider extends ChangeNotifier {
  AuthenticationProvider _auth;
  late DatabaseService _db;
  List<Chat>? chats;
  late StreamSubscription _chatsStream;

  ChatsPageProvider(this._auth) {
    _db = GetIt.instance.get<DatabaseService>();
    getChats();
  }

  @override
  void dispose() {
    // StreamSubscription to save memory
    _chatsStream.cancel();
    super.dispose();
  }

  void getChats() async {
    try {
      // listens for changes in the database for chat rooms which the current user is a part of, and returns a Chat instance for every data collection there.
      _chatsStream = _db.getChatsForUser(_auth.user.uid).listen((snapshot) async {
        chats = await Future.wait(
          snapshot.docs.map(
            (document) async {
              Map<String, dynamic> _chatData =
                  document.data() as Map<String, dynamic>;
              // gets all the members in a chat room
              List<ChatUser> _members = [];
              for (var _uid in _chatData['members']) {
                DocumentSnapshot _userSnapshot = await _db.getUser(_uid);
                Map<String, dynamic> _userData =
                    _userSnapshot.data() as Map<String, dynamic>;
                _userData['uid'] = _userSnapshot.id;
                _members.add(ChatUser.fromJSON(_userData));
              }
              // gets all the messages in a chat room
              List<ChatMessage> _messages = [];
              QuerySnapshot _chatMessage =
                  await _db.getLastMessageForChat(document.id);

              if (_chatMessage.docs.isNotEmpty) {
                Map<String, dynamic> _messageData =
                    _chatMessage.docs.first.data()! as Map<String, dynamic>;
                ChatMessage _message = ChatMessage.fromJSON(_messageData);
                _messages.add(_message);
              }

              return Chat(
                uid: document.id,
                currentUserUid: _auth.user.uid,
                members: _members,
                messages: _messages,
                activity: _chatData['is_activity'],
                group: _chatData['is_group'],
              );
            },
          ).toList(),
        );
        notifyListeners();
      });
    } catch (e) {
      print("error while trying to get chats");
      print(e);
    }
  }
}
