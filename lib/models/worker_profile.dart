class WorkerProfile {
  WorkerProfile({
    required this.fullName,
    required this.phone,
    required this.dob,
    required this.address,
    required this.area,
    required this.city,
    required this.service,
    required this.experienceYears,
    this.rating = 4.5,
  });

  final String fullName;
  final String phone;
  final DateTime dob;
  final String address;
  final String area;
  final String city;
  final String service;
  final int experienceYears;
  double rating;
}
