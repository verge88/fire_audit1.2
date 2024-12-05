import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:convert';
import '../../data/model/law.dart';
import '../../data/repositories/library_repo.dart';
import 'law_view_screen.dart';

class LibraryScreen extends StatefulWidget {
  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  late Future<List<Law>> futureLaws;
  final String url = 'https://firebasestorage.googleapis.com/v0/b/quiz-4c367.appspot.com/o/law_url%2Flaw_url.json?alt=media&token=43020c69-ec0e-4c4c-8c3f-8d169acf0500';
  String? selectedContentType;

  @override
  void initState() {
    super.initState();
    // Future will be initialized after content type selection
  }

  Future<List<Law>> _fetchLaws() async {
    DefaultCacheManager cacheManager = DefaultCacheManager();
    FileInfo? fileInfo = await cacheManager.getFileFromCache(url);
    if (fileInfo != null && fileInfo.validTill!.isAfter(DateTime.now())) {
      String? jsonString = await fileInfo.file.readAsString();
      Iterable decoded = jsonDecode(jsonString!);
      return List<Law>.from(decoded.map((lawJson) => Law.fromJson(lawJson)));
    } else {
      List<Law> laws = await _fetchFromNetwork();
      await cacheManager.putFile(url, utf8.encode(jsonEncode(laws)));
      return laws;
    }
  }

  Future<List<Law>> _fetchFromNetwork() async {
    LibraryDataRepository repository = LibraryDataRepository(url);
    return repository.getLaws();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (selectedContentType != null) {
          setState(() {
            selectedContentType = null; // Reset to content type selection
          });
          return false; // Prevent exiting the app
        }
        return true; // Allow exiting the app if already on content selection
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        // appBar: AppBar(title: Text('Библиотека')),
        body: selectedContentType == null
            ? _buildContentTypeSelection()
            : _buildContentDisplay(),
      ),
    );
  }

  Widget _buildContentTypeSelection() {
    return Center(
      child: ListView(
        children: [
          _buildCard('Нормативно-правовая база', 'нормативно-правовая база'),
          _buildCard('Лекции', 'лекции'),
          _buildCard('Полезные ссылки', 'полезные ссылки'),
        ],
      ),
    );
  }

  Widget _buildCard(String title, String contentType) {
    return Card(
      child: Container(
        height: 80, // Увеличенная высота карточки
        child: Center(
          child: ListTile(
            title: Text(
              title,
              style: TextStyle(fontSize: 18), // Увеличенный размер шрифта
            ),
            onTap: () {
              setState(() {
                selectedContentType = contentType;
                if (contentType == 'нормативно-правовая база') {
                  futureLaws = _fetchLaws();
                }
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContentDisplay() {
    if (selectedContentType == 'нормативно-правовая база') {
      return FutureBuilder<List<Law>>(
        future: futureLaws,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No laws available.'));
          }

          List<Law> laws = snapshot.data!;
          return ListView.builder(
            itemCount: laws.length,
            itemBuilder: (context, index) {
              return Card(

                  child: Center(
                    child: ListTile(
                      title: Text(
                        laws[index].title,
                        //style: TextStyle(fontSize: 18), // Увеличенный размер шрифта
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LawViewScreen(law: laws[index]),
                          ),
                        );
                      },
                    ),
                  ),

              );
            },
          );
        },
      );
    } else if (selectedContentType == 'лекции') {
      // Placeholder for displaying "лекции"
      return Center(child: Text('Раздел "лекции" еще не реализован.'));
    } else {
      return Container();
    }
  }
}