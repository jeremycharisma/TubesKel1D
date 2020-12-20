import 'package:ConsultDoc/screens/auth/loginscreen.dart';
import 'package:ConsultDoc/screens/doctor/doctorpage.dart';
import 'package:ConsultDoc/screens/user/Homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Authentication extends StatefulWidget {
  final String currentUserId;

  const Authentication({Key key, this.currentUserId}) : super(key: key);

  @override
  _AuthenticationState createState() =>
      _AuthenticationState(currentUserId: currentUserId);
}

class _AuthenticationState extends State<Authentication> {
  _AuthenticationState({Key key, @required this.currentUserId});

  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection("users").doc(currentUserId).snapshots() ,
            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot){
              if(snapshot.hasData && snapshot.data != null) {
                final userDoc = snapshot.data;
                final user = userDoc.data();
                if(user['role'] == "doctor") {
                  return DoctorPage(currentUserId: currentUserId);
                }else if(user['role'] == 'user'){
                  return Homepage(currentUserId: currentUserId);
                }
              }else{
                return LoginScreen();
              }
            },
          );
  }
}