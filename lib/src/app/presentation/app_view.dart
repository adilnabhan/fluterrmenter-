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
  }

  @override
  void dispose() {
    super.dispose();
    _cubit.close();
  }

  @override
  Widget build(BuildContext context) {
    return FeggyApp(
      commonErrorHandlers: (error) {
        final nonFieldError = ApiCommonErrors.handleNonFieldError(error: error);
        if (nonFieldError != null) {
          return nonFieldError;
        }
        return null;
      },
      fixedHeaders: {'X-Platform': platformSource, 'user_role': 20},
      token: () => 'JWT ${_cubit.state.currentUser?.access}',
      onTokenError: () async {
        _cubit.removeUser();
        await Feggy.pushAndRemoveUntil(const SentOtpScreen());
      },
      child: Sizer.init(
        child: MultiBlocProvider(
          providers: [BlocProvider.value(value: _cubit)],
          child: BlocBuilder<AppCubit, AppState>(
            bloc: _cubit,
            builder: (context, state) {
              return MaterialApp(
                navigatorKey: Feggy.navKey,
                debugShowCheckedModeBanner: false,
                themeMode: state.themeMode,
                theme: AppThemes.light,
                darkTheme: AppThemes.dark,
                locale: state.locale,
                // home: const ProfileScreen(),
                home: BlocBuilder<AppCubit, AppState>(
                  buildWhen: (p, c) => p.currentUser != c.currentUser,
                  builder: (context, state) {
                    if (state.currentUser == null) {
                      return const SentOtpScreen();
                    } else if (!(state.currentUser?.isProfileCompleted ?? false)) {
                      return const CreateOrganizationBasicDetailsScreen();
                    }
                    // return const OrganizationListingScreen();
                    return AddOrEditTrainerScreen();
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
