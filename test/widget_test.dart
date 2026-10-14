import 'package:flutter_test/flutter_test.dart';
import 'package:waterintaker/app_state.dart';

void main() {
  test('goal is within sane range', () {
    final g = AppState.instance.recommendedGoalMl;
    expect(g >= 1200 && g <= 5000, true);
  });
}
