import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String text;
  final int messageCount;
  final void Function()? onTap;
  final String avatarURL;
  const UserTile({
    super.key,
    required this.text,
    required this.messageCount,
    this.onTap,
    required this.avatarURL,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            children: [
              CircularProfileAvatar(
                avatarURL,
                backgroundColor: Colors.cyan,
                borderWidth: 1,
                borderColor: Colors.purple,
                elevation: 20,
                radius: 24,
                cacheImage: true,
                errorWidget: (context, url, error) {
                  return Icon(
                    Icons.face,
                    size: 50,
                  );
                },
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(text),
              ),
              if (messageCount > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade500,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$messageCount',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
