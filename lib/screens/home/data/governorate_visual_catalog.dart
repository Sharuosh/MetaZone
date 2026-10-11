import 'package:flutter/foundation.dart';

enum GovernorateVisualPeriod {
  morning,
  afternoon,
  night,
}

class GovernorateVisual {
  const GovernorateVisual({
    required this.id,
    required this.name,
    required this.code,
    required this.morningPath,
    required this.afternoonPath,
    required this.nightPath,
  });

  final String id;
  final String name;
  final String code;

  final String morningPath;
  final String afternoonPath;
  final String nightPath;

  String assetForPeriod(
      GovernorateVisualPeriod period,
      ) {
    switch (period) {
      case GovernorateVisualPeriod.morning:
        return morningPath;

      case GovernorateVisualPeriod.afternoon:
        return afternoonPath;

      case GovernorateVisualPeriod.night:
        return nightPath;
    }
  }
}

class GovernorateVisualCatalog {
  GovernorateVisualCatalog._();

  static const List<GovernorateVisual> all = [
    GovernorateVisual(
      id: 'cairo',
      name: 'Cairo',
      code: 'CAI',
      morningPath:
      'assets/images/governorates/CAI/MOR.png',
      afternoonPath:
      'assets/images/governorates/CAI/AFT.png',
      nightPath:
      'assets/images/governorates/CAI/NGT.png',
    ),

    GovernorateVisual(
      id: 'giza',
      name: 'Giza',
      code: 'GIZ',
      morningPath:
      'assets/images/governorates/GIZ/MOR.png',
      afternoonPath:
      'assets/images/governorates/GIZ/AFT.png',
      nightPath:
      'assets/images/governorates/GIZ/NGT.png',
    ),

    GovernorateVisual(
      id: 'alexandria',
      name: 'Alexandria',
      code: 'ALX',
      morningPath:
      'assets/images/governorates/ALX/MOR.png',
      afternoonPath:
      'assets/images/governorates/ALX/AFT.png',
      nightPath:
      'assets/images/governorates/ALX/NGT.png',
    ),

    GovernorateVisual(
      id: 'qalyubia',
      name: 'Qalyubia',
      code: 'QLY',
      morningPath:
      'assets/images/governorates/QLY/MOR.png',
      afternoonPath:
      'assets/images/governorates/QLY/AFT.png',
      nightPath:
      'assets/images/governorates/QLY/NGT.png',
    ),

    GovernorateVisual(
      id: 'dakahlia',
      name: 'Dakahlia',
      code: 'DKH',
      morningPath:
      'assets/images/governorates/DKH/MOR.png',
      afternoonPath:
      'assets/images/governorates/DKH/AFT.png',
      nightPath:
      'assets/images/governorates/DKH/NGT.png',
    ),

    GovernorateVisual(
      id: 'sharqia',
      name: 'Sharqia',
      code: 'SHR',
      morningPath:
      'assets/images/governorates/SHR/MOR.png',
      afternoonPath:
      'assets/images/governorates/SHR/AFT.png',
      nightPath:
      'assets/images/governorates/SHR/NGT.png',
    ),

    GovernorateVisual(
      id: 'gharbia',
      name: 'Gharbia',
      code: 'GHB',
      morningPath:
      'assets/images/governorates/GHB/MOR.png',
      afternoonPath:
      'assets/images/governorates/GHB/AFT.png',
      nightPath:
      'assets/images/governorates/GHB/NGT.png',
    ),

    GovernorateVisual(
      id: 'monufia',
      name: 'Monufia',
      code: 'MNF',
      morningPath:
      'assets/images/governorates/MNF/MOR.png',
      afternoonPath:
      'assets/images/governorates/MNF/AFT.png',
      nightPath:
      'assets/images/governorates/MNF/NGT.png',
    ),

    GovernorateVisual(
      id: 'beheira',
      name: 'Beheira',
      code: 'BHR',
      morningPath:
      'assets/images/governorates/BHR/MOR.png',
      afternoonPath:
      'assets/images/governorates/BHR/AFT.png',
      nightPath:
      'assets/images/governorates/BHR/NGT.png',
    ),

    GovernorateVisual(
      id: 'kafr_el_sheikh',
      name: 'Kafr El Sheikh',
      code: 'KFS',
      morningPath:
      'assets/images/governorates/KFS/MOR.png',
      afternoonPath:
      'assets/images/governorates/KFS/AFT.png',
      nightPath:
      'assets/images/governorates/KFS/NGT.png',
    ),

    GovernorateVisual(
      id: 'damietta',
      name: 'Damietta',
      code: 'DMT',
      morningPath:
      'assets/images/governorates/DMT/MOR.png',
      afternoonPath:
      'assets/images/governorates/DMT/AFT.png',
      nightPath:
      'assets/images/governorates/DMT/NGT.png',
    ),

    GovernorateVisual(
      id: 'port_said',
      name: 'Port Said',
      code: 'PSD',
      morningPath:
      'assets/images/governorates/PSD/MOR.png',
      afternoonPath:
      'assets/images/governorates/PSD/AFT.png',
      nightPath:
      'assets/images/governorates/PSD/NGT.png',
    ),

    GovernorateVisual(
      id: 'ismailia',
      name: 'Ismailia',
      code: 'ISM',
      morningPath:
      'assets/images/governorates/ISM/MOR.png',
      afternoonPath:
      'assets/images/governorates/ISM/AFT.png',
      nightPath:
      'assets/images/governorates/ISM/NGT.png',
    ),

    GovernorateVisual(
      id: 'suez',
      name: 'Suez',
      code: 'SUZ',
      morningPath:
      'assets/images/governorates/SUZ/MOR.png',
      afternoonPath:
      'assets/images/governorates/SUZ/AFT.png',
      nightPath:
      'assets/images/governorates/SUZ/NGT.png',
    ),

    GovernorateVisual(
      id: 'north_sinai',
      name: 'North Sinai',
      code: 'NSI',
      morningPath:
      'assets/images/governorates/NSI/MOR.png',
      afternoonPath:
      'assets/images/governorates/NSI/AFT.png',
      nightPath:
      'assets/images/governorates/NSI/NGT.png',
    ),

    GovernorateVisual(
      id: 'south_sinai',
      name: 'South Sinai',
      code: 'SSI',
      morningPath:
      'assets/images/governorates/SSI/MOR.png',
      afternoonPath:
      'assets/images/governorates/SSI/AFT.png',
      nightPath:
      'assets/images/governorates/SSI/NGT.png',
    ),

    GovernorateVisual(
      id: 'red_sea',
      name: 'Red Sea',
      code: 'RDS',
      morningPath:
      'assets/images/governorates/RDS/MOR.png',
      afternoonPath:
      'assets/images/governorates/RDS/AFT.png',
      nightPath:
      'assets/images/governorates/RDS/NGT.png',
    ),

    GovernorateVisual(
      id: 'new_valley',
      name: 'New Valley',
      code: 'NVL',
      morningPath:
      'assets/images/governorates/NVL/MOR.png',
      afternoonPath:
      'assets/images/governorates/NVL/AFT.png',
      nightPath:
      'assets/images/governorates/NVL/NGT.png',
    ),

    GovernorateVisual(
      id: 'matrouh',
      name: 'Matrouh',
      code: 'MTR',
      morningPath:
      'assets/images/governorates/MTR/MOR.png',
      afternoonPath:
      'assets/images/governorates/MTR/AFT.png',
      nightPath:
      'assets/images/governorates/MTR/NGT.png',
    ),

    GovernorateVisual(
      id: 'fayoum',
      name: 'Fayoum',
      code: 'FYM',
      morningPath:
      'assets/images/governorates/FYM/MOR.png',
      afternoonPath:
      'assets/images/governorates/FYM/AFT.png',
      nightPath:
      'assets/images/governorates/FYM/NGT.png',
    ),

    GovernorateVisual(
      id: 'beni_suef',
      name: 'Beni Suef',
      code: 'BSF',
      morningPath:
      'assets/images/governorates/BSF/MOR.png',
      afternoonPath:
      'assets/images/governorates/BSF/AFT.png',
      nightPath:
      'assets/images/governorates/BSF/NGT.png',
    ),

    GovernorateVisual(
      id: 'minya',
      name: 'Minya',
      code: 'MNY',
      morningPath:
      'assets/images/governorates/MNY/MOR.png',
      afternoonPath:
      'assets/images/governorates/MNY/AFT.png',
      nightPath:
      'assets/images/governorates/MNY/NGT.png',
    ),

    GovernorateVisual(
      id: 'asyut',
      name: 'Asyut',
      code: 'ASY',
      morningPath:
      'assets/images/governorates/ASY/MOR.png',
      afternoonPath:
      'assets/images/governorates/ASY/AFT.png',
      nightPath:
      'assets/images/governorates/ASY/NGT.png',
    ),

    GovernorateVisual(
      id: 'sohag',
      name: 'Sohag',
      code: 'SHG',
      morningPath:
      'assets/images/governorates/SHG/MOR.png',
      afternoonPath:
      'assets/images/governorates/SHG/AFT.png',
      nightPath:
      'assets/images/governorates/SHG/NGT.png',
    ),

    GovernorateVisual(
      id: 'qena',
      name: 'Qena',
      code: 'QNA',
      morningPath:
      'assets/images/governorates/QNA/MOR.png',
      afternoonPath:
      'assets/images/governorates/QNA/AFT.png',
      nightPath:
      'assets/images/governorates/QNA/NGT.png',
    ),

    GovernorateVisual(
      id: 'luxor',
      name: 'Luxor',
      code: 'LXR',
      morningPath:
      'assets/images/governorates/LXR/MOR.png',
      afternoonPath:
      'assets/images/governorates/LXR/AFT.png',
      nightPath:
      'assets/images/governorates/LXR/NGT.png',
    ),

    GovernorateVisual(
      id: 'aswan',
      name: 'Aswan',
      code: 'ASW',
      morningPath:
      'assets/images/governorates/ASW/MOR.png',
      afternoonPath:
      'assets/images/governorates/ASW/AFT.png',
      nightPath:
      'assets/images/governorates/ASW/NGT.png',
    ),
  ];

