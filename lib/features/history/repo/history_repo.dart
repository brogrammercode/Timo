import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../constants/firebase.dart';
import '../../../utils/error.dart';
import '../../../utils/try_catch.dart';
import '../../session/models/focus_session_model.dart';
import '../../session/constants/session_constants.dart';

class HistoryRepo {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  HistoryRepo({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  TaskResult<List<FocusSessionModel>> getCompletedSessions() async {
    return tryCatchAsync(() async {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AuthException('User not authenticated');
      }

      final query = await _firestore
          .collection(FirebaseConstants.sessionsCollection)
          .where('user_id', isEqualTo: user.uid)
          .where('status', isEqualTo: SessionConstants.statusCompleted)
          .orderBy('started_at', descending: true)
          .limit(50) // Basic pagination/limit for now
          .get();

      return query.docs
          .map((doc) => FocusSessionModel.fromJson(doc.data()))
          .toList();
    });
  }

  TaskResult<void> deleteSession(String sessionId) async {
    return tryCatchAsync(() async {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AuthException('User not authenticated');
      }
      await _firestore
          .collection(FirebaseConstants.sessionsCollection)
          .doc(sessionId)
          .delete();
    });
  }
}

