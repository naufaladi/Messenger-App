import 'package:flutter/material.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../widgets/message_bubbles.dart';
import '../widgets/rounded_image.dart';

import '../models/chat_message.dart';
import '../models/chat_user.dart';

class CustomListViewTileWithActivity extends StatelessWidget {
  final double height;
  final String title;
  final String subtitle;
  final String imagePath;
  final bool isActive;
  final bool isActivity;
  final Function onTap;

  CustomListViewTileWithActivity({
    required this.height,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.isActive,
    required this.isActivity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
        onTap: () => onTap(),
        minVerticalPadding: height * 0.2,
        leading: RoundedImageNetworkWithStatusIndicator(
          key: UniqueKey(),
          size: height / 1.5,
          // imagePath is the other user's profile picture
          imagePath: imagePath,
          isActive: isActive,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        // if the other user is typing something, display a spinning icon. Otherwise just display the last sent message
        subtitle: isActivity
            ? Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SpinKitThreeBounce(
                    color: Colors.blue[600],
                    size: height * 0.2,
                  ),
                ],
              )
            : Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ));
  }
}

class CustomUserListViewTile extends StatelessWidget {
  final double height;
  final String title;
  final String subtitle;
  final String imagePath;
  final bool isActive;
  final bool isSelected;
  final Function onTap;

  CustomUserListViewTile({
    required this.height,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.isActive,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minVerticalPadding: height * 0.2,
      leading: RoundedImageNetworkWithStatusIndicator(
        isActive: isActive,
        key: UniqueKey(),
        imagePath: imagePath,
        size: height * 0.7,
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(subtitle),
      trailing:
          isSelected ? const Icon(Icons.check_circle, color: Colors.blue) : null,
      onTap: () => onTap(),
    );
  }
}

class CustomChatListViewTile extends StatelessWidget {
  final bool isOwnMessage;
  final double deviceHeight;
  final double width;
  final ChatUser sender;
  final ChatMessage message;

  CustomChatListViewTile({
    required this.isOwnMessage,
    required this.deviceHeight,
    required this.width,
    required this.sender,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: 10,
      ),
      width: width,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment:
            isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          isOwnMessage
              ? Container()
              : RoundedImageNetwork(
                  key: UniqueKey(),
                  imagePath: sender.imageUrl,
                  size: width * 0.09,
                ),
          SizedBox(
            width: width * 0.025,
          ),
          message.type == MessageType.TEXT
              ? TextMessageBubble(
                  isOwnMessage: isOwnMessage,
                  message: message,
                  height: deviceHeight * 0.06,
                  width: width,
                )
              : ImageMessageBubble(
                  isOwnMessage: isOwnMessage,
                  message: message,
                  height: deviceHeight * 0.3,
                  width: width * 0.95,
                ),
        ],
      ),
    );
  }
}
