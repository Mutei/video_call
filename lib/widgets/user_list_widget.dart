import 'package:flutter/material.dart';

class UserListWidget extends StatelessWidget {
  final List<Map<String, String>> users;
  final Function(String userId) onUserPressed;

  const UserListWidget({
    Key? key,
    required this.users,
    required this.onUserPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return users.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              String fullName = users[index]['fullName'] ?? 'Unknown User';
              String userId = users[index]['userId'] ?? '';

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () => onUserPressed(userId),
                  child: Text(fullName),
                ),
              );
            },
          );
  }
}
