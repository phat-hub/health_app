import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screen.dart'; // import WaterService

class WaterManager extends ChangeNotifier {
  final WaterService _service = WaterService();

  int goal = 2000;
  int defaultCupSize = 200;
  int totalDrank = 0;
  int cupCount = 0;
  int lastDrink = 0;
  bool hasData = false;

  DateTime selectedDate = DateTime.now();
  DateTime firstOpenDate = DateTime.now();

  List<int> _drinkHistory = [];

  WaterManager() {
    _init();
  }

  Future<void> _init() async {
    await _loadPrefs();
    await _service.saveFirstOpenDate(DateTime.now());
    firstOpenDate = await _service.getFirstOpenDate();
    if (DateTime.now().difference(firstOpenDate).inDays > 30) {
      await _service.deleteOldData(30);
    }
    await loadWaterForDate(DateTime.now());
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    goal = prefs.getInt('water_goal') ?? 2000;
    defaultCupSize = prefs.getInt('water_cup') ?? 200;
    notifyListeners();
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('water_goal', goal);
    await prefs.setInt('water_cup', defaultCupSize);
  }

  Future<void> loadWaterForDate(DateTime date) async {
    _drinkHistory = await _service.getDrinkHistory(date);
    _recalculate();
    selectedDate = date;
    notifyListeners();
  }

  void _recalculate() {
    totalDrank = _drinkHistory.fold(0, (sum, e) => sum + e);
    cupCount = _drinkHistory.length;
    lastDrink = cupCount > 0 ? _drinkHistory.last : 0;
    hasData = totalDrank > 0;
  }

  Future<void> addDrink(int ml) async {
    if (!_isToday()) return;
    _drinkHistory.add(ml);
    await _service.saveDrinkHistory(selectedDate, _drinkHistory);
    _recalculate();
    notifyListeners();
  }

  Future<void> removeLastDrink() async {
    if (!_isToday()) return;
    if (_drinkHistory.isEmpty) return;
    _drinkHistory.removeLast();
    await _service.saveDrinkHistory(selectedDate, _drinkHistory);
    _recalculate();
    notifyListeners();
  }

  bool _isToday() {
    final now = DateTime.now();
    return selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;
  }

  void updateGoal(int newGoal) {
    goal = newGoal;
    _savePrefs();
    notifyListeners();
  }

  void updateCupSize(int newSize) {
    defaultCupSize = newSize;
    _savePrefs();
    notifyListeners();
  }

  DateTime getMinSelectableDate() {
    final diff = DateTime.now().difference(firstOpenDate).inDays;
    if (diff > 30) {
      return DateTime.now().subtract(const Duration(days: 30));
    }
    return firstOpenDate;
  }
}
