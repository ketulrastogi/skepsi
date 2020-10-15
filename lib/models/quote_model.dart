import 'package:cloud_firestore/cloud_firestore.dart';

class QuoteModel {
  final String quote;
  final String author;
  final String id;
  final String categoryId;
  final String categoryName;
  final Timestamp created;
  final String imageUrl;
  final String imageFBPath;

  QuoteModel(
      {this.categoryId,
      this.categoryName,
      this.quote,
      this.author,
      this.id,
      this.created,
      this.imageUrl,
      this.imageFBPath});

  factory QuoteModel.fromFirebase(DocumentSnapshot snapshot) {
    return QuoteModel(
      id: snapshot.id,
      quote: snapshot.data()['quote'],
      author: snapshot.data()['author'],
      categoryId: snapshot.data()['categoryId'],
      categoryName: snapshot.data()['categoryName'],
      created: snapshot.data()['created'],
      imageUrl: snapshot.data()['imageUrl'],
      imageFBPath: snapshot.data()['imageFBPath'],
    );
  }
}
