import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CreateCategoryScreen extends StatefulWidget {
  final String title;
  final String id;
  final String categoryName;

  const CreateCategoryScreen({Key key, this.title, this.categoryName, this.id})
      : super(key: key);
  @override
  _CreateCategoryScreenState createState() => _CreateCategoryScreenState();
}

class _CreateCategoryScreenState extends State<CreateCategoryScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(debugLabel: 'CreateQuote');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _categoryController = TextEditingController();
  String category;
  bool _loading = false;
  bool _loadingDelete = false;

  @override
  void initState() {
    super.initState();
    _categoryController.text = widget.categoryName;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            widget.title,
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
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _categoryController,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    hintText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      category = value;
                    });
                  },
                  onSaved: (value) {
                    setState(() {
                      category = value;
                    });
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Category must not be empty';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 8.0,
                ),
                RaisedButton(
                  color: Theme.of(context).primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: _loading
                      ? Container(
                          height: 24.0,
                          width: 24.0,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text(
                          'SUBMIT',
                          style: Theme.of(context).textTheme.button.copyWith(
                                color: Colors.white,
                                fontSize: 20.0,
                              ),
                        ),
                  onPressed: () async {
                    setState(() {
                      _loading = true;
                    });
                    // await Future.delayed(Duration(seconds: 2));
                    if (_formKey.currentState.validate()) {
                      _formKey.currentState.save();
                      try {
                        if (widget.id != null) {
                          await FirebaseFirestore.instance
                              .collection('categories')
                              .doc(widget.id)
                              .update({
                            'name': category,
                          });
                        } else {
                          await FirebaseFirestore.instance
                              .collection('categories')
                              .add({
                            'name': category,
                          });
                        }

                        Navigator.of(context).pop();
                      } catch (e) {
                        print(e.toString());
                        _scaffoldKey.currentState.showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Quote is not saved. Please try again.')),
                        );
                      }
                    }

                    setState(() {
                      _loading = false;
                    });
                  },
                ),
                SizedBox(
                  height: 8.0,
                ),
                (widget.id != null)
                    ? FlatButton(
                        // color: Theme.of(context).primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: _loadingDelete
                            ? Container(
                                height: 24.0,
                                width: 24.0,
                                child: CircularProgressIndicator(),
                              )
                            : Text(
                                'DELETE',
                                style:
                                    Theme.of(context).textTheme.button.copyWith(
                                          color: Theme.of(context).primaryColor,
                                          fontSize: 20.0,
                                        ),
                              ),
                        onPressed: () async {
                          setState(() {
                            _loadingDelete = true;
                          });
                          // await Future.delayed(Duration(seconds: 2));
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();
                            try {
                              await FirebaseFirestore.instance
                                  .collection('categories')
                                  .doc(widget.id)
                                  .delete();

                              Navigator.of(context).pop();
                            } catch (e) {
                              print(e.toString());
                              _scaffoldKey.currentState.showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Quote is not saved. Please try again.')),
                              );
                            }
                          }

                          setState(() {
                            _loadingDelete = false;
                          });
                        },
                      )
                    : SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
