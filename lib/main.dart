import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(MoodCalendarApp(prefs: prefs));
}

class MoodCalendarApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MoodCalendarApp({Key? key, required this.prefs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Календарь настроения',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MoodCalendarScreen(prefs: prefs),
    );
  }
}

class MoodCalendarScreen extends StatefulWidget {
  final SharedPreferences prefs;

  const MoodCalendarScreen({Key? key, required this.prefs}) : super(key: key);

  @override
  _MoodCalendarScreenState createState() => _MoodCalendarScreenState();
}

class _MoodCalendarScreenState extends State<MoodCalendarScreen> {
  late DateTime _currentDate;
  late Map<String, String> _moodData;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    _moodData = _loadMoodData();
  }

  // Загрузка данных из SharedPreferences
  Map<String, String> _loadMoodData() {
    final keys = widget.prefs.getKeys();
    final Map<String, String> data = {};
    for (final key in keys) {
      final value = widget.prefs.getString(key);
      if (value != null) {
        data[key] = value;
      }
    }
    return data;
  }

  // Сохранение данных в SharedPreferences
  void _saveMoodData() {
    _moodData.forEach((key, value) {
      widget.prefs.setString(key, value);
    });
  }

  // Установка настроения для дня
  void _setMood(DateTime day, String mood) {
    setState(() {
      if (mood == 'none') {
        _moodData.remove(day.toIso8601String());
      } else {
        _moodData[day.toIso8601String()] = mood;
      }
      _saveMoodData();
    });
  }

  // Получение настроения для дня
  String _getMood(DateTime day) {
    return _moodData[day.toIso8601String()] ?? 'none';
  }

  // Показ меню выбора настроения
  void _showMoodMenu(DateTime day, BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.thumb_up, color: Colors.green),
              title: Text('Хороший день'),
              onTap: () {
                _setMood(day, 'good');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.thumb_down, color: Colors.red),
              title: Text('Плохой день'),
              onTap: () {
                _setMood(day, 'bad');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.cancel, color: Colors.grey),
              title: Text('Отмена'),
              onTap: () {
                _setMood(day, 'none');
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // Построение календаря
  List<Widget> _buildCalendar() {
    final daysInMonth = DateTime(_currentDate.year, _currentDate.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_currentDate.year, _currentDate.month, 1);
    final startingOffset = firstDayOfMonth.weekday - 1;

    List<Widget> days = [];

    // Пустые дни в начале месяца
    for (int i = 0; i < startingOffset; i++) {
      days.add(Container());
    }

    // Дни месяца
    for (int day = 1; day <= daysInMonth; day++) {
      final currentDay = DateTime(_currentDate.year, _currentDate.month, day);
      final mood = _getMood(currentDay);

      days.add(
        GestureDetector(
          onTap: () {
            _showMoodMenu(currentDay, context);
          },
          child: Container(
            decoration: BoxDecoration(
              color: mood == 'good'
                  ? Colors.green
                  : mood == 'bad'
                      ? Colors.red
                      : Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: TextStyle(
                  color: mood == 'none' ? Colors.black : Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return days;
  }

  // Названия дней недели
  Widget _buildWeekdays() {
    return Row(
      children: ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'].map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Сбор статистики за месяц
  Map<String, int> _getMonthlyStats() {
    int goodDays = 0;
    int badDays = 0;

    final daysInMonth = DateTime(_currentDate.year, _currentDate.month + 1, 0).day;
    for (int day = 1; day <= daysInMonth; day++) {
      final currentDay = DateTime(_currentDate.year, _currentDate.month, day);
      final mood = _getMood(currentDay);
      if (mood == 'good') {
        goodDays++;
      } else if (mood == 'bad') {
        badDays++;
      }
    }

    return {'good': goodDays, 'bad': badDays};
  }

  // Показ статистики
  void _showStats(BuildContext context) {
    final stats = _getMonthlyStats();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Статистика за месяц'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Хороших дней: ${stats['good']}'),
              Text('Плохих дней: ${stats['bad']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final monthNames = [
      'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
      'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${monthNames[_currentDate.month - 1]} ${_currentDate.year}',
          style: TextStyle(fontSize: 24),
        ),
        actions: [
          // Кнопка "Статистика"
          IconButton(
            icon: Icon(Icons.bar_chart, color: Colors.white),
            onPressed: () {
              _showStats(context);
            },
          ),
          // Кнопка "Сегодня"
          IconButton(
            icon: Icon(Icons.today, color: Colors.white),
            onPressed: () {
              setState(() {
                _currentDate = DateTime.now(); // Возврат к текущей дате
              });
            },
          ),
          // Кнопка "<" для перехода к предыдущему месяцу
          IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
              });
            },
          ),
          // Кнопка ">" для перехода к следующему месяцу
          IconButton(
            icon: Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Названия дней недели
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: _buildWeekdays(),
          ),
          // Календарь
          Expanded(
            child: GridView.count(
              padding: EdgeInsets.all(16),
              crossAxisCount: 7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: _buildCalendar(),
            ),
          ),
        ],
      ),
    );
  }
}