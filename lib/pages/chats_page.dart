import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:messenger_app/models/chat_user.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

import '../providers/authentication_provider.dart';
import '../providers/chats_page_provider.dart';

import '../widgets/top_bar.dart';
import '../pages/chat_page.dart';
import '../services/navigation_service.dart';
import '../widgets/custom_list_view_tiles.dart';
import '../models/chat.dart';
import '../models/chat_user.dart';
import '../models/chat_message.dart';

class ChatsPage extends StatefulWidget {
  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;
  late NavigationService _navigation;
  late ChatsPageProvider _pageProvider;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _auth = Provider.of<AuthenticationProvider>(context);
    _navigation = GetIt.instance.get<NavigationService>();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ChatsPageProvider>(
          create: (_) => ChatsPageProvider(_auth),
        ),
      ],
      child: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Builder(builder: (BuildContext context) {
      _pageProvider = context.watch<ChatsPageProvider>();
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: _deviceWidth * 0.03,
          vertical: _deviceHeight * 0.02,
        ),
        height: _deviceHeight * 0.98,
        width: _deviceWidth * 0.97,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TopBar(
              '  Chats',
              primaryAction: IconButton(
                  onPressed: () {
                    _auth.logout();
                    _navigation.navigateToRoute('/login');
                    setState(() {});
                  },
                  icon: Icon(
                    Icons.logout,
                    color: Colors.black,
                  )),
            ),
            _chatsList(),
          ],
        ),
      );
    });
  }

  Widget _chatsList() {
    List<Chat>? _chats = _pageProvider.chats;

    return Expanded(
      child: (() {
        if (_chats != null) {
          if (_chats.length != 0) {
            return ListView.builder(
              itemCount: _chats.length,
              itemBuilder: (context, index) {
                return _chatTile(_chats[index]);
              },
            );
          } else {
            return Center(
              child: Text(
                'No chats yet!',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            );
          }
        } else {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
        }
      })(),
    );
  }

  Widget _chatTile(Chat _chat) {
    List<ChatUser> _recipients = _chat.recipients();
    bool _isActive = _recipients.any((doc) => doc.wasRecentlyActive());
    String _subtitle = '';
    if (_chat.messages.isEmpty) {
      _subtitle = 'No messages yet';
    } else {
      _subtitle = _chat.messages.first.type != MessageType.TEXT
          ? "Someone sent an Attachment"
          : _chat.messages.first.content;
    }
    return CustomListViewTileWithActivity(
        height: _deviceHeight * 0.1,
        title: _chat.title(),
        subtitle: _subtitle,
        imagePath: _chat.imageURL(),
        isActive: _isActive,
        isActivity: _chat.activity,
        onTap: () {
          _navigation.navigateToPage(
            ChatPage(chat: _chat),
          );
        });
  }
}
