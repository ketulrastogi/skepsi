import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;

  CategoryModel({this.id, this.name});

  factory CategoryModel.fromFirestore(QueryDocumentSnapshot documentSnapshot) {
    if (documentSnapshot == null || documentSnapshot.data() == null)
      return null;

    return CategoryModel(
      id: documentSnapshot.id,
      name: documentSnapshot.data()['name'],
    );
  }
}
