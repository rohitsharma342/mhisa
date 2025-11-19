import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/chat.dart';
import '../models/match.dart';

class DataService extends ChangeNotifier {
  List<User> _users = [];
  List<Chat> _chats = [];
  List<Match> _matches = [];
  List<DiscoverUser> _discoverUsers = [];
  List<String> _notifications = [];
  bool _isLoading = false;
  String _searchQuery = '';
  
  List<User> get users => _users;
  List<Chat> get chats => _chats.where((chat) => 
    _searchQuery.isEmpty || 
    chat.otherUser.name.toLowerCase().contains(_searchQuery.toLowerCase())
  ).toList();
  List<Match> get matches => _matches;
  List<DiscoverUser> get discoverUsers => _discoverUsers;
  List<String> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  
  DataService() {
    _initializeMockData();
  }
  
  void _initializeMockData() {
    _users = [
      User(
        id: '1',
        name: 'Emma Wilson',
        avatarUrl: 'https://images.unsplash.com/photo-1494790108755-2616b612b602?w=150',
        age: 25,
        gender: 'female',
        bio: 'Love music and deep conversations',
        isOnline: true,
        lastSeen: DateTime.now().subtract(Duration(minutes: 5)),
        interests: ['Music', 'Travel', 'Books'],
      ),
      User(
        id: '2',
        name: 'Alex Johnson',
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        age: 28,
        gender: 'male',
        bio: 'Adventure seeker and coffee lover',
        isOnline: false,
        lastSeen: DateTime.now().subtract(Duration(hours: 2)),
        interests: ['Adventure', 'Coffee', 'Photography'],
      ),
      User(
        id: '3',
        name: 'Sophia Davis',
        avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
        age: 24,
        gender: 'female',
        bio: 'Artist and nature enthusiast',
        isOnline: true,
        lastSeen: DateTime.now(),
        interests: ['Art', 'Nature', 'Yoga'],
      ),
      User(
        id: '4',
        name: 'Michael Brown',
        avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
        age: 30,
        gender: 'male',
        bio: 'Tech enthusiast and gamer',
        isOnline: false,
        lastSeen: DateTime.now().subtract(Duration(hours: 1)),
        interests: ['Technology', 'Gaming', 'Movies'],
      ),
    ];
    
    _chats = [
      Chat(
        id: '1',
        otherUser: _users[0],
        messages: [
          ChatMessage(
            id: '1',
            senderId: _users[0].id,
            receiverId: 'currentUser',
            content: 'Hey! How are you doing?',
            timestamp: DateTime.now().subtract(Duration(minutes: 10)),
            isRead: true,
            type: MessageType.text,
          ),
          ChatMessage(
            id: '2',
            senderId: 'currentUser',
            receiverId: _users[0].id,
            content: 'Hi Emma! I\'m doing great, thanks for asking!',
            timestamp: DateTime.now().subtract(Duration(minutes: 8)),
            isRead: true,
            type: MessageType.text,
          ),
        ],
        lastMessageTime: DateTime.now().subtract(Duration(minutes: 8)),
        lastMessage: 'Hi Emma! I\'m doing great, thanks for asking!',
        unreadCount: 0,
      ),
      Chat(
        id: '2',
        otherUser: _users[1],
        messages: [
          ChatMessage(
            id: '3',
            senderId: _users[1].id,
            receiverId: 'currentUser',
            content: 'Want to grab coffee sometime?',
            timestamp: DateTime.now().subtract(Duration(hours: 1)),
            isRead: false,
            type: MessageType.text,
          ),
        ],
        lastMessageTime: DateTime.now().subtract(Duration(hours: 1)),
        lastMessage: 'Want to grab coffee sometime?',
        unreadCount: 1,
      ),
    ];
    
    _matches = [
      Match(
        id: '1',
        user: _users[0],
        matchedAt: DateTime.now().subtract(Duration(days: 1)),
        hasStartedChat: true,
        status: MatchStatus.accepted,
      ),
      Match(
        id: '2',
        user: _users[1],
        matchedAt: DateTime.now().subtract(Duration(hours: 3)),
        hasStartedChat: true,
        status: MatchStatus.accepted,
      ),
    ];
    
    _discoverUsers = [
      DiscoverUser(
        user: _users[2],
        compatibilityScore: 85,
        commonInterests: ['Art', 'Nature'],
      ),
      DiscoverUser(
        user: _users[3],
        compatibilityScore: 72,
        commonInterests: ['Technology'],
      ),
    ];
    
    _notifications = [
      'Emma Wilson liked your voice message',
      'You have a new match with Alex Johnson',
      'Sophia Davis is now online',
    ];
  }
  
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
  
  void sendMessage(String chatId, String content) {
    final chatIndex = _chats.indexWhere((chat) => chat.id == chatId);
    if (chatIndex != -1) {
      final newMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: 'currentUser',
        receiverId: _chats[chatIndex].otherUser.id,
        content: content,
        timestamp: DateTime.now(),
        isRead: false,
        type: MessageType.text,
      );
      
      _chats[chatIndex].messages.add(newMessage);
      notifyListeners();
    }
  }
  
  Future<void> startRandomMatch() async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(Duration(seconds: 2));
    
    if (_discoverUsers.isNotEmpty) {
      final randomUser = _discoverUsers.first;
      final newMatch = Match(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        user: randomUser.user,
        matchedAt: DateTime.now(),
        hasStartedChat: false,
        status: MatchStatus.accepted,
      );
      
      _matches.add(newMatch);
      _discoverUsers.removeAt(0);
      
      final newChat = Chat(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        otherUser: randomUser.user,
        messages: [],
        lastMessageTime: DateTime.now(),
        lastMessage: 'New match! Start a conversation.',
        unreadCount: 0,
      );
      
      _chats.add(newChat);
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }
  
  void addNotification(String notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }
}