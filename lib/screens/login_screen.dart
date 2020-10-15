import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  bool _codeSent = false;
  String _phoneNumber;
  String _smsCode;
  String _verificationId;
  bool _loadingPhone = false;
  bool _loadingOtp = false;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        exit(0);
        return;
      },
      child: SafeArea(
        child: Scaffold(
          body: SingleChildScrollView(
            child: _codeSent
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 32.0,
                      ),
                      Container(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Verify OTP',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline3
                                  .copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            SizedBox(
                              height: 8.0,
                            ),
                            Text(
                              'Enter SMS Code sent your phone number.',
                              style: Theme.of(context).textTheme.headline6,
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 24.0,
                      ),
                      Container(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Container(
                              child: TextFormField(
                                controller: _codeController,
                                style: TextStyle(fontSize: 24.0),
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'SMS Code',
                                  labelStyle: TextStyle(fontSize: 18.0),
                                  hintText: '123-456',
                                  hintStyle: TextStyle(fontSize: 24.0),
                                  // prefixText: '+91  ',
                                ),
                                maxLength: 6,
                                validator: (String value) {
                                  if (value.isEmpty) {
                                    return 'SMS Code can not be empty';
                                  } else if (value.length != 6) {
                                    return 'SMS Code must be of 6 digits';
                                  }

                                  return null;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    _smsCode = value;
                                  });
                                },
                              ),
                            ),
                            SizedBox(
                              height: 24.0,
                            ),
                            RaisedButton(
                              padding: EdgeInsets.all(20.0),
                              color: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0)),
                              child: _loadingOtp
                                  ? Container(
                                      height: 24.0,
                                      width: 24.0,
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation(
                                            Colors.white),
                                      ),
                                    )
                                  : Text(
                                      'VERIFY',
                                      style: Theme.of(context)
                                          .textTheme
                                          .button
                                          .copyWith(
                                            color: Colors.white,
                                            fontSize: 20.0,
                                          ),
                                    ),
                              onPressed: () async {
                                print(
                                    'VerificationId: $_verificationId \n SmsCode: $_smsCode');
                                setState(() {
                                  _loadingOtp = true;
                                });
                                try {
                                  AuthCredential authCreds =
                                      PhoneAuthProvider.credential(
                                          verificationId: _verificationId,
                                          smsCode: _smsCode);
                                  UserCredential userCredential =
                                      await FirebaseAuth.instance
                                          .signInWithCredential(authCreds);
                                  User user = userCredential.user;
                                  _codeController.clear();
                                } catch (e) {
                                  Scaffold.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'OTP Verification Failed. Please')),
                                  );
                                }
                                await Future.delayed(Duration(seconds: 1), () {
                                  setState(() {
                                    _loadingPhone = false;
                                  });
                                });
                              },
                            ),
                            SizedBox(
                              height: 32.0,
                            ),
                            FlatButton(
                              onPressed: () {
                                setState(() {
                                  _codeSent = false;
                                });
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Not recieved OTP ?',
                                    style: Theme.of(context)
                                        .textTheme
                                        .button
                                        .copyWith(
                                          fontSize: 16.0,
                                        ),
                                  ),
                                  SizedBox(
                                    width: 16.0,
                                  ),
                                  Text(
                                    'RESEND',
                                    style: Theme.of(context)
                                        .textTheme
                                        .button
                                        .copyWith(
                                          color: Theme.of(context).primaryColor,
                                          fontSize: 16.0,
                                        ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 32.0,
                      ),
                      Container(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Verify Phone',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline3
                                  .copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            SizedBox(
                              height: 8.0,
                            ),
                            Text(
                              'We will send you a 6-digit sms code.',
                              style: Theme.of(context).textTheme.headline6,
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 24.0,
                      ),
                      Container(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Container(
                              child: TextFormField(
                                controller: _phoneController,
                                style: TextStyle(fontSize: 24.0),
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Phone number',
                                  labelStyle: TextStyle(fontSize: 18.0),
                                  hintText: '987-654-3210',
                                  hintStyle: TextStyle(fontSize: 24.0),
                                  prefixText: '+91  ',
                                ),
                                maxLength: 10,
                                validator: (String value) {
                                  if (value.isEmpty) {
                                    return 'Phone number can not be empty';
                                  } else if (value.length != 10) {
                                    return 'Phone number must be of 10 digits';
                                  }

                                  return null;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    _phoneNumber = '+91' + value;
                                  });
                                },
                              ),
                            ),
                            SizedBox(
                              height: 24.0,
                            ),
                            RaisedButton(
                              padding: EdgeInsets.all(20.0),
                              color: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0)),
                              child: _loadingPhone
                                  ? Container(
                                      height: 24.0,
                                      width: 24.0,
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation(
                                            Colors.white),
                                      ),
                                    )
                                  : Text(
                                      'SEND OTP',
                                      style: Theme.of(context)
                                          .textTheme
                                          .button
                                          .copyWith(
                                            color: Colors.white,
                                            fontSize: 20.0,
                                          ),
                                    ),
                              onPressed: () async {
                                print(_phoneNumber);
                                setState(() {
                                  _loadingPhone = true;
                                });
                                _phoneController.clear();
                                final PhoneVerificationCompleted verified =
                                    (AuthCredential authResult) async {
                                  UserCredential userCredential =
                                      await FirebaseAuth.instance
                                          .signInWithCredential(authResult);
                                  User user = userCredential.user;
                                };

                                final PhoneVerificationFailed
                                    verificationfailed =
                                    (FirebaseAuthException authException) {
                                  print('${authException.message}');
                                  Scaffold.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'OTP Verification Failed. Please')),
                                  );
                                };

                                final PhoneCodeSent smsSent =
                                    (String verId, [int forceResend]) async {
                                  setState(() {
                                    _verificationId = verId;
                                    _codeSent = true;
                                  });
                                };

                                final PhoneCodeAutoRetrievalTimeout
                                    autoTimeout = (String verId) {
                                  setState(() {
                                    _verificationId = verId;
                                  });
                                };

                                await FirebaseAuth.instance.verifyPhoneNumber(
                                    phoneNumber: _phoneNumber,
                                    // timeout: const Duration(seconds: 5),
                                    verificationCompleted: verified,
                                    verificationFailed: verificationfailed,
                                    codeSent: smsSent,
                                    codeAutoRetrievalTimeout: autoTimeout);
                                await Future.delayed(Duration(seconds: 1), () {
                                  setState(() {
                                    _loadingPhone = false;
                                  });
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
