import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../data/model/questions.dart';



class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();
  static const int _version = 2; // Увеличиваем версию базы данных

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('assets/databases/database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: _version,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        is_generated INTEGER DEFAULT 0,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        test_id INTEGER,
        question TEXT NOT NULL,
        correct_answer TEXT NOT NULL,
        incorrect_answers TEXT NOT NULL,
        category TEXT,
        clarification TEXT,
        FOREIGN KEY (test_id) REFERENCES tests (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Добавляем новые столбцы или создаем новые таблицы
      await db.execute('ALTER TABLE tests ADD COLUMN is_generated INTEGER DEFAULT 0');
    }
  }

  Future<int> createTest(String testName, {bool isGenerated = true}) async {
    final db = await database;
    return await db.insert('tests', {
      'name': testName,
      'is_generated': isGenerated ? 1 : 0,
      'created_at': DateTime.now().toIso8601String()
    });
  }

  Future<void> saveQuestionsToTest(int testId, List<Question> questions) async {
    final db = await database;
    final batch = db.batch();

    for (var question in questions) {
      batch.insert('questions', {
        'test_id': testId,
        'question': question.question,
        'correct_answer': question.correctAnswer,
        'incorrect_answers': question.incorrectAnswers.join('|'),
        'category': question.category,
        'clarification': question.clarification
      });
    }

    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getGeneratedTests() async {
    final db = await database;
    return await db.query('tests', where: 'is_generated = 1');
  }

  Future<List<Question>> getQuestionsForTest(int testId) async {
    final db = await database;
    final questionsData = await db.query('questions', where: 'test_id = ?', whereArgs: [testId]);

    return questionsData.map((q) => Question(
        id: q['id'].toString(),
        question: q['question'] as String,
        correctAnswer: q['correct_answer'] as String,
        incorrectAnswers: (q['incorrect_answers'] as String).split('|'),
        category: q['category'] as String? ?? '',
        clarification: q['clarification'] as String? ?? ''
    )).toList();
  }





  Future<List<Question>> fetchTestQuestions(int testId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('test_questions_$testId');

      if (maps.isEmpty) {
        print('Вопросы для теста не найдены');
        return [];
      }

      return List.generate(maps.length, (i) {
        return Question(
          id: maps[i]['id'].toString(),
          question: maps[i]['question'],
          correctAnswer: maps[i]['correctAnswer'],
          incorrectAnswers: maps[i]['incorrectAnswers'].split('|'),
          category: '',
          clarification: '',
        );
      });
    } catch (e) {
      print('Ошибка при загрузке вопросов теста: $e');
      return [];
    }
  }




  Future<List<Question>> fetchQuestions() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('questions');

      if (maps.isEmpty) {
        print('Таблица вопросов пуста');
        return [];
      }

      return List.generate(maps.length, (i) {
        return Question(
          id: maps[i]['id'].toString(),
          category: maps[i]['category'],
          question: maps[i]['question'],
          correctAnswer: maps[i]['correctAnswer'],
          incorrectAnswers: maps[i]['incorrectAnswers'].split('|'),
          clarification: maps[i]['clarification'],
        );
      });
    } catch (e) {
      print('Ошибка при загрузке вопросов: $e');
      return [];
    }
  }

  Future<void> _ensureGeneratedQuestionsTable(Database db) async {
    // Проверяем, существует ли таблица
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='generated';",
    );

    if (result.isEmpty) {
      print('Таблица generated отсутствует. Создаём...');
      await db.execute('''
      CREATE TABLE IF NOT EXISTS generated (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question TEXT NOT NULL,
        correctAnswer TEXT NOT NULL,
        incorrectAnswers TEXT NOT NULL
      )
    ''');
      print('Таблица generated успешно создана.');
    } else {
      print('Таблица generated уже существует.');
    }
  }


  Future<List<Question>> fetchGeneratedQuestions() async {

    try {

      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('generated');

      if (maps.isEmpty) {
        print('Таблица сгенерированных вопросов пуста');
        return [];
      }

      return List.generate(maps.length, (i) {
        return Question(
          id: maps[i]['id'].toString(),
          question: maps[i]['question'],
          correctAnswer: maps[i]['correctAnswer'],
          incorrectAnswers: maps[i]['incorrectAnswers'].split('|'),
          category: '',
          clarification: '',
        );
      });
    } catch (e) {
      print('Ошибка при загрузке сгенерированных вопросов: $e');
      return [];
    }
  }

  Future<void> insertGeneratedQuestions(List<Question> questions) async {
    try {
      final db = await database;

      for (var question in questions) {
        await db.insert(
          'questions',
          {
            'question': question.question,
            'correct_answer': question.correctAnswer,
            'incorrect_answers': question.incorrectAnswers.join('|')
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      print('Вопросы успешно добавлены');
    } catch (e) {
      print('Ошибка при добавлении вопросов: $e');
    }
  }

  Future<void> deleteGeneratedQuestion(String id) async {
    try {
      final db = await database;
      await db.delete(
        'generated',
        where: 'id = ?',
        whereArgs: [id],
      );
      print('Вопрос успешно удален');
    } catch (e) {
      print('Ошибка при удалении вопроса: $e');
    }
  }

  Future<List<Question>> fetchTestQuestionsById(int testId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('test_questions_$testId');

      if (maps.isEmpty) {
        print('Вопросы для теста не найдены');
        return [];
      }

      return List.generate(maps.length, (i) {
        return Question(
          id: maps[i]['id'].toString(),
          question: maps[i]['question'],
          correctAnswer: maps[i]['correctAnswer'],
          incorrectAnswers: maps[i]['incorrectAnswers'].split('|'),
          category: '',
          clarification: '',
        );
      });
    } catch (e) {
      print('Ошибка при загрузке вопросов теста: $e');
      return [];
    }
  }


  // Add these methods to the existing DatabaseHelper class

  Future<int> createTestFromGeneratedQuestions(String testName) async {
    try {
      final db = await database;

      // Create test record
      int testId = await db.insert('tests', {
        'name': testName,
        'created_at': DateTime.now().toIso8601String()
      });

      // Fetch generated questions
      List<Question> generatedQuestions = await fetchGeneratedQuestions();

      // Save generated questions to test
      await saveQuestionsToTest(testId, generatedQuestions);

      return testId;
    } catch (e) {
      print('Ошибка при создании теста из сгенерированных вопросов: $e');
      return -1;
    }
  }

  Future<void> deleteAllGeneratedQuestions() async {
    try {
      final db = await database;
      await db.delete('generated');
      print('Все сгенерированные вопросы удалены');
    } catch (e) {
      print('Ошибка при удалении сгенерированных вопросов: $e');
    }
  }

  // Получить список всех созданных тестов
  Future<List<Map<String, dynamic>>> getAllTests() async {
    final db = await database;
    return await db.query('tests');
  }

// Получить вопросы для конкретного теста
  Future<List<Question>> getTestQuestions(int testId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'generated_questions',
      where: 'test_id = ?',
      whereArgs: [testId],
    );
    return List.generate(maps.length, (i) {
      return Question(
        id: maps[i]['id'].toString(),
        question: maps[i]['question'],
        correctAnswer: maps[i]['correct_answer'],
        incorrectAnswers: (maps[i]['incorrect_answers'] as String).split('|'),
        category: maps[i]['category'] ?? '',
        clarification: maps[i]['clarification'] ?? '',
      );
    });
  }
}




