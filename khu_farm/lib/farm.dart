import 'fruit.dart';

class Farm {
  final int id;
  final String brandName;
  final String title;
  final String description;
  final String imageUrl;
  final int userId;
  final List<Fruit>? fruits;

  Farm({
    required this.id,
    required this.brandName,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.userId,
    this.fruits,
  });

  factory Farm.fromJson(Map<String, dynamic> json) {
    List<dynamic>? fruitsJson = json['fruits']?['content'];
    List<Fruit>? fruitsList;
    if (fruitsJson != null) {
      fruitsList = fruitsJson.map((fruitJson) => Fruit.fromJson(fruitJson)).toList();
    }
    
    return Farm(
      id: json['id'],
      brandName: json['brandName'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      userId: json['userId'],
      fruits: fruitsList,
    );
  }
}