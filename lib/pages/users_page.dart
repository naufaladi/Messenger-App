import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

import '../providers/authentication_provider.dart';
import '../providers/users_page_provider.dart';
import '../widgets/top_bar.dart';
import '../widgets/custom_input_fields.dart';
import '../widgets/custom_list_view_tiles.dart';
import '../widgets/rounded_button.dart';
import '../services/navigation_service.dart';

import '../models/chat_user.dart';

class UsersPage extends StatefulWidget {
  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  late double _deviceHeight;
  late double _deviceWidth;
  late AuthenticationProvider _auth;
  late UsersPageProvider _pageProvider;
  late NavigationService _navigation;

  final TextEditingController _searchFieldTextEditingController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _auth = Provider.of<AuthenticationProvider>(context);
    _navigation = GetIt.instance.get<NavigationService>();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UsersPageProvider>(
          create: (_) => UsersPageProvider(_auth),
        ),
      ],
      child: _buildUI(),
    );
  }

  Widget _buildUI() {
    // we use Builder so we get access to BuildContext (_ctx) which we can use to access the Page Provider
    return Builder(
      builder: (_ctx) {
        _pageProvider = _ctx.watch<UsersPageProvider>();
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
                '  Contacts',
                primaryAction: IconButton(
                  onPressed: () {
                    _auth.logout();
                  },
                  icon: const Icon(
                    Icons.logout,
                    color: Colors.black,
                  ),
                ),
              ),
              CustomTextField(
                onEditingComplete: (_value) {
                  _pageProvider.getUsers(name: _value);
                  FocusScope.of(context).unfocus();
                },
                placeholder: 'Search for contacts...',
                obscuretext: false,
                controller: _searchFieldTextEditingController,
                icon: Icons.search,
              ),
              _usersList(),
              _createChatButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _usersList() {
    List<ChatUser>? _users = _pageProvider.users;
    return Expanded(child: () {
      if (_users != null) {
        if (_users.isNotEmpty) {
          return ListView.builder(
              itemCount: _users.length,
              itemBuilder: (ctx, index) {
                return CustomUserListViewTile(
                  height: _deviceHeight * 0.1,
                  title: _users[index].name,
                  subtitle: "last active: ${_users[index].lastDayActive()}",
                  imagePath: _users[index].imageUrl,
                  isActive: _users[index].wasRecentlyActive(),
                  isSelected: _pageProvider.selectedUsers.contains(_users[index]),
                  onTap: () {
                    _pageProvider.updateSelectedUsers(_users[index]);
                  },
                );
              });
        } else {
          return Center(
            child: Text('No User was found'),
          );
        }
      } else {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
    }());
  }

  Widget _createChatButton() {
    return Visibility(
      visible: _pageProvider.selectedUsers.isNotEmpty,
      child: RoundedButton(
        title: _pageProvider.selectedUsers.length == 1
            ? 'Chat With ${_pageProvider.selectedUsers[0].name}'
            : 'Create group chat',
        height: _deviceHeight * 0.08,
        width: _deviceWidth * 0.8,
        onPressed: () {
          _pageProvider.createChat();
        },
      ),
    );
  }
}