  static GovernorateVisual? byCode(
      String? code,
      ) {
    if (code == null) return null;

    final String normalized =
    _normalize(code);

    for (final GovernorateVisual item in all) {
      if (_normalize(item.code) == normalized) {
        return item;
      }
    }

    return null;
  }

  static GovernorateVisual? resolve(
      String? locationName,
      ) {
    if (locationName == null ||
        locationName.trim().isEmpty) {
      return null;
    }

    final String value =
    _normalize(locationName);

    if (value.isEmpty) {
      return null;
    }

    // Exact code match.
    final GovernorateVisual? codeMatch =
    byCode(value);

    if (codeMatch != null) {
      return codeMatch;
    }

    // Exact English / normalized name.
    for (final GovernorateVisual item in all) {
      if (_normalize(item.name) == value) {
        return item;
      }
    }

    // Common aliases.
    const Map<String, String> aliases = {
      // Cairo
      'cairo governorate': 'CAI',
      'cairo gov': 'CAI',
      'القاهرة': 'CAI',
      'محافظة القاهرة': 'CAI',

      // Giza
      'giza governorate': 'GIZ',
      'giza gov': 'GIZ',
      'الجيزة': 'GIZ',
      'محافظة الجيزة': 'GIZ',

      // Alexandria
      'alexandria governorate': 'ALX',
      'alexandria gov': 'ALX',
      'الإسكندرية': 'ALX',
      'الاسكندرية': 'ALX',
      'محافظة الإسكندرية': 'ALX',

      // Qalyubia
      'qalyubia governorate': 'QLY',
      'القليوبية': 'QLY',
      'محافظة القليوبية': 'QLY',

      // Dakahlia
      'dakahlia governorate': 'DKH',
      'dakahlia gov': 'DKH',
      'الدقهلية': 'DKH',
      'محافظة الدقهلية': 'DKH',

      // Sharqia
      'sharqia governorate': 'SHR',
      'sharqia gov': 'SHR',
      'الشرقية': 'SHR',
      'محافظة الشرقية': 'SHR',

      // Gharbia
      'gharbia governorate': 'GHB',
      'الغربية': 'GHB',
      'محافظة الغربية': 'GHB',

      // Monufia
      'monufia governorate': 'MNF',
      'monufia gov': 'MNF',
      'menoufia': 'MNF',
      'المنوفية': 'MNF',
      'محافظة المنوفية': 'MNF',

      // Beheira
      'beheira governorate': 'BHR',
      'beheira gov': 'BHR',
      'البحيرة': 'BHR',
      'محافظة البحيرة': 'BHR',

      // Kafr El Sheikh
      'kafr el sheikh governorate': 'KFS',
      'kafr el sheikh': 'KFS',
      'كفر الشيخ': 'KFS',
      'محافظة كفر الشيخ': 'KFS',

      // Damietta
      'damietta governorate': 'DMT',
      'damietta gov': 'DMT',
      'damietta': 'DMT',
      'دمياط': 'DMT',
      'محافظة دمياط': 'DMT',

      // Port Said
      'port said governorate': 'PSD',
      'port said gov': 'PSD',
      'port said': 'PSD',
      'بورسعيد': 'PSD',
      'محافظة بورسعيد': 'PSD',

      // Ismailia
      'ismailia governorate': 'ISM',
      'ismailia gov': 'ISM',
      'ismailia': 'ISM',
      'الإسماعيلية': 'ISM',
      'الاسماعيلية': 'ISM',
      'محافظة الإسماعيلية': 'ISM',

      // Suez
      'suez governorate': 'SUZ',
      'suez gov': 'SUZ',
      'suez': 'SUZ',
      'السويس': 'SUZ',
      'محافظة السويس': 'SUZ',

      // North Sinai
      'north sinai governorate': 'NSI',
      'north sinai': 'NSI',
      'شمال سيناء': 'NSI',
      'محافظة شمال سيناء': 'NSI',

      // South Sinai
      'south sinai governorate': 'SSI',
      'south sinai': 'SSI',
      'جنوب سيناء': 'SSI',
      'محافظة جنوب سيناء': 'SSI',

      // Red Sea
      'red sea governorate': 'RDS',
      'red sea': 'RDS',
      'البحر الأحمر': 'RDS',
      'البحر الاحمر': 'RDS',
      'محافظة البحر الأحمر': 'RDS',

      // New Valley
      'new valley governorate': 'NVL',
      'new valley': 'NVL',
      'الوادي الجديد': 'NVL',
      'محافظة الوادي الجديد': 'NVL',

      // Matrouh
      'matrouh governorate': 'MTR',
      'matrouh': 'MTR',
      'matruh': 'MTR',
      'مطروح': 'MTR',
      'محافظة مطروح': 'MTR',

      // Fayoum
      'fayoum governorate': 'FYM',
      'fayoum': 'FYM',
      'faiyum': 'FYM',
      'الفيوم': 'FYM',
      'محافظة الفيوم': 'FYM',

      // Beni Suef
      'beni suef governorate': 'BSF',
      'beni suef': 'BSF',
      'بني سويف': 'BSF',
      'محافظة بني سويف': 'BSF',

      // Minya
      'minya governorate': 'MNY',
      'minya': 'MNY',
      'المنيا': 'MNY',
      'محافظة المنيا': 'MNY',

      // Asyut
      'asyut governorate': 'ASY',
      'asyut': 'ASY',
      'assiut': 'ASY',
      'أسيوط': 'ASY',
      'اسيوط': 'ASY',
      'محافظة أسيوط': 'ASY',

      // Sohag
      'sohag governorate': 'SHG',
      'sohag': 'SHG',
      'سوهاج': 'SHG',
      'محافظة سوهاج': 'SHG',

      // Qena
      'qena governorate': 'QNA',
      'qena': 'QNA',
      'قنا': 'QNA',
      'محافظة قنا': 'QNA',

      // Luxor
      'luxor governorate': 'LXR',
      'luxor': 'LXR',
      'الأقصر': 'LXR',
      'الاقصر': 'LXR',
      'محافظة الأقصر': 'LXR',

      // Aswan
      'aswan governorate': 'ASW',
      'aswan': 'ASW',
      'أسوان': 'ASW',
      'اسوان': 'ASW',
      'محافظة أسوان': 'ASW',
    };

    final String? aliasCode =
    aliases[value];

    if (aliasCode != null) {
      return byCode(aliasCode);
    }

    // Extra-safe partial matching for
    // values such as "Damietta Governorate, Egypt".
    for (final GovernorateVisual item in all) {
      final String name =
      _normalize(item.name);

      if (value.contains(name)) {
        return item;
      }
    }

    return null;
  }

