import 'package:mentor_mobile_app/imports_bindings.dart';

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
              // FeggyApp(
              // commonErrorHandlers: (error) {
              //   final nonFieldError = ApiCommonErrors.handleNonFieldError(error: error);
              //   if (nonFieldError != null) {
              //     return nonFieldError;
              //   }
              //   return null;
              // },
              fixedHeaders: {'X-Platform': platformSource, 'user_role': 20},
              // token: () => 'JWT ${_cubit.state.currentUser?.access}',

              /// ✅ Correct prefix
              token: () {
                final access = _cubit.state.currentUser?.access;
                return access != null ? 'JWT $access' : null;
              },
              // onTokenError: () async {
              //   _cubit.removeUser();
              //   await Feggy.pushAndRemoveUntil(const SentOtpScreen());
              // },

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
                home: getScreen(state)
                // BlocBuilder<AppCubit, AppState>(
                //   buildWhen: (p, c) => false,
                //   builder: (context, state) => getScreen(state),
                // ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Widget getScreen(AppState state) {
  //   if (state.currentUser == null) {
  //     return const SentOtpScreen();
  //   } else if (!(state.currentUser?.isProfileCompleted ?? false)) {
  //     return const CreateOrganizationBasicDetailsScreen();
  //   }
  //   return const OrganizationListingScreen();
  // }

  Widget getScreen(AppState state) {
    // print('usr dara----${state.currentUser?.mentor}');
    print('newly stored token is---${state.currentUser?.access}');
    // print('usr dara----${state.currentUser?.isProfileCompleted}');
    if (state.currentUser == null) {
      return const SignupScreen();
    } else if (state.currentUser?.isProfileCompleted ?? false) {
      return const OrganizationListingScreen();
    } else {
      return const SentOtpScreen();

      // if ((state.currentUser?.mentor?.org?.profileCompleteness ?? 0) == 6) {
      //   return const OrganizationListingScreen();
      // } else {
      //   return const SentOtpScreen();
      // }
    }
    return const OrganizationListingScreen();
  }
}
