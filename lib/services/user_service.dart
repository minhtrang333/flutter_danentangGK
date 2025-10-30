import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class UserService {
  final CollectionReference _users = FirebaseFirestore.instance.collection(
    'client',
  );

  Future<List<User>> getAll() async {
    final snapshot = await _users.get();
    return snapshot.docs
        .map((doc) => User.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<User?> getByEmail(String email) async {
    final snapshot = await _users.where('email', isEqualTo: email).get();
    if (snapshot.docs.isEmpty) return null;
    return User.fromMap(
      snapshot.docs.first.id,
      snapshot.docs.first.data() as Map<String, dynamic>,
    );
  }

  Future<void> add(User user) async {
    await _users.add(user.toMap());
  }

  Future<void> update(User user) async {
    await _users.doc(user.id).update(user.toMap());
  }

  Future<void> delete(String id) async {
    await _users.doc(id).delete();
  }
}
