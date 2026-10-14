import 'package:flutter/material.dart';

enum Vessel { glass, mug, bottle, wine, can, cocktail, bowl }

enum Sex { male, female, pregnant, breastfeeding, other }

enum Activity { low, medium, high, veryHigh }

enum Climate { cold, temperate, hot, veryHot }

class Beverage {
  final String id;
  final String en;
  final String hi;
  final String mr;
  final String category; // tea, coffee, milk, sugar, fruit, active, mocktail, alcohol, other, indian
  final int hydration; // percent, can be negative for strong alcohol
  final int caffeine; // mg per 250 ml
  final String? alcohol; // light / medium / strong
  final Color color;
  final Vessel vessel;
  final int kcal; // per 250 ml

  const Beverage({
    required this.id,
    required this.en,
    required this.hi,
    required this.mr,
    required this.category,
    required this.hydration,
    required this.color,
    this.caffeine = 0,
    this.alcohol,
    this.vessel = Vessel.glass,
    this.kcal = 0,
  });

  String name(String lang) {
    if (lang == 'hi') return hi;
    if (lang == 'mr') return mr;
    return en;
  }
}

class Entry {
  final String id;
  final int ts; // epoch ms
  final String beverageId;
  final int volumeMl;
  final int hydrationMl;

  Entry({
    required this.id,
    required this.ts,
    required this.beverageId,
    required this.volumeMl,
    required this.hydrationMl,
  });

  DateTime get time => DateTime.fromMillisecondsSinceEpoch(ts);

  Map<String, dynamic> toJson() => {
        'id': id,
        'ts': ts,
        'b': beverageId,
        'v': volumeMl,
        'h': hydrationMl,
      };

  factory Entry.fromJson(Map<String, dynamic> j) => Entry(
        id: j['id'] as String,
        ts: j['ts'] as int,
        beverageId: j['b'] as String,
        volumeMl: j['v'] as int,
        hydrationMl: j['h'] as int,
      );
}

String dayKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime dayStart(DateTime d) => DateTime(d.year, d.month, d.day);
