import 'package:flutter_test/flutter_test.dart';
import 'package:gurbani_wallpapers/models/verse.dart';
import 'package:gurbani_wallpapers/services/banidb_service.dart';

// Placeholder strings only: real Gurbani always comes from BaniDB.
void main() {
  test('parses a search result item', () {
    final verses = Verse.listFromResponse({
      'verses': [
        {
          'verse': {'unicode': 'LINE'},
          'transliteration': {'english': 'translit'},
          'translation': {
            'en': {'bdb': null, 'ms': 'meaning ms', 'ssk': 'meaning ssk'},
          },
          'pageNo': 1,
          'source': {'english': 'Source Name', 'pageNo': 1},
        },
        {
          'verse': {'unicode': '  '},
        },
      ],
    });
    expect(verses, hasLength(1));
    expect(verses.first.gurmukhi, 'LINE');
    expect(verses.first.transliteration, 'translit');
    expect(verses.first.meaning, 'meaning ms');
    expect(verses.first.reference, 'Source Name, Ang 1');
  });

  test('random shabad uses shabadInfo source', () {
    final verses = Verse.listFromResponse({
      'shabadInfo': {
        'source': {'english': 'Source Name', 'pageNo': 5},
      },
      'verses': [
        {
          'verse': {'unicode': 'LINE'},
          'pageNo': 6,
        },
      ],
    });
    expect(verses.single.reference, 'Source Name, Ang 6');
  });

  test('ignores malformed responses', () {
    expect(Verse.listFromResponse(null), isEmpty);
    expect(Verse.listFromResponse({'verses': 'x'}), isEmpty);
  });

  test('chooses search type from script and mode', () {
    expect(BaniDbService.searchTypeFor('abc', SearchMode.firstLetters), 7);
    expect(BaniDbService.searchTypeFor('ਕ', SearchMode.firstLetters), 1);
    expect(BaniDbService.searchTypeFor('abc', SearchMode.wholeWords), 4);
    expect(BaniDbService.searchTypeFor('ਕ', SearchMode.wholeWords), 2);
  });

  test('parses every line of a Hukamnama, with its shabad source and Ang', () {
    final verses = Verse.listFromHukamnama({
      'shabads': [
        {
          'shabadInfo': {
            'pageNo': 7,
            'source': {'english': 'Source Name'},
          },
          'verses': [
            {
              'verse': {'unicode': 'LINE ONE'},
            },
            {
              'verse': {'unicode': 'LINE TWO'},
              'pageNo': 8,
            },
            {
              'verse': {'unicode': ' '},
            },
          ],
        },
      ],
    });
    expect(verses.map((v) => v.gurmukhi), ['LINE ONE', 'LINE TWO']);
    expect(verses[0].reference, 'Source Name, Ang 7');
    expect(verses[1].reference, 'Source Name, Ang 8');
  });

  test('ignores a malformed Hukamnama response', () {
    expect(Verse.listFromHukamnama(null), isEmpty);
    expect(Verse.listFromHukamnama({'shabads': 'x'}), isEmpty);
  });
}
