import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:meal_finder/config/app_constants.dart';
import 'package:meal_finder/utils/debouncer.dart';
import 'package:meal_finder/utils/search_query.dart';

void main() {
  test('SearchQuery trims and caps length', () {
    expect(SearchQuery.sanitize('  pasta  '), 'pasta');
    expect(SearchQuery.sanitize('   '), isEmpty);

    final long = 'a' * (AppConstants.searchMaxLength + 10);
    expect(SearchQuery.sanitize(long).length, AppConstants.searchMaxLength);
  });

  test('Debouncer only runs the last action after delay', () {
    fakeAsync((async) {
      var count = 0;
      String? last;
      final debouncer = Debouncer(duration: AppConstants.searchDebounce);

      debouncer.run(() {
        count++;
        last = 'a';
      });
      debouncer.run(() {
        count++;
        last = 'ab';
      });
      async.elapse(const Duration(milliseconds: 299));
      expect(count, 0);

      async.elapse(const Duration(milliseconds: 1));
      expect(count, 1);
      expect(last, 'ab');

      debouncer.dispose();
    });
  });
}
