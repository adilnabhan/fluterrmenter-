import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';

///* First widget integrating
import 'package:mentor_mobile_app/src/features/trainer/presentation/screens/trainer_dashboard_screen.dart';

///* First widget integrating
class AppView extends StatefulWidget {
  ///*
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  late final AppCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = AppCubit();

    // 🔐 Register AuthInterceptor with DioClient
    DioClient().registerAuthInterceptor(_cubit);

    /// 🔥 IMPORTANT: wait until HydratedCubit restores state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = _cubit.state.currentUser;
      // if (user?.refresh?.isNotEmpty == true) {
      _cubit.refreshToken();
      // }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _cubit.close();
  }

  @override
  Widget build(BuildContext context) {
    return Sizer.init(
      child: MultiBlocProvider(
        providers: [BlocProvider.value(value: _cubit)],
        child: BlocBuilder<AppCubit, AppState>(
          bloc: _cubit,
          builder: (context, state) {
            return FeggyApp(
              commonErrorHandlers: (error) {
                return ApiCommonErrors.handleNonFieldError(error: error);
              },
              fixedHeaders: {
                'X-Platform': platformSource,
                'user_role': state.currentUser?.userRole ?? 20
              },

              /// ✅ Correct prefix
              token: () {
                final access = _cubit.state.currentUser?.access;
                return access != null ? 'JWT $access' : null;
              },

              /// 🔥 Do NOT logout immediately
              onTokenError: () async {
                await _cubit.refreshToken();
              },

              child: MaterialApp(
                navigatorKey: Feggy.navKey,
                debugShowCheckedModeBanner: false,
                themeMode: state.themeMode,
                theme: AppThemes.light,
                darkTheme: AppThemes.dark,
                locale: state.locale,
                home: getScreen(state),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget getScreen(AppState state) {
    print('newly stored token is---${state.currentUser?.access}');
    final user = state.currentUser;
    if (user == null) {
      return const SignupScreen();
    }
    
    // Redirect Trainer (role 35) to TrainerDashboardScreen
    if (user.userRole == 35) {
      return const TrainerDashboardScreen();
    }

    if ((user.isProfileCompleted ?? false) ||
        user.mentor?.org != null) {
      return const OrganizationListingScreen();
    } else {
      return const SentOtpScreen();
    }
  }
}
