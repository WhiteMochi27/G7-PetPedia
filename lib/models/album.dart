// Contributed by: Tong Qian Ru

import 'package:petpedia/models/photo.dart';

class Album {
  final int id;
  final String name;
  List<Photo> photos;
  
  Album({
    required this.id,
    required this.name,
    required this.photos,
  });
}