import 'dart:async';

import 'package:async/async.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import '../services/cloud_storage_service.dart';
import '../services/database_service.dart';
import '../services/media_service.dart';
import '../services/navigation_service.dart';

import '../providers/authentication_provider.dart';

import '../models/chat_message.dart';

class ChatPageProvider extends ChangeNotifier {
  late DatabaseService _db;
  late CloudStorageService _storage;
  late MediaService _media;
  late NavigationService _navigation;

  String _chatID;
  List<ChatMessage>? messages;

  AuthenticationProvider _auth;
  ScrollController _messagesListViewController;

  late StreamSubscription _messagesStream;
  late StreamSubscription _keyboardVisibilityStream;
  late KeyboardVisibilityController _keyboardVisibilityController;

  String? _message;

  String get message {
    return message;
  }

  void set message(String _value) {
    _message = _value;
  }

  ChatPageProvider(this._chatID, this._auth, this._messagesListViewController) {
    _db = GetIt.instance.get<DatabaseService>();
    _navigation = GetIt.instance.get<NavigationService>();
    _storage = GetIt.instance.get<CloudStorageService>();
    _media = GetIt.instance.get<MediaService>();
    _keyboardVisibilityController = KeyboardVisibilityController();

    listenToMessages();
    listenToKeyboardChanges();
  }

  @override
  void dispose() {
    _messagesStream.cancel();
    super.dispose();
  }

  void listenToMessages() {
    // everytime a new message is added to the database, this will parse the messages, add it to a list, updates the messages list, then updates the UI
    try {
      _messagesStream = _db.streamMessagesForChat(_chatID).listen(
        (snapshot) {
          List<ChatMessage> _messages = snapshot.docs.map((message) {
            Map<String, dynamic> _messageData =
                message.data() as Map<String, dynamic>;
            return ChatMessage.fromJSON(_messageData);
          }).toList();
          messages = _messages;
          notifyListeners();
          print("LISTENERS NOTIFIED");
          // jump to bottom, like in whatsapp
          WidgetsBinding.instance!.addPostFrameCallback(
            (timeStamp) {
              if (_messagesListViewController.hasClients) {
                _messagesListViewController
                    .jumpTo(_messagesListViewController.position.maxScrollExtent);
              }
            },
          );
        },
      );
    } catch (e) {
      print(e);
    }
  }

  void listenToKeyboardChanges() {
    _keyboardVisibilityStream = _keyboardVisibilityController.onChange.listen(
      (_event) {
        _db.updateChatData(_chatID, {'is_activity': _event});
      },
    );
  }

  void goBack() {
    _navigation.goBack();
  }

  void sendTextMessage() {
    if (_message != null) {
      ChatMessage _messageToSend = ChatMessage(
        content: _message!,
        type: MessageType.TEXT,
        senderID: _auth.user.uid,
        sentTime: DateTime.now(),
      );
      _db.addMessageToChat(_chatID, _messageToSend);
      print("MESSAGE ADDED TO CHAT");
    }
  }

  void sendImageMessage() async {
    try {
      // selects a file using media_service
      PlatformFile? _file = await _media.pickImageFromLibrary();
      if (_file != null) {
        // saves the selected file into database, then we retrieve the downloadURL String for that file
        String? _downloadURL = await _storage.saveChatImageToStorage(
          _chatID,
          _auth.user.uid,
          _file,
        );
        // create a new ChatMessage instance containing that file (image) we selected (via downloadURL)
        ChatMessage _messageToSend = ChatMessage(
          content: _downloadURL!,
          type: MessageType.IMAGE,
          senderID: _auth.user.uid,
          sentTime: DateTime.now(),
        );
        _db.addMessageToChat(_chatID, _messageToSend);
      }
    } catch (e) {
      print(e);
    }
  }

  void deleteChat() {
    goBack();
    _db.deleteChat(_chatID);
  }
}
