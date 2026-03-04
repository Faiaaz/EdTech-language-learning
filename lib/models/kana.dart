/// Represents a single kana character (Hiragana or Katakana).
class Kana {
  final String character;
  final String romaji;
  final String mnemonic;
  final List<String> strokeOrder; // SVG-like path hints for animation
  final String type; // 'hiragana' or 'katakana'
  final String? dakuten; // Dakuten variant if applicable
  final String? dakutenRomaji;

  const Kana({
    required this.character,
    required this.romaji,
    required this.mnemonic,
    this.strokeOrder = const [],
    required this.type,
    this.dakuten,
    this.dakutenRomaji,
  });
}

/// All 46 basic Hiragana characters in traditional A-I-U-E-O order.
class KanaData {
  // ── Sakura Pink accent for JLC ──────────────────────────────────
  static const sakuraPink = 0xFFF06292;
  static const sakuraPinkLight = 0xFFFCE4EC;
  static const sakuraPinkDark = 0xFFE91E63;

  static const List<Kana> hiragana = [
    // ── Vowels (A row) ──
    Kana(character: 'あ', romaji: 'a', mnemonic: 'Looks like an Antenna on a head', type: 'hiragana'),
    Kana(character: 'い', romaji: 'i', mnemonic: 'Two eels swimming', type: 'hiragana'),
    Kana(character: 'う', romaji: 'u', mnemonic: 'A U-shaped mouth whistling', type: 'hiragana'),
    Kana(character: 'え', romaji: 'e', mnemonic: 'An Energetic dancer', type: 'hiragana'),
    Kana(character: 'お', romaji: 'o', mnemonic: 'A golf ball On a tee', type: 'hiragana'),
    // ── K row ──
    Kana(character: 'か', romaji: 'ka', mnemonic: 'A Kite cutting through wind', type: 'hiragana', dakuten: 'が', dakutenRomaji: 'ga'),
    Kana(character: 'き', romaji: 'ki', mnemonic: 'A Key hanging on a hook', type: 'hiragana', dakuten: 'ぎ', dakutenRomaji: 'gi'),
    Kana(character: 'く', romaji: 'ku', mnemonic: 'A Cuckoo bird beak', type: 'hiragana', dakuten: 'ぐ', dakutenRomaji: 'gu'),
    Kana(character: 'け', romaji: 'ke', mnemonic: 'A gate (Keg entrance)', type: 'hiragana', dakuten: 'げ', dakutenRomaji: 'ge'),
    Kana(character: 'こ', romaji: 'ko', mnemonic: 'Two Coins stacked', type: 'hiragana', dakuten: 'ご', dakutenRomaji: 'go'),
    // ── S row ──
    Kana(character: 'さ', romaji: 'sa', mnemonic: 'A Samba dancer twisting', type: 'hiragana', dakuten: 'ざ', dakutenRomaji: 'za'),
    Kana(character: 'し', romaji: 'shi', mnemonic: 'A fish hook (She caught a fish)', type: 'hiragana', dakuten: 'じ', dakutenRomaji: 'ji'),
    Kana(character: 'す', romaji: 'su', mnemonic: 'A Swing set hanging', type: 'hiragana', dakuten: 'ず', dakutenRomaji: 'zu'),
    Kana(character: 'せ', romaji: 'se', mnemonic: 'A mouth Saying something', type: 'hiragana', dakuten: 'ぜ', dakutenRomaji: 'ze'),
    Kana(character: 'そ', romaji: 'so', mnemonic: 'A Sewing needle with thread', type: 'hiragana', dakuten: 'ぞ', dakutenRomaji: 'zo'),
    // ── T row ──
    Kana(character: 'た', romaji: 'ta', mnemonic: 'Letters t and a combined', type: 'hiragana', dakuten: 'だ', dakutenRomaji: 'da'),
    Kana(character: 'ち', romaji: 'chi', mnemonic: 'A Cheerleader posing', type: 'hiragana', dakuten: 'ぢ', dakutenRomaji: 'di'),
    Kana(character: 'つ', romaji: 'tsu', mnemonic: 'A Tsunami wave', type: 'hiragana', dakuten: 'づ', dakutenRomaji: 'du'),
    Kana(character: 'て', romaji: 'te', mnemonic: 'A Telephone pole', type: 'hiragana', dakuten: 'で', dakutenRomaji: 'de'),
    Kana(character: 'と', romaji: 'to', mnemonic: 'A Toe kicking', type: 'hiragana', dakuten: 'ど', dakutenRomaji: 'do'),
    // ── N row ──
    Kana(character: 'な', romaji: 'na', mnemonic: 'A Knot tied tight', type: 'hiragana'),
    Kana(character: 'に', romaji: 'ni', mnemonic: 'A Needle and thread', type: 'hiragana'),
    Kana(character: 'ぬ', romaji: 'nu', mnemonic: 'Noodles in a bowl', type: 'hiragana'),
    Kana(character: 'ね', romaji: 'ne', mnemonic: 'A cat saying Neh', type: 'hiragana'),
    Kana(character: 'の', romaji: 'no', mnemonic: 'A NO sign (circle with line)', type: 'hiragana'),
    // ── H row ──
    Kana(character: 'は', romaji: 'ha', mnemonic: 'A person saying Ha! Ha!', type: 'hiragana', dakuten: 'ば', dakutenRomaji: 'ba'),
    Kana(character: 'ひ', romaji: 'hi', mnemonic: 'A smiling mouth saying Hee!', type: 'hiragana', dakuten: 'び', dakutenRomaji: 'bi'),
    Kana(character: 'ふ', romaji: 'fu', mnemonic: 'Mount Fuji with snow', type: 'hiragana', dakuten: 'ぶ', dakutenRomaji: 'bu'),
    Kana(character: 'へ', romaji: 'he', mnemonic: 'A mountain ridge (Hey, a hill!)', type: 'hiragana', dakuten: 'べ', dakutenRomaji: 'be'),
    Kana(character: 'ほ', romaji: 'ho', mnemonic: 'A HOly cross with flags', type: 'hiragana', dakuten: 'ぼ', dakutenRomaji: 'bo'),
    // ── M row ──
    Kana(character: 'ま', romaji: 'ma', mnemonic: 'Mama with a hat', type: 'hiragana'),
    Kana(character: 'み', romaji: 'mi', mnemonic: 'The number 21 (Me = 21?)', type: 'hiragana'),
    Kana(character: 'む', romaji: 'mu', mnemonic: 'A cow Mooing', type: 'hiragana'),
    Kana(character: 'め', romaji: 'me', mnemonic: 'A Maze with a path', type: 'hiragana'),
    Kana(character: 'も', romaji: 'mo', mnemonic: 'A fisherman with More fish', type: 'hiragana'),
    // ── Y row ──
    Kana(character: 'や', romaji: 'ya', mnemonic: 'A Yak with horns', type: 'hiragana'),
    Kana(character: 'ゆ', romaji: 'yu', mnemonic: 'A Unicorn swimming', type: 'hiragana'),
    Kana(character: 'よ', romaji: 'yo', mnemonic: 'A Yo-yo on a string', type: 'hiragana'),
    // ── R row ──
    Kana(character: 'ら', romaji: 'ra', mnemonic: 'A Rabbit ear', type: 'hiragana'),
    Kana(character: 'り', romaji: 'ri', mnemonic: 'Two Reeds swaying', type: 'hiragana'),
    Kana(character: 'る', romaji: 'ru', mnemonic: 'A loop on a Route', type: 'hiragana'),
    Kana(character: 'れ', romaji: 're', mnemonic: 'A person REaching out', type: 'hiragana'),
    Kana(character: 'ろ', romaji: 'ro', mnemonic: 'A Road winding ahead', type: 'hiragana'),
    // ── W row ──
    Kana(character: 'わ', romaji: 'wa', mnemonic: 'A person saying Wa! (Wow)', type: 'hiragana'),
    Kana(character: 'を', romaji: 'wo', mnemonic: 'A Wobbly wrestler', type: 'hiragana'),
    // ── N ──
    Kana(character: 'ん', romaji: 'n', mnemonic: 'Like the letter N tilted', type: 'hiragana'),
  ];

