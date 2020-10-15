import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_files_and_screenshot_widgets/share_files_and_screenshot_widgets.dart';
import 'package:skepsi/models/category_model.dart';
import 'package:skepsi/models/quote_model.dart';
import 'package:skepsi/screens/category_list_screen.dart';
import 'package:skepsi/screens/create_quote_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GlobalKey _key;
  bool _admin = false;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    isUserAdmin();
    configureFirebase();
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

  configureFirebase() async {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        // _showItemDialog(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        // _navigateToItemDetail(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        // _navigateToItemDetail(message);
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });

    _firebaseMessaging.getToken().then((String token) async {
      assert(token != null);
      // await FirebaseFirestore.instance
      //     .collection('roles')
      //     .doc(FirebaseAuth.instance.currentUser.uid)
      //     .set({
      //   token: true,
      // });
      print(token);
    });
    _firebaseMessaging.subscribeToTopic('quotes');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        exit(0);
        return;
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'SKEPSI',
              style: Theme.of(context).textTheme.headline4.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.power_settings_new,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
              ),
              SizedBox(
                width: 8.0,
              ),
              ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16.0),
                ),
                child: RaisedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CategoryListScreen(),
                      ),
                    );
                  },
                  color: Theme.of(context).primaryColor,
                  child: Text(
                    'Categories',
                    style: Theme.of(context)
                        .textTheme
                        .button
                        .copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0.0,
          ),
          backgroundColor: Color(0xFFFCFBF9),
          body: _buildBody(context),
          floatingActionButton: _admin
              ? FloatingActionButton(
                  child: Icon(Icons.add),
                  backgroundColor: Theme.of(context).primaryColor,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CreateQuoteScreen(
                          title: 'Create Quote',
                        ),
                      ),
                    );
                  },
                )
              : SizedBox(),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('quotes')
          .orderBy('created', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
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
            borderRadius: BorderRadius.circular(16.0),
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0),
                    ),
                    child: Image.network(
                      record.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16.0),
                    bottomRight: Radius.circular(16.0),
                  ),
                ),
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
                          Container(
                            child: Row(
                              children: [
                                _admin
                                    ? InkWell(
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
                                            color: Color(0xFF76BF81),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(16.0),
                                              bottomRight: _admin
                                                  ? Radius.circular(0.0)
                                                  : Radius.circular(16.0),
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                    : SizedBox(),
                                InkWell(
                                  onTap: () {
                                    ShareFilesAndScreenshotWidgets()
                                        .shareScreenshot(_key, 800, "Title",
                                            "Name.png", "image/png",
                                            text:
                                                "${record.quote} - ${record.author}");
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.only(
                                        topLeft: _admin
                                            ? Radius.circular(0.0)
                                            : Radius.circular(16.0),
                                        bottomRight: Radius.circular(16.0),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.share,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
