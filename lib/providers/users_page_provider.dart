import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import '../services/database_service.dart';
import '../services/navigation_service.dart';

import '../providers/authentication_provider.dart';

import '../models/chat.dart';
import '../models/chat_user.dart';

import '../pages/chat_page.dart';

class UsersPageProvider extends ChangeNotifier {
  AuthenticationProvider _auth;

  late DatabaseService _databaseService;
  late NavigationService _navigationService;

  List<ChatUser>? users;
  late List<ChatUser> _selectedUsers;

  List<ChatUser> get selectedUsers {
    return _selectedUsers;
  }

  UsersPageProvider(this._auth) {
    _selectedUsers = [];

    _databaseService = GetIt.instance.get<DatabaseService>();
    _navigationService = GetIt.instance.get<NavigationService>();
    getUsers();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getUsers({String? name}) async {
    _selectedUsers = [];
    try {
      // snapshot is the query result (documents) of the getUsers method
      _databaseService.getUsers(name: name).then(
        (_snapshot) {
          users = _snapshot.docs.map(
            (_doc) {
              Map<String, dynamic> _data = _doc.data() as Map<String, dynamic>;
              _data['uid'] = _doc.id;
              return ChatUser.fromJSON(_data);
            },
          ).toList();
          notifyListeners();
        },
      );
    } catch (e) {
      print('ERROR GETTING SEARCHED USERS LIST');
      print(e);
    }
  }

  void updateSelectedUsers(ChatUser _user) {
    if (_selectedUsers.contains(_user)) {
      _selectedUsers.remove(_user);
    } else {
      _selectedUsers.add(_user);
    }
    notifyListeners();
  }

  void createChat() async {
    try {
      List<String> _membersID = _selectedUsers.map((_user) => _user.uid).toList();
      _membersID.add(_auth.user.uid);
      bool _isGroup = _membersID.length > 2;
      DocumentReference? _doc = await _databaseService.createChat(
        {
          'is_group': _isGroup,
          'is_activity': false,
          'members': _membersID,
        },
      );
      // navigates to the newly created chat page
      List<ChatUser> _members = [];
      for (var _uid in _membersID) {
        // populate the _members list above
        DocumentSnapshot _userSnapshot = await _databaseService.getUser(_uid);
        Map<String, dynamic> _userData =
            _userSnapshot.data() as Map<String, dynamic>;
        _userData['uid'] = _userSnapshot.id;
        _members.add(ChatUser.fromJSON(_userData));
      }
      ChatPage _chatPage = ChatPage(
        chat: Chat(
          uid: _doc!.id,
          currentUserUid: _auth.user.uid,
          members: _members,
          messages: [],
          activity: false,
          group: _isGroup,
        ),
      );
      _selectedUsers = [];
      notifyListeners();
      _navigationService.navigateToPage(_chatPage);
    } catch (e) {
      print('ERROR CREATING CHAT');
      print(e);
    }
  }
}
