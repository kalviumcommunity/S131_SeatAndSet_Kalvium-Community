import 'package:flutter_test/flutter_test.dart';

import 'package:seat_and_set/admin_panel/services/admin_auth_service.dart';

void main() {
  test('admin authorization requires the exact true custom claim', () {
    expect(AdminAuthService.hasAdminClaim({'admin': true}), isTrue);
    expect(AdminAuthService.hasAdminClaim({'admin': false}), isFalse);
    expect(AdminAuthService.hasAdminClaim({'role': 'admin'}), isFalse);
    expect(AdminAuthService.hasAdminClaim(null), isFalse);
  });
}
