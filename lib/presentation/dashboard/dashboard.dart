import 'package:bloc_quiz/presentation/dashboard/result/results_screen.dart';
import 'package:bloc_quiz/presentation/library/library_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../data/model/generator.dart';
import '../Profile/profile.dart';
import '../assistant.dart';
import '../auth/sign_in/sign_in.dart';
import '../settings/settings_screen.dart';
import 'categories/categories_screen.dart';
import '../questions/questions_screen.dart';

class Dashboard extends StatefulWidget {
  final User currentUser;
  const Dashboard(this.currentUser);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentIndex = 0;
  int _previousIndex = 0; // Track previous screen index
  bool _showBackButton = false;


  List<String> _appBarTitles = [
    'Главная',
    'Статистика',
    'Вопросы',
    'Библиотека',
    'Ассистент',

  ];

  @override
  Widget build(BuildContext context) {

    final List<Widget> _screens = [
      const Categories(),
      Results(),
      QuestionsScreen(),
      LibraryScreen(),
      AIAssistantScreen(),

    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          _appBarTitles[_currentIndex],
          style: TextStyle(
            fontSize: 24,
          ),
        ),
        //backgroundColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9), // Установите нужную прозрачность
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_rounded),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => Profile()));
            },
          ),
        ],
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.black),
              accountName: Text(
                '${widget.currentUser.displayName}',
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: Text(
                '${widget.currentUser.email}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              currentAccountPicture: widget.currentUser.photoURL != null
                  ? Image.network("${widget.currentUser.photoURL}")
                  : const FlutterLogo(),
            ),
            ListTile(
              leading: const Icon(
                Icons.contact_page,
              ),
              title: const Text(
                'Мой профиль',
                style: TextStyle(fontSize: 20),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Profile(),
                  ),
                );
              },
            ),
            const AboutListTile(
              icon: Icon(Icons.info),
              child: Text(
                'О приложении',
                style: TextStyle(fontSize: 20),
              ),
              applicationIcon: Icon(Icons.task_alt),
              applicationName: 'Пожарный аудит',
              applicationVersion: '1.0.0',
              applicationLegalese: 'verge',
              aboutBoxChildren: [],
            ),
            ListTile(
              leading: const Icon(Icons.logout_rounded),
              title: const Text(
                'Выйти из аккаунта',
                style: TextStyle(fontSize: 20),
              ),
              onTap: () {
                context.read<AuthBloc>().add(SignOutRequested());
              },
            ),
          ],
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is UnAuthenticated) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => SignIn()),
                  (route) => false,
            );
          }
        },
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 5,
        onDestinationSelected: (int index) {
          HapticFeedback.selectionClick();
          setState(() {
            _previousIndex = _currentIndex;
            _currentIndex = index;
            _showBackButton = (_currentIndex == 3); // Check if navigating to Library screen
          });
        },
        //indicatorColor: Theme.of(context).colorScheme.onPrimary,
        //backgroundColor: Theme.of(context).colorScheme.surface,

        selectedIndex: _currentIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Главная',
          ),
          NavigationDestination(
            icon: Icon(Icons.stacked_line_chart),
            label: 'Статистика',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            label: 'Вопросы',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.local_library),
            icon: Icon(Icons.local_library_outlined),
            label: 'Библиотека',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.assistant),
            icon: Icon(Icons.assistant_outlined),
            label: 'Ассистент',
          ),

        ],
      ),
    );
  }
}
