import 'package:flutter_test/flutter_test.dart';
import 'package:pprincipal/providers/user_provider.dart';
import 'package:pprincipal/providers/provide_mapper.dart';
import 'package:pprincipal/providers/user_dto.dart';

void main() {
  test('ProvideMapper maps User <-> UserDTO', () {
    final user = User(
      name: 'Alice',
      email: 'alice@example.com',
      description: 'desc',
      loggedIn: true,
    );

    final dto = ProvideMapper.toDto(user);
    expect(dto.name, user.name);
    expect(dto.email, user.email);
    expect(dto.description, user.description);
    expect(dto.loggedIn, user.loggedIn);

    final back = ProvideMapper.fromDto(dto);
    expect(back.name, user.name);
    expect(back.email, user.email);
    expect(back.description, user.description);
    expect(back.loggedIn, user.loggedIn);
  });
}
