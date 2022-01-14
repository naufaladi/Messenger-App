import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/custom_input_fields.dart';
import '../widgets/top_bar.dart';
import '../widgets/custom_list_view_tiles.dart';

import '../models/chat_message.dart';
import '../models/chat.dart';

import '../providers/chats_page_provider.dart';
import '../providers/chat_page_provider.dart';
import '../providers/authentication_provider.dart';

class ChatPage extends StatefulWidget {
  final Chat chat;

  ChatPage({required this.chat});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late ChatPageProvider _chatPageProvider;
  late AuthenticationProvider _auth;

  late GlobalKey<FormState> messageFormState;
  late ScrollController messageListViewController;

  @override
  void initState() {
    super.initState();
    messageListViewController = ScrollController();
    messageFormState = GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _auth = Provider.of<AuthenticationProvider>(context);
    // _navigation = GetIt.instance.get<NavigationService>();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ChatPageProvider>(create: (_) {
          return ChatPageProvider(
            this.widget.chat.uid,
            _auth,
            messageListViewController,
          );
        }),
      ],
      child: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Builder(
      builder: (BuildContext context) {
        _chatPageProvider = context.watch<ChatPageProvider>();
        return Scaffold(
          body: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: _deviceWidth * 0.03,
                vertical: _deviceHeight * 0.02,
              ),
              height: _deviceHeight,
              width: _deviceWidth,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TopBar(
                    this.widget.chat.title(),
                    fontSize: 20,
                    primaryAction: IconButton(
                      onPressed: () {
                        _chatPageProvider.deleteChat();
                      },
                      icon: Icon(Icons.delete),
                    ),
                    secondaryAction: IconButton(
                      onPressed: () {
                        _chatPageProvider.goBack();
                      },
                      icon: Icon(Icons.arrow_back_ios),
                    ),
                  ),
                  _messagesListView(),
                  _typeMessageForm(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _messagesListView() {
    if (_chatPageProvider.messages != null) {
      if (_chatPageProvider.messages?.length != 0) {
        return Container(
          height: _deviceHeight * 0.74,
          child: ListView.builder(
            controller: messageListViewController,
            itemCount: _chatPageProvider.messages?.length,
            itemBuilder: (ctx, idx) {
              ChatMessage _message = _chatPageProvider.messages![idx];
              bool _isOwnMessage = _message.senderID == _auth.user.uid;
              return Container(
                child: CustomChatListViewTile(
                  deviceHeight: _deviceHeight,
                  width: _deviceWidth * 0.8,
                  message: _message,
                  isOwnMessage: _isOwnMessage,
                  sender: this
                      .widget
                      .chat
                      .members
                      .where((user) => user.uid == _message.senderID)
                      .first,
                ),
              );
            },
          ),
        );
      } else {
        return const Align(
          alignment: Alignment.center,
          child: Text('No chat history with this contact'),
        );
      }
    } else {
      return const Center(
        child: LinearProgressIndicator(),
      );
    }
  }

  Widget _typeMessageForm() {
    return Container(
      height: _deviceHeight * 0.06,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.symmetric(
        horizontal: _deviceWidth * 0.04,
        vertical: _deviceHeight * 0.03,
      ),
      child: Form(
        key: messageFormState,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _selectAttachmentButton(),
            _messageTextField(),
            _sendMessageButton(),
          ],
        ),
      ),
    );
  }

  Widget _messageTextField() {
    return SizedBox(
      width: _deviceWidth * 0.65,
      child: CustomTextFormField(
        onSaved: (_message) {
          _chatPageProvider.message = _message;
        },
        placeholder: 'Type your message',
        regEx: r"^(?!\s*$).+",
        obscureText: false,
      ),
    );
  }

  Widget _sendMessageButton() {
    double _size = _deviceHeight * 0.04;
    return Container(
      height: _size,
      width: _size,
      child: IconButton(
        onPressed: () {
          if (messageFormState.currentState!.validate()) {
            // triggers the onSave() on _messageTextField, and once the value is assigned to the _message variable in chat_page_provider, activate the sendTextMessage() in chat_page_provider.
            messageFormState.currentState!.save();
            _chatPageProvider.sendTextMessage();
            // deletes whatever is on the text field
            messageFormState.currentState!.reset();
          }
        },
        icon: Icon(Icons.send_rounded),
      ),
    );
  }

  Widget _selectAttachmentButton() {
    double _size = _deviceHeight * 0.04;
    return Container(
      height: _size,
      width: _size,
      child: FloatingActionButton(
        child: const Icon(
          Icons.attachment,
          color: Colors.white,
        ),
        backgroundColor: Colors.lightBlue,
        onPressed: () {
          _chatPageProvider.sendImageMessage();
        },
      ),
    );
  }
}
