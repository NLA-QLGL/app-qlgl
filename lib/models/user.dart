class User {
  String name;
  String email;
  String phone;
  String address;
  String avatar;
  String memberSince;
  int totalOrders;

  User({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.avatar,
    required this.memberSince,
    required this.totalOrders,
  });

  // Create a copy of the user with updated fields
  User copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? avatar,
    String? memberSince,
    int? totalOrders,
  }) {
    return User(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      avatar: avatar ?? this.avatar,
      memberSince: memberSince ?? this.memberSince,
      totalOrders: totalOrders ?? this.totalOrders,
    );
  }

  // Get a sample user for testing
  static User getSampleUser() {
    return User(
      name: 'Nguyễn Văn Anh',
      email: 'anh.nguyen@example.com',
      phone: '0912 345 678',
      address: 'Số 123, Đường Lê Lợi, Quận Hoàn Kiếm, Hà Nội',
      avatar: 'assets/images/default_profile.png',
      memberSince: '01/2023',
      totalOrders: 15,
    );
  }
}
