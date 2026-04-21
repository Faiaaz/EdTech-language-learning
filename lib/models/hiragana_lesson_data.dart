class HiraganaChar {
  final String kana;
  final String romaji;
  final String row;

  const HiraganaChar(this.kana, this.romaji, this.row);
}

class VocabWord {
  final String kana;
  final String romaji;
  final String meaningEn;
  final String meaningBn;
  final String imagePath;

  const VocabWord({
    required this.kana,
    required this.romaji,
    required this.meaningEn,
    required this.meaningBn,
    required this.imagePath,
  });
}

class HiraganaLesson1Data {
  static const kanaList = <HiraganaChar>[
    HiraganaChar('あ', 'a', 'Vowel'),
    HiraganaChar('い', 'i', 'Vowel'),
    HiraganaChar('う', 'u', 'Vowel'),
    HiraganaChar('え', 'e', 'Vowel'),
    HiraganaChar('お', 'o', 'Vowel'),
    HiraganaChar('か', 'ka', 'K-row'),
    HiraganaChar('き', 'ki', 'K-row'),
    HiraganaChar('く', 'ku', 'K-row'),
    HiraganaChar('け', 'ke', 'K-row'),
    HiraganaChar('こ', 'ko', 'K-row'),
    HiraganaChar('さ', 'sa', 'S-row'),
    HiraganaChar('し', 'shi', 'S-row'),
    HiraganaChar('す', 'su', 'S-row'),
    HiraganaChar('せ', 'se', 'S-row'),
    HiraganaChar('そ', 'so', 'S-row'),
  ];

  static const vocabList = <VocabWord>[
    VocabWord(
      kana: 'あさ',
      romaji: 'asa',
      meaningEn: 'Morning',
      meaningBn: 'সকাল',
      imagePath: 'assets/images/vocab_asa.png',
    ),
    VocabWord(
      kana: 'いえ',
      romaji: 'ie',
      meaningEn: 'House',
      meaningBn: 'বাড়ি',
      imagePath: 'assets/images/vocab_ie.png',
    ),
    VocabWord(
      kana: 'すし',
      romaji: 'sushi',
      meaningEn: 'Sushi (famous food)',
      meaningBn: 'বিখ্যাত খাবার',
      imagePath: 'assets/images/vocab_sushi.png',
    ),
  ];
}
