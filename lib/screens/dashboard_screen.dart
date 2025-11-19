import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../utils/constants.dart';
import '../widgets/match_list_item.dart';
import '../widgets/user_card.dart';
import 'chat_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<DataService>(
      builder: (context, dataService, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(AppConstants.appName),
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications),
                    onPressed: () {
                      _showNotifications(context, dataService);
                    },
                  ),
                  if (dataService.notifications.isNotEmpty)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${dataService.notifications.length}',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsScreen()),
                  );
                },
              ),
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(120),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(AppConstants.padding),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search matches, chats...',
                              prefixIcon: Icon(Icons.search,
                                  color: AppConstants.textSecondaryColor),
                            ),
                            onChanged: (value) {
                              dataService.updateSearchQuery(value);
                            },
                          ),
                        ),
                        SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.filter_list),
                          onPressed: () {
                            _showFilterDialog(context);
                          },
                        ),
                      ],
                    ),
                  ),
                  TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(text: 'Matches'),
                      Tab(text: 'Chats'),
                      Tab(text: 'Discover'),
                      Tab(text: 'Activity'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildMatchesTab(dataService),
              _buildChatsTab(dataService),
              _buildDiscoverTab(dataService),
              _buildActivityTab(dataService),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: dataService.isLoading
                ? null
                : () async {
                    await dataService.startRandomMatch();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('New match found! Check your matches tab.'),
                        backgroundColor: AppConstants.primaryColor,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
            child: dataService.isLoading
                ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  )
                : Icon(Icons.add),
            tooltip: 'Find New Match',
          ),
        );
      },
    );
  }
  
  Widget _buildMatchesTab(DataService dataService) {
    if (dataService.matches.isEmpty) {
      return _buildEmptyState(
        icon: Icons.favorite_border,
        title: 'No matches yet',
        subtitle: 'Tap the + button to find your first match!',
      );
    }
    
    return ListView.builder(
      padding: EdgeInsets.all(AppConstants.padding),
      itemCount: dataService.matches.length,
      itemBuilder: (context, index) {
        final match = dataService.matches[index];
        return MatchListItem(
          match: match,
          onTap: () {
            final existingChat = dataService.chats
                .where((chat) => chat.otherUser.id == match.user.id)
                .firstOrNull;
            
            if (existingChat != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(chat: existingChat),
                ),
              );
            }
          },
        );
      },
    );
  }
  
  Widget _buildChatsTab(DataService dataService) {
    final chats = dataService.chats;
    
    if (chats.isEmpty) {
      return _buildEmptyState(
        icon: Icons.chat_bubble_outline,
        title: 'No chats yet',
        subtitle: 'Start a conversation with your matches!',
      );
    }
    
    return ListView.builder(
      padding: EdgeInsets.all(AppConstants.padding),
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        return Card(
          margin: EdgeInsets.only(bottom: AppConstants.margin),
          child: ListTile(
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(chat.otherUser.avatarUrl),
                ),
                if (chat.otherUser.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppConstants.cardColor, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    chat.otherUser.name,
                    style: TextStyle(
                      fontWeight: chat.unreadCount > 0
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
                if (chat.unreadCount > 0)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${chat.unreadCount}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Text(
              chat.isTyping ? 'Typing...' : chat.lastMessage,
              style: TextStyle(
                color: chat.isTyping
                    ? AppConstants.primaryColor
                    : AppConstants.textSecondaryColor,
                fontStyle: chat.isTyping ? FontStyle.italic : FontStyle.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              _formatTime(chat.lastMessageTime),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(chat: chat),
                ),
              );
            },
          ),
        );
      },
    );
  }
  
  Widget _buildDiscoverTab(DataService dataService) {
    if (dataService.discoverUsers.isEmpty) {
      return _buildEmptyState(
        icon: Icons.explore,
        title: 'No more users to discover',
        subtitle: 'Check back later for new people!',
      );
    }
    
    return GridView.builder(
      padding: EdgeInsets.all(AppConstants.padding),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: AppConstants.margin,
        mainAxisSpacing: AppConstants.margin,
      ),
      itemCount: dataService.discoverUsers.length,
      itemBuilder: (context, index) {
        final discoverUser = dataService.discoverUsers[index];
        return UserCard(
          discoverUser: discoverUser,
          onLike: () {
            dataService.addNotification(
                'You liked ${discoverUser.user.name}');
          },
          onPass: () {
            // Handle pass action
          },
        );
      },
    );
  }
  
  Widget _buildActivityTab(DataService dataService) {
    if (dataService.notifications.isEmpty) {
      return _buildEmptyState(
        icon: Icons.notifications_none,
        title: 'No activity yet',
        subtitle: 'Your recent activity will appear here',
      );
    }
    
    return ListView.builder(
      padding: EdgeInsets.all(AppConstants.padding),
      itemCount: dataService.notifications.length,
      itemBuilder: (context, index) {
        final notification = dataService.notifications[index];
        return Card(
          margin: EdgeInsets.only(bottom: AppConstants.margin),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppConstants.primaryColor,
              child: Icon(Icons.notifications, color: Colors.black),
            ),
            title: Text(notification),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              // Handle notification tap
            },
          ),
        );
      },
    );
  }
  
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: AppConstants.textSecondaryColor,
          ),
          SizedBox(height: 20),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  void _showNotifications(BuildContext context, DataService dataService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Notifications'),
        content: Container(
          width: double.maxFinite,
          child: dataService.notifications.isEmpty
              ? Text('No notifications')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: dataService.notifications.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(dataService.notifications[index]),
                      dense: true,
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              dataService.clearNotifications();
              Navigator.pop(context);
            },
            child: Text('Clear All'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
  
  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filter Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Age Range'),
              subtitle: Text('18 - 35'),
              trailing: Icon(Icons.chevron_right),
            ),
            ListTile(
              title: Text('Gender'),
              subtitle: Text('All'),
              trailing: Icon(Icons.chevron_right),
            ),
            ListTile(
              title: Text('Interests'),
              subtitle: Text('Any'),
              trailing: Icon(Icons.chevron_right),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Apply'),
          ),
        ],
      ),
    );
  }
  
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }
}