import 'package:flutter_test/flutter_test.dart';
import 'package:gurbani_wallpapers/services/review_prompt.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('counts successful wallpapers and does not ask before the threshold',
      () async {
    SharedPreferences.setMockInitialValues({});
    await ReviewPrompt.recordSuccess();
    await ReviewPrompt.recordSuccess();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt(ReviewPrompt.countKey), 2);
    expect(prefs.getBool(ReviewPrompt.askedKey), isNull);
  });

  test('stops counting once the review has been requested', () async {
    SharedPreferences.setMockInitialValues({
      ReviewPrompt.countKey: 3,
      ReviewPrompt.askedKey: true,
    });
    await ReviewPrompt.recordSuccess();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt(ReviewPrompt.countKey), 3);
  });
}