  static GovernorateVisual? resolveCode(
      String? locationName,
      ) {
    return resolve(locationName);
  }

  static GovernorateVisualPeriod periodForHour(
      int hour,
      ) {
    if (hour >= 6 && hour <= 13) {
      return GovernorateVisualPeriod.morning;
    }

    if (hour >= 14 && hour <= 21) {
      return GovernorateVisualPeriod.afternoon;
    }

    return GovernorateVisualPeriod.night;
  }

  static GovernorateVisualPeriod periodForDateTime(
      DateTime dateTime,
      ) {
    return periodForHour(dateTime.hour);
  }

  static String periodCodeForDateTime([
    DateTime? dateTime,
  ]) {
    final DateTime now =
        dateTime ?? DateTime.now();

    switch (periodForDateTime(now)) {
      case GovernorateVisualPeriod.morning:
        return 'MOR';

      case GovernorateVisualPeriod.afternoon:
        return 'AFT';

      case GovernorateVisualPeriod.night:
        return 'NGT';
    }
  }

  static String? assetForDateTime(
      String? locationName, {
        DateTime? dateTime,
      }) {
    final GovernorateVisual? governorate =
    resolve(locationName);

    if (governorate == null) {
      return null;
    }

    final GovernorateVisualPeriod period =
    periodForDateTime(
      dateTime ?? DateTime.now(),
    );

    return governorate.assetForPeriod(
      period,
    );
  }

  static String? assetFor({
    required String? locationName,
    DateTime? dateTime,
  }) {
    return assetForDateTime(
      locationName,
      dateTime: dateTime,
    );
  }

  static void debugPrintCatalog() {
    for (final GovernorateVisual item in all) {
      debugPrint(
        '${item.code} → '
            '${item.name} | '
            '${item.morningPath} | '
            '${item.afternoonPath} | '
            '${item.nightPath}',
      );
    }
  }

  static String _normalize(
      String value,
      ) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(
      'أ',
      'ا',
    )
        .replaceAll(
      'إ',
      'ا',
    )
        .replaceAll(
      'آ',
      'ا',
    )
        .replaceAll(
      'ة',
      'ه',
    )
        .replaceAll(
      'ى',
      'ي',
    )
        .replaceAll(
      RegExp(r'[_\-]+'),
      ' ',
    )
        .replaceAll(
      RegExp(r'\s+'),
      ' ',
    );
  }
}