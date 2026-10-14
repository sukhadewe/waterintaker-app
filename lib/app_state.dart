import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/beverages.dart';
import 'i18n.dart';
import 'models.dart';

class AppState extends ChangeNotifier {
  AppState._();
  static final AppState instance = AppState._();

  late SharedPreferences _prefs;

  // ----- profile / settings -----
  bool onboarded = false;
  String lang = 'en';
  bool useOz = false;
  bool weightLbs = false;
  Sex sex = Sex.male;
  double weightKg = 65;
  Activity activity = Activity.medium;
  Climate climate = Climate.hot;
  int? customGoalMl;
  String character = 'sparrow';
  bool soundsOn = true;
  bool premium = false;
  List<String> quickBar = List.of(kDefaultQuickBar);
  Map<String, int> lastAmount = {}; // beverageId -> last volume ml

  // reminders
  bool remindersOn = false;
  int remindIntervalMin = 120;
  int remindStartMin = 8 * 60;
  int remindEndMin = 22 * 60;
  bool smartSkip = true;

  // data
  final List<Entry> entries = [];
  int bestStreak = 0;
  String? celebratedDay;

  static const freeQuickLimit = 6;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs.getString('state');
    if (raw != null) {
      try {
        _fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {}
    }
    final rawEntries = _prefs.getString('entries');
    if (rawEntries != null) {
      try {
        final list = jsonDecode(rawEntries) as List<dynamic>;
        entries
          ..clear()
          ..addAll(list.map((e) => Entry.fromJson(Map<String, dynamic>.from(e as Map))));
        entries.sort((a, b) => a.ts.compareTo(b.ts));
      } catch (_) {}
    }
    currentLang = lang;
  }

  void _fromJson(Map<String, dynamic> j) {
    onboarded = j['onboarded'] as bool? ?? false;
    lang = j['lang'] as String? ?? 'en';
    useOz = j['useOz'] as bool? ?? false;
    weightLbs = j['weightLbs'] as bool? ?? false;
    sex = Sex.values[(j['sex'] as int? ?? 0).clamp(0, Sex.values.length - 1)];
    weightKg = (j['weightKg'] as num? ?? 65).toDouble();
    activity = Activity.values[(j['activity'] as int? ?? 1).clamp(0, Activity.values.length - 1)];
    climate = Climate.values[(j['climate'] as int? ?? 2).clamp(0, Climate.values.length - 1)];
    customGoalMl = j['customGoalMl'] as int?;
    character = j['character'] as String? ?? 'sparrow';
    soundsOn = j['soundsOn'] as bool? ?? true;
    premium = j['premium'] as bool? ?? false;
    final qb = j['quickBar'];
    if (qb is List) {
      quickBar = qb.map((e) => e.toString()).where(kBeverageById.containsKey).toList();
      if (quickBar.isEmpty) quickBar = ['water'];
    }
    final la = j['lastAmount'];
    if (la is Map) {
      lastAmount = la.map((k, v) => MapEntry(k.toString(), (v as num).toInt()));
    }
    remindersOn = j['remindersOn'] as bool? ?? false;
    remindIntervalMin = j['remindIntervalMin'] as int? ?? 120;
    remindStartMin = j['remindStartMin'] as int? ?? 480;
    remindEndMin = j['remindEndMin'] as int? ?? 1320;
    smartSkip = j['smartSkip'] as bool? ?? true;
    bestStreak = j['bestStreak'] as int? ?? 0;
    celebratedDay = j['celebratedDay'] as String?;
  }

  Map<String, dynamic> _toJson() => {
        'onboarded': onboarded,
        'lang': lang,
        'useOz': useOz,
        'weightLbs': weightLbs,
        'sex': sex.index,
        'weightKg': weightKg,
        'activity': activity.index,
        'climate': climate.index,
        'customGoalMl': customGoalMl,
        'character': character,
        'soundsOn': soundsOn,
        'premium': premium,
        'quickBar': quickBar,
        'lastAmount': lastAmount,
        'remindersOn': remindersOn,
        'remindIntervalMin': remindIntervalMin,
        'remindStartMin': remindStartMin,
        'remindEndMin': remindEndMin,
        'smartSkip': smartSkip,
        'bestStreak': bestStreak,
        'celebratedDay': celebratedDay,
      };

