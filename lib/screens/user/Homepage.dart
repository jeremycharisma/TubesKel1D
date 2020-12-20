import 'dart:io';
import 'package:ConsultDoc/components/loading.dart';
import 'package:ConsultDoc/components/style.dart';
import 'package:ConsultDoc/model/choice.dart';
import 'package:ConsultDoc/screens/auth/loginscreen.dart';
import 'package:ConsultDoc/screens/settings.dart';
import 'package:ConsultDoc/screens/user/chat.dart';
import 'package:ConsultDoc/services/AuthService.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Homepage extends StatefulWidget {
  final String currentUserId;

  Homepage({Key key, @required this.currentUserId}) : super(key: key);

  @override
  State createState() => _HomepageState(currentUserId: currentUserId);
}

class _HomepageState extends State<Homepage> {
  _HomepageState({Key key, @required this.currentUserId});

  final String currentUserId;
  final AuthenticationService authenticationService = AuthenticationService();
  final GoogleSignIn googleSignIn = GoogleSignIn();
  List<Choice> choices = const <Choice>[
    const Choice(title: 'Settings', icon: Icons.settings),
    const Choice(title: 'Log out', icon: Icons.exit_to_app),
  ];
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
  }

  void onItemMenuPress(Choice choice) {
    if (choice.title == 'Log out') {
      handleSignOut();
    } else {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ChatSettings()));
    }
  }

  Future<bool> onBackPress() {
    openDialog();
    return Future.value(false);
  }

  Future<Null> openDialog() async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding:
                EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
            children: <Widget>[
              Container(
                color: orange,
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
                height: 100.0,
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.exit_to_app,
                        size: 30.0,
                        color: Colors.white,
                      ),
                      margin: EdgeInsets.only(bottom: 10.0),
                    ),
                    Text(
                      'Exit app',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Are you sure to exit app?',
                      style: TextStyle(color: Colors.white70, fontSize: 14.0),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 0);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.cancel,
                        color: orange,
                      ),
                      margin: EdgeInsets.only(right: 10.0),
                    ),
                    Text(
                      'CANCEL',
                      style:
                          TextStyle(color: orange, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 1);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.check_circle,
                        color: orange,
                      ),
                      margin: EdgeInsets.only(right: 10.0),
                    ),
                    Text(
                      'YES',
                      style:
                          TextStyle(color: orange, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ],
          );
        })) {
      case 0:
        break;
      case 1:
        exit(0);
        break;
    }
  }

  Future<Null> handleSignOut() async {
    this.setState(() {
      isLoading = true;
    });

    await FirebaseAuth.instance.signOut();
    await googleSignIn.signOut();

    this.setState(() {
      isLoading = false;
    });

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => LoginScreen(
                  title: 'Login',
                )),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Homepage',
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        actions: <Widget>[
          PopupMenuButton<Choice>(
            onSelected: onItemMenuPress,
            itemBuilder: (BuildContext context) {
              return choices.map((Choice choice) {
                return PopupMenuItem<Choice>(
                    value: choice,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          choice.icon,
                          color: Colors.black,
                        ),
                        Container(
                          width: 10.0,
                        ),
                        Text(
                          choice.title,
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ));
              }).toList();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Stack(children: [
          Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 21,
                ),
                Container(
                  child: Text('Pilih Dokter Pilihan \nAnda', style: maintext),
                ),
                SizedBox(
                  height: 30,
                ),
                SizedBox(
                  height: 22,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Kategori',
                      style: maintext,
                    ),
                    Text(
                      'see All..',
                      style: TextStyle(
                          fontSize: 14,
                          color: orange,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                        child: Card(
                      elevation: 5,
                      shadowColor: bcndclr2,
                      child: Column(
                        children: [
                          Container(
                              height: 60,
                              child: Image(
                                  image:
                                      AssetImage('assets/images/kucing.png'))),
                          Container(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Kucing',
                                style: cardtext,
                              ),
                            ),
                          )
                        ],
                      ),
                    )),
                    Expanded(
                        child: Card(
                      elevation: 5,
                      shadowColor: bcndclr2,
                      child: Column(
                        children: [
                          Container(
                              height: 60,
                              child: Image(
                                  image:
                                      AssetImage('assets/images/puppy.png'))),
                          Container(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Anjing',
                                style: cardtext,
                              ),
                            ),
                          )
                        ],
                      ),
                    )),
                    Expanded(
                        child: Card(
                      elevation: 5,
                      shadowColor: bcndclr2,
                      child: Column(
                        children: [
                          Container(
                              height: 60,
                              child: Image(
                                  image: AssetImage('assets/images/bird.jpg'))),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              child: Text(
                                'Burung',
                                style: cardtext,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Dokter Terbaik',
                        style: maintext,
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          'See All..',
                          style: TextStyle(
                              color: orange,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('role', isEqualTo: 'doctor')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(orange),
                        ),
                      );
                    } else {
                      return Expanded(
                        child: ListView.builder(
                          itemBuilder: (context, index) => buildItem(
                              context, snapshot.data.documents[index]),
                          itemCount: snapshot.data.documents.length,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget buildItem(BuildContext context, DocumentSnapshot document) {
    if (document.data()['id'] == currentUserId) {
      return Container();
    } else {
      return Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: bcndclr2)],
        ),
        child: GestureDetector(
          child: ListTile(
            hoverColor: backgroundclr,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            leading: Container(
              decoration: BoxDecoration(shape: BoxShape.circle),
              child: document.data()['photoUrl'] != null
                  ? CachedNetworkImage(
                      placeholder: (context, url) => Container(
                            child: CircularProgressIndicator(
                              strokeWidth: 1.0,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                            width: 50.0,
                            height: 50.0,
                            padding: EdgeInsets.all(15.0),
                          ),
                      errorWidget: (context, url, error) => Material(
                            child: Image.asset(
                              'assets/images/patient.png',
                              width: 200.0,
                              height: 200.0,
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                            clipBehavior: Clip.hardEdge,
                          ),
                      width: 50.0,
                      height: 50.0,
                      fit: BoxFit.cover,
                      imageUrl: document.data()['photoUrl'])
                  : Icon(Icons.account_circle, size: 50.0, color: grey),
            ),
            title: Text(
              '${document.data()['nickname']}',
              style: TextStyle(fontFamily: 'Mulish', fontSize: 17),
            ),
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Chat(
                          peerId: document.id,
                          peerAvatar: document.data()['photoUrl'],
                        )));
          },
        ),
        margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
      );
    }
  }
}
