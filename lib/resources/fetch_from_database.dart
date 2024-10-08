import 'package:firebase_database/firebase_database.dart';

class UserDataService {
  final DatabaseReference _userRef = FirebaseDatabase.instance.ref('App/User');

  Future<String> getUserFullName(String userId) async {
    try {
      final firstNameSnapshot = await _userRef.child('$userId/FirstName').get();
      final secondNameSnapshot =
          await _userRef.child('$userId/SecondName').get();
      final lastNameSnapshot = await _userRef.child('$userId/LastName').get();

      if (firstNameSnapshot.exists &&
          secondNameSnapshot.exists &&
          lastNameSnapshot.exists) {
        String firstName = firstNameSnapshot.value.toString();
        String secondName = secondNameSnapshot.value.toString();
        String lastName = lastNameSnapshot.value.toString();
        return "$firstName $secondName $lastName";
      } else {
        return 'User Full Name';
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return 'User Full Name';
    }
  }

  Future<String> getUserFirstName(String userId) async {
    try {
      final firstNameSnapshot = await _userRef.child('$userId/FirstName').get();
      if (firstNameSnapshot.exists) {
        String firstName = firstNameSnapshot.value.toString();

        return firstName;
      } else {
        return 'User Full Name';
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return 'User Full Name';
    }
  }

  Future<String> getUserSecondName(String userId) async {
    try {
      final firstNameSnapshot =
          await _userRef.child('$userId/SecondName').get();
      if (firstNameSnapshot.exists) {
        String firstName = firstNameSnapshot.value.toString();

        return firstName;
      } else {
        return 'User Full Name';
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return 'User Full Name';
    }
  }

  Future<String> getUserLastName(String userId) async {
    try {
      final firstNameSnapshot = await _userRef.child('$userId/LastName').get();
      if (firstNameSnapshot.exists) {
        String firstName = firstNameSnapshot.value.toString();

        return firstName;
      } else {
        return 'User Full Name';
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return 'User Full Name';
    }
  }

  Future<List<Map<String, String>>> getAllUsers() async {
    try {
      final usersSnapshot = await _userRef.get();
      List<Map<String, String>> users = [];

      if (usersSnapshot.exists) {
        final usersData = usersSnapshot.value as Map<dynamic, dynamic>;

        usersData.forEach((userId, userInfo) {
          if (userInfo is Map) {
            String firstName = userInfo['FirstName'] ?? 'Unknown';
            String secondName = userInfo['SecondName'] ?? '';
            String lastName = userInfo['LastName'] ?? 'Unknown';
            users.add({
              'userId': userId,
              'fullName': '$firstName $secondName $lastName',
            });
          }
        });
      }

      return users;
    } catch (e) {
      print('Error fetching all users: $e');
      return [];
    }
  }
}