  static const List<Kana> katakana = [
    // ── Vowels (A row) ──
    Kana(character: 'ア', romaji: 'a', mnemonic: 'An Axe chopping', type: 'katakana'),
    Kana(character: 'イ', romaji: 'i', mnemonic: 'An Eagle\'s beak', type: 'katakana'),
    Kana(character: 'ウ', romaji: 'u', mnemonic: 'An Umbrella top', type: 'katakana'),
    Kana(character: 'エ', romaji: 'e', mnemonic: 'An Elevator going up', type: 'katakana'),
    Kana(character: 'オ', romaji: 'o', mnemonic: 'An Opera singer', type: 'katakana'),
    // ── K row ──
    Kana(character: 'カ', romaji: 'ka', mnemonic: 'A sword Cutting (Ka!)', type: 'katakana', dakuten: 'ガ', dakutenRomaji: 'ga'),
    Kana(character: 'キ', romaji: 'ki', mnemonic: 'A Key with teeth', type: 'katakana', dakuten: 'ギ', dakutenRomaji: 'gi'),
    Kana(character: 'ク', romaji: 'ku', mnemonic: 'A beak going Coo', type: 'katakana', dakuten: 'グ', dakutenRomaji: 'gu'),
    Kana(character: 'ケ', romaji: 'ke', mnemonic: 'A crooked K (Keg)', type: 'katakana', dakuten: 'ゲ', dakutenRomaji: 'ge'),
    Kana(character: 'コ', romaji: 'ko', mnemonic: 'A Corner of a box', type: 'katakana', dakuten: 'ゴ', dakutenRomaji: 'go'),
    // ── S row ──
    Kana(character: 'サ', romaji: 'sa', mnemonic: 'A Saddle on a horse', type: 'katakana', dakuten: 'ザ', dakutenRomaji: 'za'),
    Kana(character: 'シ', romaji: 'shi', mnemonic: 'A Smiley face ;)', type: 'katakana', dakuten: 'ジ', dakutenRomaji: 'ji'),
    Kana(character: 'ス', romaji: 'su', mnemonic: 'A person Skiing down', type: 'katakana', dakuten: 'ズ', dakutenRomaji: 'zu'),
    Kana(character: 'セ', romaji: 'se', mnemonic: 'A mouth Saying hello', type: 'katakana', dakuten: 'ゼ', dakutenRomaji: 'ze'),
    Kana(character: 'ソ', romaji: 'so', mnemonic: 'Two Socks hanging', type: 'katakana', dakuten: 'ゾ', dakutenRomaji: 'zo'),
    // ── T row ──
    Kana(character: 'タ', romaji: 'ta', mnemonic: 'Letters T and A', type: 'katakana', dakuten: 'ダ', dakutenRomaji: 'da'),
    Kana(character: 'チ', romaji: 'chi', mnemonic: 'A Chicken running', type: 'katakana', dakuten: 'ヂ', dakutenRomaji: 'di'),
    Kana(character: 'ツ', romaji: 'tsu', mnemonic: 'A Tsunami (three drops)', type: 'katakana', dakuten: 'ヅ', dakutenRomaji: 'du'),
    Kana(character: 'テ', romaji: 'te', mnemonic: 'A Telephone pole', type: 'katakana', dakuten: 'デ', dakutenRomaji: 'de'),
    Kana(character: 'ト', romaji: 'to', mnemonic: 'A Totem pole', type: 'katakana', dakuten: 'ド', dakutenRomaji: 'do'),
    // ── N row ──
    Kana(character: 'ナ', romaji: 'na', mnemonic: 'A kNife cutting', type: 'katakana'),
    Kana(character: 'ニ', romaji: 'ni', mnemonic: 'Two horizontal lines (Ni = 2)', type: 'katakana'),
    Kana(character: 'ヌ', romaji: 'nu', mnemonic: 'Chopsticks eating Noodles', type: 'katakana'),
    Kana(character: 'ネ', romaji: 'ne', mnemonic: 'A Net catching fish', type: 'katakana'),
    Kana(character: 'ノ', romaji: 'no', mnemonic: 'A single stroke saying NO', type: 'katakana'),
    // ── H row ──
    Kana(character: 'ハ', romaji: 'ha', mnemonic: 'Open mouth Ha Ha!', type: 'katakana', dakuten: 'バ', dakutenRomaji: 'ba'),
    Kana(character: 'ヒ', romaji: 'hi', mnemonic: 'A person saying Hee!', type: 'katakana', dakuten: 'ビ', dakutenRomaji: 'bi'),
    Kana(character: 'フ', romaji: 'fu', mnemonic: 'A Roof (Fu-top)', type: 'katakana', dakuten: 'ブ', dakutenRomaji: 'bu'),
    Kana(character: 'ヘ', romaji: 'he', mnemonic: 'A mountain peak', type: 'katakana', dakuten: 'ベ', dakutenRomaji: 'be'),
    Kana(character: 'ホ', romaji: 'ho', mnemonic: 'A HOly cross', type: 'katakana', dakuten: 'ボ', dakutenRomaji: 'bo'),
    // ── M row ──
    Kana(character: 'マ', romaji: 'ma', mnemonic: 'A Mama\'s arms open', type: 'katakana'),
    Kana(character: 'ミ', romaji: 'mi', mnemonic: 'Three lines (three = Mi)', type: 'katakana'),
    Kana(character: 'ム', romaji: 'mu', mnemonic: 'A cow\'s horns (Moo)', type: 'katakana'),
    Kana(character: 'メ', romaji: 'me', mnemonic: 'An X marks the spot (Me?)', type: 'katakana'),
    Kana(character: 'モ', romaji: 'mo', mnemonic: 'More lines stacked', type: 'katakana'),
    // ── Y row ──
    Kana(character: 'ヤ', romaji: 'ya', mnemonic: 'A Yak charging', type: 'katakana'),
    Kana(character: 'ユ', romaji: 'yu', mnemonic: 'A U-turn sign (Yu-turn)', type: 'katakana'),
    Kana(character: 'ヨ', romaji: 'yo', mnemonic: 'A Yoga pose (three lines)', type: 'katakana'),
    // ── R row ──
    Kana(character: 'ラ', romaji: 'ra', mnemonic: 'A person Running', type: 'katakana'),
    Kana(character: 'リ', romaji: 'ri', mnemonic: 'Two Reeds in a River', type: 'katakana'),
    Kana(character: 'ル', romaji: 'ru', mnemonic: 'A tree Root', type: 'katakana'),
    Kana(character: 'レ', romaji: 're', mnemonic: 'A person REaching up', type: 'katakana'),
    Kana(character: 'ロ', romaji: 'ro', mnemonic: 'A Robot mouth (square)', type: 'katakana'),
    // ── W row ──
    Kana(character: 'ワ', romaji: 'wa', mnemonic: 'A Wine glass', type: 'katakana'),
    Kana(character: 'ヲ', romaji: 'wo', mnemonic: 'A Worm on a hook', type: 'katakana'),
    // ── N ──
    Kana(character: 'ン', romaji: 'n', mnemonic: 'A sharp N slash', type: 'katakana'),
  ];

  /// Returns dakuten variants only for characters that have them.
  static List<Kana> getDakutenList(List<Kana> baseList) {
    return baseList
        .where((k) => k.dakuten != null)
        .map((k) => Kana(
              character: k.dakuten!,
              romaji: k.dakutenRomaji!,
              mnemonic: '${k.mnemonic} (voiced)',
              type: k.type,
            ))
        .toList();
  }
}
