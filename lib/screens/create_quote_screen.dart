import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skepsi/models/category_model.dart';

class CreateQuoteScreen extends StatefulWidget {
  final String title;
  final String id;
  final String quote;
  final String author;
  final String imageUrl;
  final CategoryModel categoryModel;

  const CreateQuoteScreen(
      {Key key,
      this.quote,
      this.author,
      this.imageUrl,
      this.title,
      this.categoryModel,
      this.id})
      : super(key: key);
  @override
  _CreateQuoteScreenState createState() => _CreateQuoteScreenState();
}

class _CreateQuoteScreenState extends State<CreateQuoteScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(debugLabel: 'CreateQuote');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _quoteController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  File _image;
  final picker = ImagePicker();
  String quote;
  String author;
  bool _loading = false;
  bool _loadingDelete = false;
  List<CategoryModel> _categoryList;
  CategoryModel _selectedCategory;

  @override
  void initState() {
    super.initState();
    _quoteController.text = widget.author;
    _authorController.text = widget.quote;

    getCategories();
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  getCategories() async {
    QuerySnapshot qs =
        await FirebaseFirestore.instance.collection('categories').get();
    setState(() {
      _categoryList =
          qs.docs.map((e) => CategoryModel.fromFirestore(e)).toList();
      // print('Category Model Id: ${widget.categoryModel.id}');
      if (widget.categoryModel?.id != null) {
        _selectedCategory = _categoryList
            .firstWhere((element) => (element.id == widget.categoryModel.id));
      }
    });
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
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _quoteController,
                    decoration: InputDecoration(
                      labelText: 'Quote',
                      hintText: 'Quote',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        quote = value;
                      });
                    },
                    onSaved: (value) {
                      setState(() {
                        quote = value;
                      });
                    },
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Quote must not be empty';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  TextFormField(
                    controller: _authorController,
                    decoration: InputDecoration(
                      labelText: 'Author',
                      hintText: 'Author',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        author = value;
                      });
                    },
                    onSaved: (value) {
                      setState(() {
                        author = value;
                      });
                    },
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Author must not be empty';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  DropdownButtonFormField<CategoryModel>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Category',
                      hintText: 'Select Category',
                    ),
                    value: _selectedCategory,
                    items: _categoryList
                        ?.map((category) => DropdownMenuItem(
                              child: Text(category.name.toString()),
                              value: category,
                            ))
                        ?.toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                    onSaved: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                    validator: (value) {
                      if (value.id == null) {
                        return 'Category is not selected';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  InkWell(
                    onTap: () async => getImage(),
                    child: Container(
                      width: MediaQuery.of(context).size.width - 16,
                      height: MediaQuery.of(context).size.width / 2,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: (_image != null)
                          ? Image.file(_image)
                          : (widget.imageUrl != null)
                              ? Image.network(
                                  widget.imageUrl,
                                  fit: BoxFit.cover,
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.image),
                                    SizedBox(
                                      width: 8.0,
                                    ),
                                    Text(
                                      'Select image',
                                      textAlign: TextAlign.center,
                                      style:
                                          Theme.of(context).textTheme.subtitle1,
                                    ),
                                  ],
                                ),
                    ),
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
                          StorageUploadTask _task = uploadFile(context, _image);
                          StorageReference _ref =
                              await _task.onComplete.then((value) => value.ref);
                          String _downloadUrl = await _ref.getDownloadURL();
                          String imageFBPath = await _ref.getPath();

                          if (widget.id != null) {
                            await FirebaseFirestore.instance
                                .collection('quotes')
                                .doc(widget.id)
                                .update({
                              'quote': quote,
                              'author': author,
                              'categoryId': _selectedCategory.id,
                              'categoryName': _selectedCategory.name,
                              'created': FieldValue.serverTimestamp(),
                              'imageUrl': _downloadUrl,
                              'imageFBPath': imageFBPath,
                            });
                          } else {
                            await FirebaseFirestore.instance
                                .collection('quotes')
                                .add({
                              'quote': quote,
                              'author': author,
                              'categoryId': _selectedCategory.id,
                              'categoryName': _selectedCategory.name,
                              'created': FieldValue.serverTimestamp(),
                              'imageUrl': _downloadUrl,
                              'imageFBPath': imageFBPath,
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
                                  style: Theme.of(context)
                                      .textTheme
                                      .button
                                      .copyWith(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 20.0,
                                      ),
                                ),
                          onPressed: () async {
                            setState(() {
                              _loadingDelete = true;
                            });
                            try {
                              await FirebaseFirestore.instance
                                  .collection('quotes')
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
      ),
    );
  }

  /// The user selects a file, and the task is added to the list.
  StorageUploadTask uploadFile(BuildContext context, File file) {
    if (file == null) {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text("No file was selected")));
      return null;
    }

    // Create a Reference to the file
    StorageReference ref = FirebaseStorage.instance
        .ref()
        .child('quotes')
        .child(basename(file.path));

    return ref.putFile(file);
  }
}
