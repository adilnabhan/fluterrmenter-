import 'package:mentor_mobile_app/imports_bindings.dart';

///* First widget integrating
class AppView extends StatefulWidget {
  ///*
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  @override
  Widget build(BuildContext context) {
    return FeggyApp(
      // token: () => 'Bearer ${Feggy.read<LoginCubit>()?.state.loginModel?.accessToken}',
      // onTokenError: () => Feggy.read<LoginCubit>()?.logout(isTokenExpire: true),
      child: Sizer.init(
        child: MultiBlocProvider(
          providers: [BlocProvider(create: (_) => AppCubit()), BlocProvider(create: (_) => AuthCubit())],
          child: BlocBuilder<AppCubit, AppState>(
            builder: (context, state) {
              return MaterialApp(
                navigatorKey: Feggy.navKey,
                debugShowCheckedModeBanner: false,
                themeMode: state.themeMode,
                theme: AppThemes.light,
                darkTheme: AppThemes.dark,
                locale: state.locale,
                home: const HomeScreen(),
              );
            },
          ),
        ),
      ),
    );
  }
}
