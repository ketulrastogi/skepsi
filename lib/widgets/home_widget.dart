import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skepsi/models/quote_model.dart';
import 'package:skepsi/screens/create_quote_screen.dart';

class HomeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 56.0,
          left: 0.0,
          right: 0.0,
          bottom: 0.0,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('quotes')
                .orderBy('created', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return LinearProgressIndicator();
              return ListView(
                padding: const EdgeInsets.only(top: 8.0),
                children: snapshot.data.docs.map((data) {
                  final record = QuoteModel.fromFirebase(data);
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Card(
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
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '"${record.quote}"',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6
                                      .copyWith(
                                        color: Colors.black,
                                      ),
                                ),
                                SizedBox(
                                  height: 8.0,
                                ),
                                Container(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        record.author,
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1
                                            .copyWith(
                                                // fontSize: 20.0,
                                                ),
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            width: 48.0,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(48.0),
                                              child: RaisedButton(
                                                padding: EdgeInsets.all(12.0),
                                                elevation: 12.0,
                                                child: Icon(
                                                  Icons.edit,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          CreateQuoteScreen(
                                                        title: 'Edit Quote',
                                                        quote: record.quote,
                                                        author: record.author,
                                                        imageUrl:
                                                            record.imageUrl,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8.0),
                                          Container(
                                            width: 48.0,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(48.0),
                                              child: RaisedButton(
                                                padding: EdgeInsets.all(12.0),
                                                elevation: 12.0,
                                                child: Icon(
                                                  Icons.share,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                                onPressed: () async {
                                                  debugPrint('Hello');
                                                  // String filePath = await capturePng();

                                                  // print('Bytes Length: $bytes');
                                                  // await Share.shareFiles(
                                                  //   [filePath],
                                                  //   text: 'Test',
                                                  //   mimeTypes: ['image/png'],
                                                  //   subject: 'Test Subject',
                                                  // );
                                                },
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
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
                  );
                }).toList(),
              );
            },
          ),
        ),
        Positioned(
          top: 0.0,
          left: 0.0,
          right: 0.0,
          child: Container(
            height: 56.0,
            // color: Colors.green,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 16.0),
            child: Text(
              'SKEPSI',
              style: Theme.of(context).textTheme.headline5.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
