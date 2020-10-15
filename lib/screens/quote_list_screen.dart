import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:skepsi/models/category_model.dart';
import 'package:skepsi/models/quote_model.dart';
import 'package:skepsi/screens/category_list_screen.dart';
import 'package:skepsi/screens/create_quote_screen.dart';
import 'package:skepsi/widgets/categoryList_widget.dart';
import 'package:skepsi/widgets/home_widget.dart';

class QuoteListScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const QuoteListScreen({Key key, this.categoryId, this.categoryName})
      : super(key: key);
  @override
  _QuoteListScreenState createState() => _QuoteListScreenState();
}

class _QuoteListScreenState extends State<QuoteListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(debugLabel: 'QuoteListScreen');
  final PageController _pageController = PageController();
  GlobalKey _key;
  int _currentIndex = 1;
  List<Widget> widgets = [
    CategoryListWidget(),
    HomeWidget(),
    HomeWidget(),
  ];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Quotes',
            style: Theme.of(context).textTheme.headline4.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          titleSpacing: 4.0,
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
        backgroundColor: Color(0xFFFCFBF9),
        body: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('quotes')
          .where('categoryId', isEqualTo: widget.categoryId)
          // .orderBy('created', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());
        if (snapshot.data.docs.length == 0)
          return Center(
            child: Text(
              'No quotes are available',
              style: Theme.of(context).textTheme.subtitle1,
            ),
          );
        return _buildList(context, snapshot.data.docs);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 8.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = QuoteModel.fromFirebase(data);
    _key = new GlobalKey(debugLabel: record.id);
    return RepaintBoundary(
      key: _key,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(16.0),
              bottomRight: Radius.circular(16.0),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: MediaQuery.of(context).size.width - 32,
                height: MediaQuery.of(context).size.width / 2,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4.0),
                    topRight: Radius.circular(4.0),
                  ),
                  child: Image.network(
                    record.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 16.0,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        '"${record.quote}"',
                        style: Theme.of(context).textTheme.headline6.copyWith(
                              color: Colors.black,
                            ),
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                left: 12.0, top: 8.0, bottom: 12.0),
                            child: Text(
                              record.author,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  .copyWith(
                                      // fontSize: 20.0,
                                      ),
                            ),
                          ),
                          FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('roles')
                                  .doc(FirebaseAuth.instance.currentUser.uid)
                                  .get(),
                              builder: (context,
                                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                                if (!snapshot.hasData) {
                                  return SizedBox();
                                } else {
                                  print(snapshot.data.data().toString());
                                  if (snapshot.data.data() == null ||
                                      !snapshot.data
                                          .data()
                                          .containsKey('admin') ||
                                      !snapshot.data.data()['admin']) {
                                    return SizedBox();
                                  }
                                  return InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CreateQuoteScreen(
                                            title: 'Edit Quote',
                                            id: record.id,
                                            quote: record.quote,
                                            author: record.author,
                                            imageUrl: record.imageUrl,
                                            categoryModel: CategoryModel(
                                              id: record.categoryId,
                                              name: record.categoryName,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(16.0),
                                          bottomRight: Radius.circular(16.0),
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                }
                              }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
