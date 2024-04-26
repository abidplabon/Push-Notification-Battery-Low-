import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<String>> fetchNonAdminUserIds() async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('rool', isEqualTo: 'User')
          .get();

      return querySnapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print('Error fetching non-admin user IDs: $e');
      return [];
    }
  }
}
