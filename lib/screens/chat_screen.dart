import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chat.dart';
import '../services/data_service.dart';
import '../utils/constants.dart';
import '../widgets/chat_bubble.dart';
import 'audio_call_screen.dart';

class ChatScreen extends StatefulWidget {
  final Chat chat;
  
  const ChatScreen({Key? key, required this.chat}) : super(key: key);
  
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<DataService>(
      builder: (context, dataService, child) {
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(widget.chat.otherUser.avatarUrl),
                    ),
                    if (widget.chat.otherUser.isOnline)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppConstants.primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppConstants.surfaceColor, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.chat.otherUser.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        widget.chat.otherUser.isOnline
                            ? 'Online'
                            : 'Last seen ${_formatLastSeen(widget.chat.otherUser.lastSeen)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppConstants.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.call),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AudioCallScreen(
                        user: widget.chat.otherUser,
                      ),
                    ),
                  );
                },
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'block':
                      _showBlockDialog();
                      break;
                    case 'report':
                      _showReportDialog();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'block',
                    child: Row(
                      children: [
                        Icon(Icons.block, color: AppConstants.errorColor),
                        SizedBox(width: 8),
                        Text('Block User'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(Icons.report, color: AppConstants.errorColor),
                        SizedBox(width: 8),
                        Text('Report User'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: widget.chat.messages.isEmpty
                    ? _buildEmptyChat()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.all(AppConstants.padding),
                        itemCount: widget.chat.messages.length,
                        itemBuilder: (context, index) {
                          final message = widget.chat.messages[index];
                          final isCurrentUser = message.senderId == 'currentUser';
                          
                          return ChatBubble(
                            message: message,
                            isCurrentUser: isCurrentUser,
                          );
                        },
                      ),
              ),
              if (widget.chat.isTyping)
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: AppConstants.padding, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        '${widget.chat.otherUser.name} is typing',
                        style: TextStyle(
                          color: AppConstants.primaryColor,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      SizedBox(width: 8),
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppConstants.primaryColor),
                        ),
                      ),
                    ],
                  ),
                ),
              _buildMessageInput(dataService),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildEmptyChat() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(widget.chat.otherUser.avatarUrl),
          ),
          SizedBox(height: 16),
          Text(
            'Start a conversation with\n${widget.chat.otherUser.name}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: 8),
          Text(
            'Say hello and break the ice!',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AudioCallScreen(
                    user: widget.chat.otherUser,
                  ),
                ),
              );
            },
            icon: Icon(Icons.call),
            label: Text('Start Voice Call'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMessageInput(DataService dataService) {
    return Container(
      padding: EdgeInsets.all(AppConstants.padding),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        border: Border(
          top: BorderSide(
            color: AppConstants.cardColor,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppConstants.cardColor,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (value) {
                  setState(() {
                    _isTyping = value.isNotEmpty;
                  });
                },
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    _sendMessage(dataService, value.trim());
                  }
                },
              ),
            ),
            SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: AppConstants.primaryColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _messageController.text.trim().isEmpty
                    ? null
                    : () {
                        _sendMessage(dataService, _messageController.text.trim());
                      },
                icon: Icon(
                  Icons.send,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _sendMessage(DataService dataService, String content) {
    dataService.sendMessage(widget.chat.id, content);
    _messageController.clear();
    setState(() {
      _isTyping = false;
    });
    
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Block User'),
        content: Text(
            'Are you sure you want to block ${widget.chat.otherUser.name}? They will not be able to contact you anymore.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${widget.chat.otherUser.name} has been blocked'),
                  backgroundColor: AppConstants.errorColor,
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.errorColor,
            ),
            child: Text('Block'),
          ),
        ],
      ),
    );
  }
  
  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Report User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Why are you reporting ${widget.chat.otherUser.name}?'),
            SizedBox(height: 16),
            ...[
              'Inappropriate behavior',
              'Spam or fake profile',
              'Harassment',
              'Other'
            ].map((reason) => ListTile(
                  title: Text(reason),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Report submitted. Thank you for helping keep our community safe.'),
                        backgroundColor: AppConstants.primaryColor,
                      ),
                    );
                  },
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }
  
  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);
    
    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}