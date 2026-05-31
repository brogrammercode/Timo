import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:timo/features/session/cubit/session_cubit.dart';
import 'package:timo/features/session/repo/session_repo.dart';
import 'package:timo/features/session/models/focus_session_model.dart';
import 'package:timo/features/session/constants/session_constants.dart';

@GenerateNiceMocks([MockSpec<SessionRepo>()])
import 'session_cubit_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SessionCubit sessionCubit;
  late MockSessionRepo mockSessionRepo;

  setUp(() {
    mockSessionRepo = MockSessionRepo();
    sessionCubit = SessionCubit(sessionRepo: mockSessionRepo);
  });

  tearDown(() {
    sessionCubit.close();
  });

  group('SessionCubit', () {
    final mockSession = FocusSessionModel(
      id: 'session1',
      userId: 'user1',
      durationSeconds: 0,
      status: SessionConstants.statusActive,
      startedAt: DateTime.now(),
      endedAt: null,
    );

    test('initial state should be empty', () {
      expect(sessionCubit.state.activeSession, null);
      expect(sessionCubit.state.loadInfo.isInitial, true);
    });

    test('loadTodaySession creates new session if none exists', () async {
      when(mockSessionRepo.getActiveOrTodaySession()).thenAnswer((_) async => const Right(null));
      when(mockSessionRepo.createDailySession()).thenAnswer((_) async => Right(mockSession));

      await sessionCubit.loadTodaySession();

      expect(sessionCubit.state.activeSession, mockSession);
      verify(mockSessionRepo.createDailySession()).called(1);
    });
    
    test('loadTodaySession resumes existing session', () async {
      when(mockSessionRepo.getActiveOrTodaySession()).thenAnswer((_) async => Right(mockSession));

      await sessionCubit.loadTodaySession();

      expect(sessionCubit.state.activeSession, mockSession);
      verifyNever(mockSessionRepo.createDailySession());
    });
  });
}
