import 'package:fluid/helpers.dart';
import 'package:test/test.dart';

void main() {
  group('formatDuration', (() {
    test('minutes are displayed as 0 when duration is lower than 60', (() {
      expect(formatDuration(12), '0:12');
      expect(formatDuration(59.99999), '0:59');
    }));

    test('seconds aren\'t being rounded up when (ie. 59.999s doesn\'t become 1:00)', (() {
      expect(formatDuration(59.99999), '0:59');
      expect(formatDuration(32.53245), '0:32');
      expect(formatDuration(91.81215), '1:31');
      expect(formatDuration(3600.9999), '1:00:00');
      expect(formatDuration(3789.56789), '1:03:09');
    }));

    test('seconds are rounded down when duration has a fractional part', (() {
      expect(formatDuration(12.3), '0:12');
      expect(formatDuration(121.99), '2:01');
    }));

    test('seconds/minutes part of the string is two characters long when the value is a single digit', (() {
      expect(formatDuration(123), '2:03');
      expect(formatDuration(3612), '1:00:12');
      expect(formatDuration(4789), '1:19:49');
    }));

    test('hours are displayed when duration is above one hour', (() {
      expect(formatDuration(3601), '1:00:01');
      expect(formatDuration(7327), '2:02:07');
    }));

    test('hours aren\'t displayed when duration is below one hour', (() {
      expect(formatDuration(1937), '32:17');
      expect(formatDuration(3599.99999), '59:59');
    }));
  }));
}
