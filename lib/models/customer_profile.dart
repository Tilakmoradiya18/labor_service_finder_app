class CustomerProfile {
  CustomerProfile({
    required this.fullName,
    required this.phone,
    required this.dob,
    required this.address,
    required this.area,
    required this.city,
  });

  final String fullName;
  final String phone;
  final DateTime dob;
  final String address;
  final String area;
  final String city;
}
