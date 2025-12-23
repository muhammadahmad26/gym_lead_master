class Plan {
  final String id;
  final String name;
  final String duration; // e.g., "Monthly", "Yearly"
  final double price;
  final List<String> features;

  Plan({
    required this.id,
    required this.name,
    required this.duration,
    required this.price,
    required this.features,
  });
}
