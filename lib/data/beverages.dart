import 'package:flutter/material.dart';
import '../models.dart';

const kCategories = [
  'all',
  'indian',
  'tea',
  'coffee',
  'milk',
  'fruit',
  'sugar',
  'active',
  'mocktail',
  'alcohol',
  'other',
];

const List<Beverage> kBeverages = [
  // ---------- Other / basics ----------
  Beverage(id: 'water', en: 'Water', hi: 'पानी', mr: 'पाणी', category: 'other', hydration: 100, color: Color(0xFF0EC5E8)),
  Beverage(id: 'sparkling', en: 'Sparkling Water', hi: 'सोडा वॉटर', mr: 'सोडा वॉटर', category: 'other', hydration: 100, color: Color(0xFF7FDDF0), vessel: Vessel.bottle),
  Beverage(id: 'warm_water', en: 'Warm Water', hi: 'गुनगुना पानी', mr: 'कोमट पाणी', category: 'other', hydration: 100, color: Color(0xFF9ED8E6), vessel: Vessel.mug),
  Beverage(id: 'soup', en: 'Soup', hi: 'सूप', mr: 'सूप', category: 'other', hydration: 60, color: Color(0xFFE08A4E), vessel: Vessel.bowl, kcal: 80),
  Beverage(id: 'dal_water', en: 'Dal Water', hi: 'दाल का पानी', mr: 'वरणाचे पाणी', category: 'other', hydration: 70, color: Color(0xFFE2B04A), vessel: Vessel.bowl, kcal: 60),
  Beverage(id: 'bone_broth', en: 'Bone Broth', hi: 'बोन ब्रॉथ', mr: 'बोन ब्रॉथ', category: 'other', hydration: 75, color: Color(0xFFC9925C), vessel: Vessel.bowl, kcal: 40),
  Beverage(id: 'aloe', en: 'Aloe Vera Drink', hi: 'एलोवेरा ड्रिंक', mr: 'कोरफड पेय', category: 'other', hydration: 85, color: Color(0xFFB9E3C6), vessel: Vessel.bottle, kcal: 60),

  // ---------- Indian ----------
  Beverage(id: 'chai', en: 'Chai', hi: 'चाय', mr: 'चहा', category: 'indian', hydration: 85, caffeine: 40, color: Color(0xFFC08A5B), vessel: Vessel.mug, kcal: 90),
  Beverage(id: 'masala_chai', en: 'Masala Chai', hi: 'मसाला चाय', mr: 'मसाला चहा', category: 'indian', hydration: 85, caffeine: 40, color: Color(0xFFB27744), vessel: Vessel.mug, kcal: 100),
  Beverage(id: 'filter_coffee', en: 'Filter Coffee', hi: 'फ़िल्टर कॉफ़ी', mr: 'फिल्टर कॉफी', category: 'indian', hydration: 70, caffeine: 90, color: Color(0xFF9A6A4A), vessel: Vessel.mug, kcal: 110),
  Beverage(id: 'lassi', en: 'Lassi', hi: 'लस्सी', mr: 'लस्सी', category: 'indian', hydration: 90, color: Color(0xFFF3E9D2), kcal: 180),
  Beverage(id: 'chaas', en: 'Buttermilk (Chaas)', hi: 'छाछ', mr: 'ताक', category: 'indian', hydration: 110, color: Color(0xFFEDEFE6), kcal: 40),
  Beverage(id: 'nimbu_pani', en: 'Nimbu Pani', hi: 'नींबू पानी', mr: 'लिंबू सरबत', category: 'indian', hydration: 95, color: Color(0xFFE8F08A), kcal: 60),
  Beverage(id: 'coconut', en: 'Coconut Water', hi: 'नारियल पानी', mr: 'नारळ पाणी', category: 'indian', hydration: 105, color: Color(0xFFE6F4EA), vessel: Vessel.bottle, kcal: 45),
  Beverage(id: 'sugarcane', en: 'Sugarcane Juice', hi: 'गन्ने का रस', mr: 'उसाचा रस', category: 'indian', hydration: 85, color: Color(0xFFCBE08A), kcal: 180),
  Beverage(id: 'jaljeera', en: 'Jaljeera', hi: 'जलजीरा', mr: 'जलजीरा', category: 'indian', hydration: 95, color: Color(0xFF9DB86A), kcal: 30),
  Beverage(id: 'aam_panna', en: 'Aam Panna', hi: 'आम पन्ना', mr: 'कैरीचे पन्हे', category: 'indian', hydration: 90, color: Color(0xFFE8D36A), kcal: 120),
  Beverage(id: 'kokum', en: 'Kokum Sharbat', hi: 'कोकम शरबत', mr: 'कोकम सरबत', category: 'indian', hydration: 90, color: Color(0xFFB0306A), kcal: 90),
  Beverage(id: 'sol_kadhi', en: 'Sol Kadhi', hi: 'सोल कढ़ी', mr: 'सोलकढी', category: 'indian', hydration: 90, color: Color(0xFFE6A6C8), vessel: Vessel.bowl, kcal: 90),
  Beverage(id: 'rooh_afza', en: 'Rose Sharbat', hi: 'गुलाब शरबत', mr: 'गुलाब सरबत', category: 'indian', hydration: 85, color: Color(0xFFE0457B), kcal: 120),
  Beverage(id: 'badam_milk', en: 'Badam Milk', hi: 'बादाम दूध', mr: 'बदाम दूध', category: 'indian', hydration: 110, color: Color(0xFFF2DFB8), vessel: Vessel.mug, kcal: 200),
  Beverage(id: 'haldi_milk', en: 'Turmeric Milk', hi: 'हल्दी दूध', mr: 'हळदीचे दूध', category: 'indian', hydration: 115, color: Color(0xFFF0C95A), vessel: Vessel.mug, kcal: 160),
  Beverage(id: 'thandai', en: 'Thandai', hi: 'ठंडाई', mr: 'थंडाई', category: 'indian', hydration: 95, color: Color(0xFFF4E2C4), kcal: 220),
  Beverage(id: 'kadha', en: 'Kadha', hi: 'काढ़ा', mr: 'काढा', category: 'indian', hydration: 90, color: Color(0xFF8A5A3A), vessel: Vessel.mug, kcal: 20),
  Beverage(id: 'ors', en: 'ORS', hi: 'ओआरएस', mr: 'ओआरएस', category: 'indian', hydration: 150, color: Color(0xFFF2A65A), vessel: Vessel.bottle, kcal: 40),
  Beverage(id: 'sattu', en: 'Sattu Drink', hi: 'सत्तू शरबत', mr: 'सत्तू सरबत', category: 'indian', hydration: 90, color: Color(0xFFD8C39A), kcal: 150),

  // ---------- Tea ----------
  Beverage(id: 'green_tea', en: 'Green Tea', hi: 'ग्रीन टी', mr: 'ग्रीन टी', category: 'tea', hydration: 95, caffeine: 25, color: Color(0xFFA9D18E), vessel: Vessel.mug),
  Beverage(id: 'black_tea', en: 'Black Tea', hi: 'काली चाय', mr: 'काळा चहा', category: 'tea', hydration: 90, caffeine: 47, color: Color(0xFF7A4A2A), vessel: Vessel.mug),
  Beverage(id: 'lemon_tea', en: 'Lemon Tea', hi: 'नींबू चाय', mr: 'लिंबू चहा', category: 'tea', hydration: 95, caffeine: 30, color: Color(0xFFD9A54A), vessel: Vessel.mug, kcal: 20),
  Beverage(id: 'herbal_tea', en: 'Herbal Tea', hi: 'हर्बल टी', mr: 'हर्बल टी', category: 'tea', hydration: 100, color: Color(0xFFC7D99A), vessel: Vessel.mug),
  Beverage(id: 'iced_tea', en: 'Iced Tea', hi: 'आइस्ड टी', mr: 'आइस्ड टी', category: 'tea', hydration: 90, caffeine: 30, color: Color(0xFFC9773E), kcal: 90),
  Beverage(id: 'matcha', en: 'Matcha', hi: 'माचा', mr: 'माचा', category: 'tea', hydration: 90, caffeine: 70, color: Color(0xFF8DBF6A), vessel: Vessel.mug),
  Beverage(id: 'bubble_tea', en: 'Bubble Tea', hi: 'बबल टी', mr: 'बबल टी', category: 'tea', hydration: 80, caffeine: 40, color: Color(0xFFCFA88A), kcal: 250),

  // ---------- Coffee ----------
  Beverage(id: 'coffee', en: 'Coffee', hi: 'कॉफ़ी', mr: 'कॉफी', category: 'coffee', hydration: 80, caffeine: 95, color: Color(0xFF6B4226), vessel: Vessel.mug),
  Beverage(id: 'espresso', en: 'Espresso', hi: 'एस्प्रेसो', mr: 'एस्प्रेसो', category: 'coffee', hydration: 40, caffeine: 500, color: Color(0xFF3E2414), vessel: Vessel.mug),
  Beverage(id: 'cappuccino', en: 'Cappuccino', hi: 'कैपुचिनो', mr: 'कॅपुचिनो', category: 'coffee', hydration: 75, caffeine: 110, color: Color(0xFFB98A62), vessel: Vessel.mug, kcal: 120),
  Beverage(id: 'latte', en: 'Latte', hi: 'लाटे', mr: 'लाटे', category: 'coffee', hydration: 80, caffeine: 77, color: Color(0xFFD2AE88), vessel: Vessel.mug, kcal: 150),
  Beverage(id: 'cold_coffee', en: 'Cold Coffee', hi: 'कोल्ड कॉफ़ी', mr: 'कोल्ड कॉफी', category: 'coffee', hydration: 80, caffeine: 80, color: Color(0xFFB08360), kcal: 200),
  Beverage(id: 'decaf', en: 'Decaf Coffee', hi: 'डिकैफ़ कॉफ़ी', mr: 'डिकॅफ कॉफी', category: 'coffee', hydration: 95, caffeine: 4, color: Color(0xFF8C6A50), vessel: Vessel.mug),
  Beverage(id: 'hot_chocolate', en: 'Hot Chocolate', hi: 'हॉट चॉकलेट', mr: 'हॉट चॉकलेट', category: 'coffee', hydration: 85, caffeine: 5, color: Color(0xFF7B4B3A), vessel: Vessel.mug, kcal: 190),

  // ---------- Milk ----------
  Beverage(id: 'milk', en: 'Milk', hi: 'दूध', mr: 'दूध', category: 'milk', hydration: 130, color: Color(0xFFF5F7FA), kcal: 150),
  Beverage(id: 'skim_milk', en: 'Skim Milk', hi: 'टोंड दूध', mr: 'टोंड दूध', category: 'milk', hydration: 125, color: Color(0xFFE9EEF3), kcal: 85),
  Beverage(id: 'almond_milk', en: 'Almond Milk', hi: 'आलमंड मिल्क', mr: 'आल्मंड मिल्क', category: 'milk', hydration: 95, color: Color(0xFFEBDCC5), vessel: Vessel.bottle, kcal: 40),
  Beverage(id: 'soy_milk', en: 'Soy Milk', hi: 'सोया मिल्क', mr: 'सोया मिल्क', category: 'milk', hydration: 95, color: Color(0xFFF1E7CF), vessel: Vessel.bottle, kcal: 100),
  Beverage(id: 'oat_milk', en: 'Oat Milk', hi: 'ओट मिल्क', mr: 'ओट मिल्क', category: 'milk', hydration: 90, color: Color(0xFFE8D9B9), vessel: Vessel.bottle, kcal: 120),
  Beverage(id: 'milkshake', en: 'Milkshake', hi: 'मिल्कशेक', mr: 'मिल्कशेक', category: 'milk', hydration: 80, color: Color(0xFFF2B6C6), kcal: 350),
  Beverage(id: 'kefir', en: 'Kefir', hi: 'केफ़िर', mr: 'केफिर', category: 'milk', hydration: 90, color: Color(0xFFF4F1EA), kcal: 110),

  // ---------- Fruit ----------
  Beverage(id: 'juice', en: 'Juice', hi: 'जूस', mr: 'ज्यूस', category: 'fruit', hydration: 95, color: Color(0xFFF4A23A), kcal: 110),
  Beverage(id: 'orange_juice', en: 'Orange Juice', hi: 'संतरे का जूस', mr: 'संत्र्याचा ज्यूस', category: 'fruit', hydration: 95, color: Color(0xFFF7A531), kcal: 110),
  Beverage(id: 'watermelon', en: 'Watermelon Juice', hi: 'तरबूज़ जूस', mr: 'कलिंगड ज्यूस', category: 'fruit', hydration: 100, color: Color(0xFFF2687A), kcal: 70),
  Beverage(id: 'mosambi', en: 'Mosambi Juice', hi: 'मौसंबी जूस', mr: 'मोसंबी ज्यूस', category: 'fruit', hydration: 95, color: Color(0xFFE9DC7A), kcal: 100),
  Beverage(id: 'smoothie', en: 'Smoothie', hi: 'स्मूदी', mr: 'स्मूदी', category: 'fruit', hydration: 70, color: Color(0xFFE5577E), kcal: 200),
  Beverage(id: 'lemonade', en: 'Lemonade', hi: 'लेमोनेड', mr: 'लेमोनेड', category: 'fruit', hydration: 90, color: Color(0xFFF1EB9A), kcal: 100),

  // ---------- Sugar ----------
  Beverage(id: 'soda', en: 'Soda / Cola', hi: 'कोल्ड ड्रिंक', mr: 'कोल्ड ड्रिंक', category: 'sugar', hydration: 80, caffeine: 25, color: Color(0xFF5A2A26), vessel: Vessel.can, kcal: 105),
  Beverage(id: 'diet_soda', en: 'Diet Soda', hi: 'डाइट सोडा', mr: 'डाएट सोडा', category: 'sugar', hydration: 85, caffeine: 30, color: Color(0xFFB7B3D9), vessel: Vessel.can),
  Beverage(id: 'kombucha', en: 'Kombucha', hi: 'कोम्बुचा', mr: 'कोम्बुचा', category: 'sugar', hydration: 70, caffeine: 14, color: Color(0xFFD08A3E), vessel: Vessel.bottle, kcal: 30),
  Beverage(id: 'ginger_ale', en: 'Ginger Ale', hi: 'जिंजर एल', mr: 'जिंजर एल', category: 'sugar', hydration: 85, color: Color(0xFFE8C46A), vessel: Vessel.can, kcal: 85),

  // ---------- Active ----------
  Beverage(id: 'sports', en: 'Sports Drink', hi: 'स्पोर्ट्स ड्रिंक', mr: 'स्पोर्ट्स ड्रिंक', category: 'active', hydration: 110, color: Color(0xFF4B7BEC), vessel: Vessel.bottle, kcal: 60),
  Beverage(id: 'energy', en: 'Energy Drink', hi: 'एनर्जी ड्रिंक', mr: 'एनर्जी ड्रिंक', category: 'active', hydration: 55, caffeine: 80, color: Color(0xFF3B3FA8), vessel: Vessel.can, kcal: 110),
  Beverage(id: 'protein', en: 'Protein Shake', hi: 'प्रोटीन शेक', mr: 'प्रोटीन शेक', category: 'active', hydration: 80, color: Color(0xFF8A86C9), vessel: Vessel.bottle, kcal: 160),
  Beverage(id: 'electrolyte', en: 'Electrolyte Water', hi: 'इलेक्ट्रोलाइट पानी', mr: 'इलेक्ट्रोलाइट पाणी', category: 'active', hydration: 120, color: Color(0xFF6FD3E8), vessel: Vessel.bottle, kcal: 20),

  // ---------- Mocktail ----------
  Beverage(id: 'virgin_mojito', en: 'Virgin Mojito', hi: 'वर्जिन मोजिटो', mr: 'व्हर्जिन मोजिटो', category: 'mocktail', hydration: 90, color: Color(0xFFC6E8B0), vessel: Vessel.cocktail, kcal: 90),
  Beverage(id: 'virgin_pina', en: 'Virgin Pina Colada', hi: 'वर्जिन पिना कोलाडा', mr: 'व्हर्जिन पिना कोलाडा', category: 'mocktail', hydration: 85, color: Color(0xFFF4E7B0), vessel: Vessel.cocktail, kcal: 180),
  Beverage(id: 'shirley', en: 'Shirley Temple', hi: 'शर्ली टेम्पल', mr: 'शर्ली टेम्पल', category: 'mocktail', hydration: 80, color: Color(0xFFF07A8A), vessel: Vessel.cocktail, kcal: 120),

  // ---------- Alcohol ----------
  Beverage(id: 'beer', en: 'Beer', hi: 'बीयर', mr: 'बिअर', category: 'alcohol', hydration: -30, alcohol: 'light', color: Color(0xFFE9B53A), vessel: Vessel.glass, kcal: 110),
  Beverage(id: 'beer_na', en: 'Beer N/A', hi: 'नॉन-अल्कोहलिक बीयर', mr: 'नॉन-अल्कोहोलिक बिअर', category: 'alcohol', hydration: 70, color: Color(0xFFEACB7A), kcal: 60),
  Beverage(id: 'red_wine', en: 'Red Wine', hi: 'रेड वाइन', mr: 'रेड वाईन', category: 'alcohol', hydration: -80, alcohol: 'medium', color: Color(0xFF8E1B34), vessel: Vessel.wine, kcal: 210),
  Beverage(id: 'white_wine', en: 'White Wine', hi: 'व्हाइट वाइन', mr: 'व्हाईट वाईन', category: 'alcohol', hydration: -80, alcohol: 'medium', color: Color(0xFFEFE3A6), vessel: Vessel.wine, kcal: 200),
  Beverage(id: 'liquor', en: 'Strong Liquor', hi: 'तेज़ शराब', mr: 'कडक दारू', category: 'alcohol', hydration: -250, alcohol: 'strong', color: Color(0xFFC98A3A), vessel: Vessel.glass, kcal: 550),
  Beverage(id: 'cocktail', en: 'Cocktail', hi: 'कॉकटेल', mr: 'कॉकटेल', category: 'alcohol', hydration: -25, alcohol: 'medium', color: Color(0xFFE5577E), vessel: Vessel.cocktail, kcal: 200),
];

final Map<String, Beverage> kBeverageById = {for (final b in kBeverages) b.id: b};

Beverage beverageById(String id) => kBeverageById[id] ?? kBeverages.first;

const kDefaultQuickBar = ['water', 'chai', 'coffee', 'chaas', 'juice', 'milk'];
