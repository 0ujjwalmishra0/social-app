import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';


class User with ChangeNotifier {
  final String id;
  final String username;
  final String email;
  final String photoUrl;
  final String displayName;
  final String bio;
  final String isVerified;


  User(
      {this.bio,
      this.displayName,
      this.email,
      this.id,
      this.photoUrl,
      this.username,
      this.isVerified});



  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc['id'],
      username: doc['username'],
      email: doc['email'],
      bio: doc['bio'],
      displayName: doc['displayName'],
      photoUrl: doc['photourl'],
      isVerified: doc['isVerified'],
    );
  }

  // createUserWithEmail(
  //     user,
  //     CollectionReference usersRef,
  //     TextEditingController _userNameController,
  //     TextEditingController _emailController,
  //     TextEditingController _fullNameController,
  //     User currentUser,
  //     ) async {
  //   // storing auto generated firestore id in map-id
  //   final id = usersRef.document().documentID;
  //   // final id2= Uuid().v4();

  //   // var doc= await usersRef.document(id);
  //   usersRef.document(user.uid).setData({
  //     'id': user.uid,
  //     'username': _userNameController.text,
  //     'photourl':
  //         'https://www.awesomegreece.com/wp-content/uploads/2018/10/default-user-image.png',
  //     'email': _emailController.text,
  //     'displayName': _fullNameController.text,
  //     'bio': '',
  //     'timestamp': DateTime.now(),
  //   });
  //   DocumentSnapshot doc2 = await usersRef.document(user.uid).get();
  //   currentUser = User.fromDocument(doc2);

   
    
  //    }
}
