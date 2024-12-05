import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme(bool isOn) {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: ListView(
        children: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return ListTile(
                title: const Text('Темная тема'),
                trailing: Switch(
                  value: themeProvider.themeMode == ThemeMode.dark,
                  onChanged: (value) {
                    HapticFeedback.mediumImpact();  // Добавляем тактильный отклик
                    themeProvider.toggleTheme(value);
                  },
                ),
              );
            },
          ),
          // Здесь можно добавить другие настройки
        ],
      ),
    );
  }
}