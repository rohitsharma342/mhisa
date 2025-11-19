import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/chat.dart';
import '../utils/constants.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isCurrentUser;
  
  const ChatBubble({
    Key? key,
    required this.message,
    required this.isCurrentUser,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isCurrentUser) ...
          [
            CircleAvatar(
              radius: 12,
              backgroundColor: AppConstants.primaryColor,
              child: Icon(
                Icons.person,
                size: 16,
                color: Colors.black,
              ),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isCurrentUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isCurrentUser
                        ? AppConstants.primaryColor
                        : AppConstants.cardColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                      bottomLeft: Radius.circular(isCurrentUser ? 18 : 4),
                      bottomRight: Radius.circular(isCurrentUser ? 4 : 18),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.type == MessageType.audio) ...
                      [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.play_arrow,
                              color: isCurrentUser
                                  ? Colors.black
                                  : AppConstants.textPrimaryColor,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Voice message',
                              style: TextStyle(
                                color: isCurrentUser
                                    ? Colors.black
                                    : AppConstants.textPrimaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ] else ...
                      [
                        Text(
                          message.content,
                          style: TextStyle(
                            color: isCurrentUser
                                ? Colors.black
                                : AppConstants.textPrimaryColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('HH:mm').format(message.timestamp),
                      style: TextStyle(
                        color: AppConstants.textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                    if (isCurrentUser) ...
                    [
                      SizedBox(width: 4),
                      Icon(
                        message.isRead ? Icons.done_all : Icons.done,
                        size: 16,
                        color: message.isRead
                            ? AppConstants.primaryColor
                            : AppConstants.textSecondaryColor,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (isCurrentUser) ...
          [
            SizedBox(width: 8),
            CircleAvatar(
              radius: 12,
              backgroundColor: AppConstants.primaryColor,
              child: Icon(
                Icons.person,
                size: 16,
                color: Colors.black,
              ),
            ),
          ],
        ],
      ),
    );
  }
}