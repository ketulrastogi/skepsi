import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:skepsi/models/category_model.dart';
import 'package:skepsi/screens/create_category_screen.dart';
import 'package:skepsi/screens/quote_list_screen.dart';

class CategoryListScreen extends StatefulWidget {
  @override
  _CategoryListScreenState createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  bool _admin = false;

  @override
  void initState() {
    super.initState();
    isUserAdmin();
  }

  isUserAdmin() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('roles')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();

    setState(() {
      _admin = (documentSnapshot.data() != null &&
              documentSnapshot.data().containsKey('admin') &&
              documentSnapshot.data()['admin'] != null)
          ? documentSnapshot.data()['admin']
          : false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Categories',
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

          // automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          titleSpacing: 4.0,
          elevation: 0.0,
        ),
        floatingActionButton: FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('roles')
                .doc(FirebaseAuth.instance.currentUser.uid)
                .get(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (!snapshot.hasData) {
                return SizedBox();
              } else {
                print(snapshot.data.data().toString());
                if (snapshot.data.data() == null ||
                    !snapshot.data.data().containsKey('admin') ||
                    !snapshot.data.data()['admin']) {
                  return SizedBox();
                }
                return FloatingActionButton(
                  child: Icon(Icons.add),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CreateCategoryScreen(
                          title: 'Create Category',
                        ),
                      ),
                    );
                  },
                );
              }
            }),
        body: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance.collection('categories').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              List<CategoryModel> categoryList = snapshot.data.docs
                  .map((QueryDocumentSnapshot documentSnapshot) =>
                      CategoryModel.fromFirestore(documentSnapshot))
                  .toList();
              if (categoryList.length < 1) {
                return Center(
                  child: Text('No data available'),
                );
              }
              return GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
                padding: EdgeInsets.all(16.0),
                children: [
                  ...categoryList.map(
                    (e) {
                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => QuoteListScreen(
                                      categoryId: e.id,
                                      categoryName: e.name,
                                    )),
                          );
                        },
                        child: Stack(
                          children: [
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(context)
                                            .primaryColor
                                            .withOpacity(0.2),
                                        blurRadius: 4.0,
                                        spreadRadius: 0.5,
                                      )
                                    ]),
                                child: Center(
                                  child: Text(
                                    e.name,
                                    style:
                                        Theme.of(context).textTheme.subtitle1,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: _admin
                                  ? InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                CreateCategoryScreen(
                                              title: 'Update Category',
                                              categoryName: e.name,
                                              id: e.id,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(16.0),
                                            bottomLeft: Radius.circular(16.0),
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.edit,
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  : SizedBox(),
                            ),
                          ],
                        ),
                      );
                    },
                  ).toList()
                ],
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}
