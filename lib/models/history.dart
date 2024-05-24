class History {
  final int id;
  final int userId;
  final String animalType;
  final String animalName;
  final String predictionClass;
  final double predictionProbability;
  final String imageUrl;
  final String formattedCreatedAt;

  History({
    required this.id,
    required this.userId,
    required this.animalType,
    required this.animalName,
    required this.predictionClass,
    required this.predictionProbability,
    required this.imageUrl,
    required this.formattedCreatedAt,
  });

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      id: json['id'],
      userId: json['user_id'],
      animalType: json['animal_type'],
      animalName: json['animal_name'],
      predictionClass: json['prediction_class'],
      predictionProbability: json['prediction_probability'].toDouble(),
      imageUrl: json['image_url'],
      formattedCreatedAt: json['formatted_created_at'],
    );
  }
}
