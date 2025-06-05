import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/auth/data/firebase_auth_repo.dart';
import 'features/auth/presentation/cubits/auth_cubit.dart';
import 'features/auth/presentation/cubits/auth_states.dart';
import 'features/auth/presentation/pages/auth_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/post/data/firebase_post_repo.dart';
import 'features/post/presentation/cubits/post_cubits.dart';
import 'features/profile/data/firebase_profile_repo.dart';
import 'features/profile/presentation/cubit/profile_cubit.dart';
import 'features/search/data/firebase_search_repo.dart';
import 'features/search/presentation/cubits/search_cubit.dart';
import 'themes/cubits/theme_cubit.dart';

class MyApp extends StatelessWidget {
  final authRepo = FirebaseAuthRepo();
  final profileRepo = FirebaseProfileRepo();
  final postRepo = FirebasePostRepo();
  final searchRepo = FirebaseSearchRepo();
  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(authRepo: authRepo)..checkAuth(),
        ),
        BlocProvider<ProfileCubit>(
          create: (context) => ProfileCubit(profileRepo: profileRepo),
        ),
        BlocProvider<PostCubit>(
          create: (BuildContext context) => PostCubit(postRepo: postRepo),
        ),
        BlocProvider<SearchCubit>(
          create: (BuildContext context) => SearchCubit(searchRepo: searchRepo),
        ),
        BlocProvider<ThemeCubit>(
          create: (BuildContext context) => ThemeCubit(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeData>(
        builder: (context, currentTheme) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: currentTheme,
            home: BlocConsumer<AuthCubit, AuthState>(
              builder: (context, authState) {
                print(authState);
                if (authState is UnauthenticatedState) {
                  return const AuthPage();
                }
                if (authState is AuthenticatedState) {
                  return const HomePage();
                } else {
                  return Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  );
                }
              },
              listener: (context, state) {
                if (state is AuthErrorState) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.errorMessage)));
                }
              },
            ),
          );
        },
      ),
    );
  }
}
