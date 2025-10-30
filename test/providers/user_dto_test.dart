import 'package:flutter_test/flutter_test.dart';
import 'package:pprincipal/providers/user_dto.dart';

void main() {
  test('UserDTO toMap/toJson/fromMap/fromJson and copyWith', () {
    final dto = UserDTO(
      name: 'Alice',
      email: 'alice@example.com',
      description: 'A user',
      loggedIn: true,
    );

    final map = dto.toMap();
    expect(map['name'], 'Alice');
    expect(map['email'], 'alice@example.com');
    expect(map['description'], 'A user');
    expect(map['loggedIn'], true);

    final json = dto.toJson();
    final fromJson = UserDTO.fromJson(json);
    expect(fromJson, dto);

    final fromMap = UserDTO.fromMap(map);
    expect(fromMap, dto);

    final changed = dto.copyWith(name: 'Bob');
    expect(changed.name, 'Bob');
    expect(changed.email, 'alice@example.com');
    expect(changed.loggedIn, true);
  });
}
