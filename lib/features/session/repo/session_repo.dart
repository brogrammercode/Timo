import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../constants/firebase.dart';
import '../../../services/local_storage.dart';
import '../../../utils/error.dart';
import '../../../utils/try_catch.dart';
import '../../../services/connectivity_service.dart';
import '../constants/session_constants.dart';
import '../models/focus_session_model.dart';

class SessionRepo {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final LocalStorage _localStorage;
  final ConnectivityService _connectivityService;

  SessionRepo({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required LocalStorage localStorage,
    required ConnectivityService connectivityService,
  })  : _firestore = firestore,
        _auth = auth,
        _localStorage = localStorage,
        _connectivityService = connectivityService;

  TaskResult<FocusSessionModel> createDailySession() async {
    return tryCatchAsync(() async {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AuthException('User not authenticated');
      }

      final doc = _firestore.collection(FirebaseConstants.sessionsCollection).doc();
      final now = DateTime.now().toUtc();
      
      final session = FocusSessionModel(
        id: doc.id,
        userId: user.uid,
        durationSeconds: 0,
        status: SessionConstants.statusActive,
        startedAt: now,
        endedAt: null,
      );

      await doc.set(session.toJson());
      await _localStorage.saveActiveSessionId(session.id);
      return session;
    });
  }

  TaskResult<FocusSessionModel?> getActiveOrTodaySession() async {
    return tryCatchAsync(() async {
      final user = _auth.currentUser;
      if (user == null) return null;

      final localSessionId = _localStorage.getActiveSessionId();
      
      if (localSessionId != null) {
        final doc = await _firestore
            .collection(FirebaseConstants.sessionsCollection)
            .doc(localSessionId)
            .get();

        if (doc.exists) {
          final session = FocusSessionModel.fromJson(doc.data()!);
          // Check if session belongs to today based on local timezone
          final startLocal = session.startedAt.toLocal();
          final nowLocal = DateTime.now();
          if (startLocal.year == nowLocal.year && 
              startLocal.month == nowLocal.month && 
              startLocal.day == nowLocal.day) {
            return session;
          } else {
            // It's from yesterday, close it out
            await completeSession(session.id, session.durationSeconds);
            await _localStorage.clearActiveSessionId();
          }
        }
      }

      // If no local session id, query for today's active session from Firestore
      final startOfDayUtc = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).toUtc();
      
      final query = await _firestore
          .collection(FirebaseConstants.sessionsCollection)
          .where('user_id', isEqualTo: user.uid)
          .where('started_at', isGreaterThanOrEqualTo: startOfDayUtc)
          .orderBy('started_at', descending: true)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final session = FocusSessionModel.fromJson(query.docs.first.data());
        await _localStorage.saveActiveSessionId(session.id);
        return session;
      }

      return null;
    });
  }

  TaskResult<void> syncSession(String sessionId, int durationSeconds, String status) async {
    return tryCatchAsync(() async {
      final isOnline = await _connectivityService.hasConnection;
      final updateFuture = _firestore.collection(FirebaseConstants.sessionsCollection).doc(sessionId).update({
        'duration_seconds': durationSeconds,
        'status': status,
      });
      
      if (isOnline) {
        await updateFuture.timeout(const Duration(seconds: 5), onTimeout: () => null);
      }
    });
  }

  TaskResult<void> completeSession(String sessionId, int durationSeconds) async {
    return tryCatchAsync(() async {
      final isOnline = await _connectivityService.hasConnection;
      final updateFuture = _firestore.collection(FirebaseConstants.sessionsCollection).doc(sessionId).update({
        'duration_seconds': durationSeconds,
        'status': SessionConstants.statusCompleted,
        'ended_at': DateTime.now().toUtc(),
      });
      
      if (isOnline) {
        await updateFuture.timeout(const Duration(seconds: 5), onTimeout: () => null);
      }
      await _localStorage.clearActiveSessionId();
    });
  }
}

