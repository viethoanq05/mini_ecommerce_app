class Address {
  Address({
    required this.id,
    required this.name,
    required this.phone,
    required this.addressLine,
    required this.city,
  });

  final String id;
  final String name;
  final String phone;
  final String addressLine;
  final String city;

  String get display => '$name • $phone\n$addressLine, $city';
}
