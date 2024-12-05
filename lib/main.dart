import 'package:bloc_quiz/bloc/auth/auth_bloc.dart';

import 'package:bloc_quiz/data/repositories/auth_repository.dart';
import 'package:bloc_quiz/presentation/Dashboard/dashboard.dart';
import 'package:bloc_quiz/presentation/assistant.dart';
import 'package:bloc_quiz/presentation/auth/sign_in/sign_in.dart';
import 'package:bloc_quiz/presentation/settings/settings_screen.dart';
import 'package:bloc_quiz/utility/questions_db.dart';
 // Import the AI Assistant Screen
import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'bloc/quiz_data/quiz_data_bloc.dart';
import 'data/repositories/quiz_repo.dart';
import 'firebase_options.dart';
import 'data/model/assistant.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,

  );
  DatabaseHelper.instance.fetchQuestions();
  DatabaseHelper.instance.fetchGeneratedQuestions();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        RepositoryProvider(create: (_) => AuthRepository()),
      ],
      child: const MyApp(),
    ),
  );
}



class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final ColorScheme lightColorScheme = lightDynamic ??
            ColorScheme.fromSeed(
              seedColor: Colors.deepOrange,
              brightness: Brightness.light,
            );
        final ColorScheme darkColorScheme = darkDynamic ??
            ColorScheme.fromSeed(
              seedColor: Colors.deepOrange,
              brightness: Brightness.dark,
            );

        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => AuthBloc(
                authRepository: context.read<AuthRepository>(),
              ),
            ),
            BlocProvider(
              create: (context) => AIAssistantBloc(),
            ),
          ],
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,

                theme: ThemeData(
                  useMaterial3: true,
                  colorScheme: lightColorScheme,

                ),
                darkTheme: ThemeData(
                  primaryColor: Colors.black,
                  primaryColorDark: Colors.black,
                  scaffoldBackgroundColor: Colors.black,
                  brightness: Brightness.dark,
                  useMaterial3: true,
                  colorScheme: darkColorScheme,

                ),

                themeMode: themeProvider.themeMode,
                home: StreamBuilder<User?>(
                  stream: FirebaseAuth.instance.userChanges(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Dashboard(snapshot.data!);
                    }
                    return SignIn();
                  },
                ),
                routes: {
                  '/assistant': (context) => AIAssistantScreen(),
                  // Add other routes here
                },
              );
            },
          ),
        );
      },
    );
  }
}
