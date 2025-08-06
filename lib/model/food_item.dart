class FoodItem {
  final String name;
  final double calories;

  FoodItem({
    required this.name,
    required this.calories,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      name: json['name'] ?? '',
      calories: (json['calories'] ?? 0).toDouble(),
    );
  }
}
