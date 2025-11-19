import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/match.dart';
import '../utils/constants.dart';

class MatchListItem extends StatelessWidget {
  final Match match;
  final VoidCallback onTap;
  
  const MatchListItem({
    Key? key,
    required this.match,
    required this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: AppConstants.margin),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(match.user.avatarUrl),
            ),
            if (match.user.isOnline)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppConstants.cardColor, width: 3),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                match.user.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(match.status).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStatusText(match.status),
                style: TextStyle(
                  fontSize: 12,
                  color: _getStatusColor(match.status),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              '${match.user.age} • ${match.user.interests.take(2).join(", ")}',
              style: TextStyle(
                color: AppConstants.textSecondaryColor,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 6),
            Text(
              match.hasStartedChat
                  ? 'Chat started'
                  : 'Matched ${DateFormat('MMM d').format(match.matchedAt)}',
              style: TextStyle(
                color: AppConstants.primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!match.hasStartedChat)
              Icon(
                Icons.chat_bubble_outline,
                color: AppConstants.primaryColor,
                size: 20,
              ),
            if (match.hasStartedChat)
              Icon(
                Icons.arrow_forward_ios,
                color: AppConstants.textSecondaryColor,
                size: 16,
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
  
  Color _getStatusColor(MatchStatus status) {
    switch (status) {
      case MatchStatus.pending:
        return Colors.orange;
      case MatchStatus.accepted:
        return AppConstants.primaryColor;
      case MatchStatus.rejected:
        return AppConstants.errorColor;
      case MatchStatus.expired:
        return AppConstants.textSecondaryColor;
    }
  }
  
  String _getStatusText(MatchStatus status) {
    switch (status) {
      case MatchStatus.pending:
        return 'Pending';
      case MatchStatus.accepted:
        return 'Matched';
      case MatchStatus.rejected:
        return 'Rejected';
      case MatchStatus.expired:
        return 'Expired';
    }
  }
}