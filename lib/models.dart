import 'package:flutter/material.dart';

enum UserRole { customer, worker }

class AppState {
  UserRole? currentRole;
  CustomerProfile? customerProfile;
  WorkerProfile? workerProfile;
}

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
  final double rating;
}

class MockData {
  static final List<WorkerProfile> workers = [
    WorkerProfile(
      fullName: 'Ravi Kumar',
      phone: '9876543210',
      dob: DateTime(1990, 5, 10),
      address: '123 MG Road',
      area: 'Andheri',
      city: 'Mumbai',
      service: 'Electrician',
      experienceYears: 6,
      rating: 4.6,
    ),
    WorkerProfile(
      fullName: 'Aman Singh',
      phone: '9876501234',
      dob: DateTime(1992, 7, 22),
      address: '45 Park Street',
      area: 'Salt Lake',
      city: 'Kolkata',
      service: 'Plumber',
      experienceYears: 4,
      rating: 4.2,
    ),
    WorkerProfile(
      fullName: 'Suresh Patel',
      phone: '9988776655',
      dob: DateTime(1988, 1, 15),
      address: 'Civil Lines',
      area: 'Civil Lines',
      city: 'Nagpur',
      service: 'Electrician',
      experienceYears: 8,
      rating: 4.8,
    ),
    WorkerProfile(
      fullName: 'Pooja Verma',
      phone: '9123456780',
      dob: DateTime(1995, 11, 3),
      address: 'Sector 21',
      area: 'Noida',
      city: 'Delhi NCR',
      service: 'Painter',
      experienceYears: 5,
      rating: 4.4,
    ),
  ];
}


