import 'user.dart';

class Match {
  final String id;
  final User user;
  final DateTime matchedAt;
  final bool hasStartedChat;
  final MatchStatus status;
  
  Match({
    required this.id,
    required this.user,
    required this.matchedAt,
    required this.hasStartedChat,
    required this.status,
  });
}

class DiscoverUser {
  final User user;
  final int compatibilityScore;
  final List<String> commonInterests;
  
  DiscoverUser({
    required this.user,
    required this.compatibilityScore,
    required this.commonInterests,
  });
}

enum MatchStatus {
  pending,
  accepted,
  rejected,
  expired,
}