import 'package:fluid/helpers.dart';
import 'package:test/test.dart';

void main() {
  group('formatDuration', (() {
    test(
      'minutes are displayed as 0 when duration is lower than 60',
      () {
        expect(formatDuration(const Duration(seconds: 12)), '0:12');
        expect(
          formatDuration(
            const Duration(
              seconds: 59,
              milliseconds: 999,
            ),
          ),
          '0:59',
        );
      },
    );

    test(
      'seconds aren\'t being rounded up when (ie. 59.999s doesn\'t become 1:00)',
      () {
        expect(
          formatDuration(const Duration(seconds: 59, milliseconds: 999)),
          '0:59',
        );
        expect(
          formatDuration(const Duration(seconds: 32, milliseconds: 532)),
          '0:32',
        );
        expect(
          formatDuration(const Duration(hours: 1, milliseconds: 999)),
          '1:00:00',
        );
        expect(
          formatDuration(
            const Duration(
              minutes: 1,
              seconds: 31,
              milliseconds: 812,
            ),
          ),
          '1:31',
        );
        expect(
          formatDuration(
            const Duration(
              hours: 1,
              minutes: 3,
              seconds: 9,
              milliseconds: 567,
            ),
          ),
          '1:03:09',
        );
      },
    );

    test(
      'seconds are rounded down when duration has a fractional part',
      () {
        expect(
          formatDuration(const Duration(seconds: 12, milliseconds: 300)),
          '0:12',
        );
        expect(
          formatDuration(
              const Duration(minutes: 2, seconds: 1, milliseconds: 999)),
          '2:01',
        );
      },
    );

    test(
      'seconds/minutes part of the string is two characters long when the value is a single digit',
      () {
        expect(
          formatDuration(const Duration(minutes: 2, seconds: 3)),
          '2:03',
        );
        expect(
          formatDuration(const Duration(hours: 1, seconds: 12)),
          '1:00:12',
        );
        expect(
          formatDuration(const Duration(hours: 1, minutes: 19, seconds: 49)),
          '1:19:49',
        );
      },
    );

    test(
      'hours are displayed when duration is above one hour',
      () {
        expect(
          formatDuration(const Duration(hours: 1, seconds: 1)),
          '1:00:01',
        );
        expect(
          formatDuration(const Duration(hours: 2, minutes: 2, seconds: 7)),
          '2:02:07',
        );
      },
    );

    test(
      'hours aren\'t displayed when duration is below one hour',
      () {
        expect(
          formatDuration(const Duration(minutes: 32, seconds: 17)),
          '32:17',
        );
        expect(
          formatDuration(const Duration(minutes: 59, seconds: 59)),
          '59:59',
        );
      },
    );
  }));
}
