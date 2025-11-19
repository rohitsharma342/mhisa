import 'package:flutter/material.dart';
import '../models/user.dart';
import '../utils/constants.dart';
import 'dart:async';

class AudioCallScreen extends StatefulWidget {
  final User user;
  
  const AudioCallScreen({Key? key, required this.user}) : super(key: key);
  
  @override
  _AudioCallScreenState createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;
  
  Timer? _callTimer;
  Duration _callDuration = Duration.zero;
  CallStatus _callStatus = CallStatus.connecting;
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  
  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    
    _waveController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));
    
    _simulateCall();
  }
  
  void _simulateCall() async {
    _pulseController.repeat(reverse: true);
    
    await Future.delayed(Duration(seconds: 2));
    
    if (mounted) {
      setState(() {
        _callStatus = CallStatus.active;
      });
      
      _waveController.repeat(reverse: true);
      
      _callTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _callDuration = Duration(seconds: _callDuration.inSeconds + 1);
          });
        }
      });
    }
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _callTimer?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCallStatus(),
                  SizedBox(height: 40),
                  _buildUserAvatar(),
                  SizedBox(height: 30),
                  Text(
                    widget.user.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  SizedBox(height: 10),
                  Text(
                    _getCallStatusText(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _getCallStatusColor(),
                    ),
                  ),
                  if (_callStatus == CallStatus.active)
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text(
                        _formatDuration(_callDuration),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppConstants.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            _buildCallControls(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCallStatus() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return Container(
          width: 80,
          height: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              final delay = index * 0.2;
              final animationValue = (_waveAnimation.value + delay) % 1.0;
              final height = 4 + (16 * (1 - (animationValue - 0.5).abs() * 2).clamp(0.0, 1.0));
              
              return AnimatedContainer(
                duration: Duration(milliseconds: 100),
                width: 4,
                height: _callStatus == CallStatus.active ? height : 4,
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        );
      },
    );
  }
  
  Widget _buildUserAvatar() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _callStatus == CallStatus.connecting ? _pulseAnimation.value : 1.0,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppConstants.primaryColor.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 100,
              backgroundImage: NetworkImage(widget.user.avatarUrl),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildCallControls() {
    return Container(
      padding: EdgeInsets.all(AppConstants.padding * 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: _isMuted ? Icons.mic_off : Icons.mic,
            backgroundColor: _isMuted ? AppConstants.errorColor : AppConstants.cardColor,
            onTap: () {
              setState(() {
                _isMuted = !_isMuted;
              });
            },
            tooltip: _isMuted ? 'Unmute' : 'Mute',
          ),
          _buildControlButton(
            icon: Icons.call_end,
            backgroundColor: AppConstants.errorColor,
            size: 70,
            iconSize: 35,
            onTap: () {
              _endCall();
            },
            tooltip: 'End Call',
          ),
          _buildControlButton(
            icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
            backgroundColor: _isSpeakerOn ? AppConstants.primaryColor : AppConstants.cardColor,
            onTap: () {
              setState(() {
                _isSpeakerOn = !_isSpeakerOn;
              });
            },
            tooltip: _isSpeakerOn ? 'Speaker Off' : 'Speaker On',
          ),
        ],
      ),
    );
  }
  
  Widget _buildControlButton({
    required IconData icon,
    required Color backgroundColor,
    required VoidCallback onTap,
    double size = 60,
    double iconSize = 30,
    String? tooltip,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: backgroundColor.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            icon,
            size: iconSize,
            color: backgroundColor == AppConstants.primaryColor
                ? Colors.black
                : AppConstants.textPrimaryColor,
          ),
        ),
      ),
    );
  }
  
  void _endCall() {
    _callTimer?.cancel();
    _pulseController.stop();
    _waveController.stop();
    
    Navigator.pop(context);
    
    // Show call ended feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Call ended - ${_formatDuration(_callDuration)}'),
        backgroundColor: AppConstants.cardColor,
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  String _getCallStatusText() {
    switch (_callStatus) {
      case CallStatus.connecting:
        return 'Connecting...';
      case CallStatus.active:
        return 'Active call';
      case CallStatus.ended:
        return 'Call ended';
      case CallStatus.failed:
        return 'Call failed';
    }
  }
  
  Color _getCallStatusColor() {
    switch (_callStatus) {
      case CallStatus.connecting:
        return AppConstants.textSecondaryColor;
      case CallStatus.active:
        return AppConstants.primaryColor;
      case CallStatus.ended:
        return AppConstants.textSecondaryColor;
      case CallStatus.failed:
        return AppConstants.errorColor;
    }
  }
  
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

enum CallStatus {
  connecting,
  active,
  ended,
  failed,
}