  Future<void> save() async {
    await _prefs.setString('state', jsonEncode(_toJson()));
  }

  Future<void> _saveEntries() async {
    await _prefs.setString('entries', jsonEncode(entries.map((e) => e.toJson()).toList()));
  }

  void update(void Function(AppState s) fn) {
    fn(this);
    currentLang = lang;
    save();
    notifyListeners();
  }

  // ----- goal -----
  int get recommendedGoalMl {
    double ml = weightKg * 35;
    switch (sex) {
      case Sex.female:
        ml *= 0.9;
        break;
      case Sex.pregnant:
        ml = ml * 0.9 + 300;
        break;
      case Sex.breastfeeding:
        ml = ml * 0.9 + 700;
        break;
      case Sex.other:
        ml *= 0.95;
        break;
      case Sex.male:
        break;
    }
    const act = [0.9, 1.0, 1.15, 1.3];
    const cl = [0.95, 1.0, 1.1, 1.2];
    ml = ml * act[activity.index] * cl[climate.index];
    final r = (ml / 10).round() * 10;
    return r.clamp(1200, 5000);
  }

  int get goalMl => customGoalMl ?? recommendedGoalMl;

  // ----- entries -----
  List<Entry> entriesFor(DateTime day) {
    final k = dayKey(day);
    return entries.where((e) => dayKey(e.time) == k).toList();
  }

  int hydrationFor(DateTime day) {
    final total = entriesFor(day).fold<int>(0, (s, e) => s + e.hydrationMl);
    return max(0, total);
  }

  int get todayMl => hydrationFor(DateTime.now());

  double progressFor(DateTime day) => (hydrationFor(day) / goalMl).clamp(0.0, 1.0);

  bool goalReached(DateTime day) => hydrationFor(day) >= goalMl;

  Entry addDrink(String beverageId, int volumeMl, {DateTime? at}) {
    final b = beverageById(beverageId);
    final now = at ?? DateTime.now();
    final e = Entry(
      id: '${now.microsecondsSinceEpoch}${Random().nextInt(999)}',
      ts: now.millisecondsSinceEpoch,
      beverageId: beverageId,
      volumeMl: volumeMl,
      hydrationMl: (volumeMl * b.hydration / 100).round(),
    );
    entries.add(e);
    entries.sort((a, b) => a.ts.compareTo(b.ts));
    lastAmount[beverageId] = volumeMl;
    final s = currentStreak;
    if (s > bestStreak) bestStreak = s;
    _saveEntries();
    save();
    notifyListeners();
    return e;
  }

  void removeEntry(String id) {
    entries.removeWhere((e) => e.id == id);
    _saveEntries();
    notifyListeners();
  }

  int get currentStreak {
    var d = dayStart(DateTime.now());
    if (!goalReached(d)) d = d.subtract(const Duration(days: 1));
    var n = 0;
    while (goalReached(d)) {
      n++;
      d = d.subtract(const Duration(days: 1));
      if (n > 3650) break;
    }
    return n;
  }

  Future<void> resetAll() async {
    entries.clear();
    bestStreak = 0;
    celebratedDay = null;
    await _saveEntries();
    await save();
    notifyListeners();
  }

  // ----- formatting -----
  String fmt(int ml, {bool unit = true}) {
    if (useOz) {
      final oz = ml / 29.5735;
      final s = oz >= 100 ? oz.round().toString() : oz.toStringAsFixed(1).replaceAll('.0', '');
      return unit ? '${s}oz' : s;
    }
    return unit ? '${ml}ml' : '$ml';
  }

  String get unitLabel => useOz ? 'oz' : 'ml';

  List<int> get presetAmounts => useOz
      ? [4, 6, 8, 10, 12, 16, 20, 24].map((oz) => (oz * 29.5735).round()).toList()
      : [100, 150, 200, 250, 300, 400, 500, 750];

  String get weightLabel => weightLbs
      ? '${(weightKg * 2.20462).round()} lbs'
      : '${weightKg.round()} kg';
}
