import 'package:flutter_test/flutter_test.dart';
import 'package:tras_phone/features/auth/domain/entities/user_entity.dart';

void main() {
  final now = DateTime(2024, 1, 1);

  UserEntity createUser({
    String id = '1',
    String phone = '+966500000000',
    String? email,
    String userType = 'customer',
    String status = 'active',
    String? referralCode,
    DateTime? lastLoginAt,
  }) {
    return UserEntity(
      id: id,
      phone: phone,
      email: email,
      userType: userType,
      status: status,
      referralCode: referralCode,
      lastLoginAt: lastLoginAt,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('Status getters', () {
    test('isActive returns true when status is active', () {
      expect(createUser(status: 'active').isActive, isTrue);
    });

    test('isActive returns false when status is not active', () {
      expect(createUser(status: 'pending').isActive, isFalse);
    });

    test('isPending returns true when status is pending', () {
      expect(createUser(status: 'pending').isPending, isTrue);
    });

    test('isPending returns false when status is not pending', () {
      expect(createUser(status: 'active').isPending, isFalse);
    });

    test('isSuspended returns true when status is suspended', () {
      expect(createUser(status: 'suspended').isSuspended, isTrue);
    });

    test('isSuspended returns false when status is not suspended', () {
      expect(createUser(status: 'active').isSuspended, isFalse);
    });
  });

  group('UserType getters', () {
    test('isCustomer returns true for customer type', () {
      expect(createUser(userType: 'customer').isCustomer, isTrue);
    });

    test('isCustomer returns false for admin type', () {
      expect(createUser(userType: 'admin').isCustomer, isFalse);
    });

    test('isAdmin returns true for admin type', () {
      expect(createUser(userType: 'admin').isAdmin, isTrue);
    });

    test('isAdmin returns false for customer type', () {
      expect(createUser(userType: 'customer').isAdmin, isFalse);
    });
  });

  group('Equatable', () {
    test('two users with same props should be equal', () {
      final u1 = createUser();
      final u2 = createUser();
      expect(u1, equals(u2));
    });

    test('two users with different id should not be equal', () {
      final u1 = createUser(id: '1');
      final u2 = createUser(id: '2');
      expect(u1, isNot(equals(u2)));
    });

    test('two users with different phone should not be equal', () {
      final u1 = createUser(phone: '+966500000001');
      final u2 = createUser(phone: '+966500000002');
      expect(u1, isNot(equals(u2)));
    });

    test('props includes id, phone, email, userType, status', () {
      final user = createUser(email: 'test@test.com');
      expect(user.props, [
        '1',
        '+966500000000',
        'test@test.com',
        'customer',
        'active',
      ]);
    });

    test('email difference makes users not equal', () {
      final u1 = createUser(email: 'a@a.com');
      final u2 = createUser(email: 'b@b.com');
      expect(u1, isNot(equals(u2)));
    });
  });
}
