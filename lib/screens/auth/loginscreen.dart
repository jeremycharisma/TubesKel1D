import 'dart:async';
import 'package:ConsultDoc/screens/auth/authentication.dart';
import 'package:ConsultDoc/screens/auth/registerscreen.dart';
import 'package:ConsultDoc/screens/user/Homepage.dart';
import 'package:ConsultDoc/services/AuthService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
    final _formKey = GlobalKey<FormState>();
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  AuthenticationService authenticationService = AuthenticationService();
  TextEditingController _emailController = TextEditingController(text: "");
  TextEditingController _passwordController = TextEditingController(text: "");
  SharedPreferences prefs;

  bool isLoggedIn = false;
  bool isLoading = false;
  bool eye = true;

  void _toggle() {
    setState(() {
      eye = !eye;
    });
  }
  User currentUser;

  @override
  void initState() {
    super.initState();
    isSignedIn();
  }

  void isSignedIn() async {
    this.setState(() {
      isLoading = true;
    });

    prefs = await SharedPreferences.getInstance();

    isLoggedIn = await googleSignIn.isSignedIn();
    if (isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                Homepage(currentUserId: prefs.getString('id'))),
      );
    }

    this.setState(() {
      isLoading = false;
    });
  }


  handleEmailSignIn() async {
    // final User user = firebaseAuth.currentUser;
    if (_formKey.currentState.validate()) {
      var firebaseUser = await authenticationService.signInWithEmailAndPassword(
          _emailController.text, _passwordController.text);
      if (firebaseUser != null) {
        final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: firebaseUser.uid)
          .get();
          // currentUser = firebaseUser;
        // await prefs.setString('id', firebaseUser.uid);
        final List<DocumentSnapshot> documents = result.docs;
        await prefs.setString('id', documents[0].data()['id']);
        await prefs.setString('nickname', documents[0].data()['nickname']);
        await prefs.setString('photoUrl', documents[0].data()['photoUrl']);
        await prefs.setString('aboutMe', documents[0].data()['aboutMe']);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => Authentication(currentUserId: firebaseUser.uid)));
      }
    }
  }
  Future<Null> handleGoogleSignIn() async {
    prefs = await SharedPreferences.getInstance();

    this.setState(() {
      isLoading = true;
    });

    GoogleSignInAccount googleUser = await googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    User firebaseUser =
        (await firebaseAuth.signInWithCredential(credential)).user;

    if (firebaseUser != null) {
      // Check is already sign up
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: firebaseUser.uid)
          .get();
      final List<DocumentSnapshot> documents = result.docs;
      if (documents.length == 0) {
        // Update data to server if new user
        FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .set({
          'nickname': firebaseUser.displayName,
          'photoUrl': firebaseUser.photoURL,
          'id': firebaseUser.uid,
          'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
          'chattingWith': null,
          'role': 'user'
        });

        // Write data to local
        currentUser = firebaseUser;
        await prefs.setString('id', currentUser.uid);
        await prefs.setString('nickname', currentUser.displayName);
        await prefs.setString('photoUrl', currentUser.photoURL);
      } else {
        // Write data to local
        await prefs.setString('id', documents[0].data()['id']);
        await prefs.setString('nickname', documents[0].data()['nickname']);
        await prefs.setString('photoUrl', documents[0].data()['photoUrl']);
        await prefs.setString('aboutMe', documents[0].data()['aboutMe']);
      }
      Fluttertoast.showToast(msg: "Sign in success");
      this.setState(() {
        isLoading = false;
      });

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  Authentication(currentUserId: firebaseUser.uid)));
    } else {
      Fluttertoast.showToast(msg: "Sign in fail");
      this.setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomPadding: true,
      appBar: new AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        actions: <Widget>[
          new Padding(
            padding: const EdgeInsets.fromLTRB(0, 15, 20, 0),
            child: new FlatButton(
              child: new Text(
                "Sign up",
                style: new TextStyle(color: Colors.grey, fontSize: 17),
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()));
              },
              highlightColor: Colors.black,
              shape: StadiumBorder(),
            ),
          ),
        ],
      ),
      body: new SingleChildScrollView(
        child: new Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Form(
            key: _formKey,
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                new Text(
                  "Log in",
                  style:
                      new TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
                ),
                new SizedBox(
                  height: 70,
                ),
                new TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: new InputDecoration(
                    // hintText: "Email",
                    labelText: "Email",
                  ),
                ),
                new SizedBox(
                  height: 30,
                ),
                new TextFormField(
                  controller: _passwordController,
                  keyboardType: TextInputType.text,
                  autocorrect: false,
                  decoration: new InputDecoration(
                    labelText: "Password",
                    suffixIcon: new GestureDetector(
                      child: new Icon(
                        Icons.remove_red_eye,
                      ),
                      onTap: _toggle,
                    ),
                  ),
                  obscureText: eye,
                ),
                new SizedBox(
                  height: 30,
                ),
                new SizedBox(
                  height: 50,
                  child: new RaisedButton(
                    child: new Text("Log in",
                        style: new TextStyle(color: Colors.white)),
                    color: Colors.black,
                    elevation: 15.0,
                    shape: StadiumBorder(),
                    splashColor: Colors.white54,
                    onPressed: () {
                      handleEmailSignIn();
                    },
                  ),
                ),
                new Container(
                  padding: const EdgeInsets.fromLTRB(0, 30, 0, 30),
                  child: new Text(
                    "----- OR -----",
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                    height: 50,
                    child: RaisedButton(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              Text(
                                "Google Sign In",
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                          ],
                        ),
                        color: Colors.white,
                        elevation: 15,
                        shape: StadiumBorder(),
                        splashColor: Colors.white54,
                        onPressed: () {
                          handleGoogleSignIn();
                        })),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
