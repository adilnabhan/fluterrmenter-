import 'package:mentor_mobile_app/core/network/dio_client.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';

/// Desktop entry widget that runs the Fitness Center (Organization) module
class DesktopAppView extends StatefulWidget {
  const DesktopAppView({super.key});

  @override
  State<DesktopAppView> createState() => _DesktopAppViewState();
}

class _DesktopAppViewState extends State<DesktopAppView> {
  late final AppCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = AppCubit();

    // 🔐 Register AuthInterceptor with DioClient
    DioClient().registerAuthInterceptor(_cubit);

    // Refresh token on start if saved in storage
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = _cubit.state.currentUser;
      if (user?.refresh?.isNotEmpty ?? false) {
        await _cubit.refreshToken();
      }
    });
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
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
                'user_role': state.currentUser?.userRole ?? 20,
              },
              token: () {
                final access = _cubit.state.currentUser?.access;
                return access != null ? 'JWT $access' : null;
              },
              onTokenError: () async {
                await _cubit.refreshToken();
              },
              child: MaterialApp(
                title: 'Discipl - Fitness Center',
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
    if (kDebugMode) {
      print('🔒 DesktopAppView: Access token: ${state.currentUser?.access}');
      print('🔒 DesktopAppView: Refresh token: ${state.currentUser?.refresh}');
      print('🔒 DesktopAppView: User id: ${state.currentUser?.id}');
    }
    final user = state.currentUser;
    if (user == null) {
      return const SignupScreen();
    }

    // Direct routing to Fitness Center / Organization Management for Desktop
    if ((user.isProfileCompleted ?? false) || user.mentor?.org != null) {
      return const OrganizationListingScreen();
    } else {
      return const SentOtpScreen();
    }
  }
}
