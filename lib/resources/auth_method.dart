// import 'dart:html';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagramclone/models/user.dart' as model;
// import 'package:flutter/material.dart';
import 'package:instagramclone/resources/storage_methods.dart';

class AuthMethod {
  // we have to get instance of firebase auth class
  // so that we can call multiple functions on it
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot snap =
        await _firestore.collection('user').doc(currentUser.uid).get();
    return model.User.fromSnap(snap);
  }

  Future<String> signUpUser({
    // as it is async the signup user will return a string
    required String email,
    required String password,
    required String username,
    required String bio,
    required Uint8List file, // this is the file type
  }) async {
    // it will be type string weather it is successful or not
    // print("here");
    String res = "Some error occured";

    try {
      // we have to setup that if all the above things are filled correctly or not
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          username.isNotEmpty ||
          bio.isNotEmpty) {
        // registering the user - to do so we use _auth instance
        print("creating user");
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        // print(cred.user!.uid);
        print("userid: ${cred.user!.uid}");

        // String photoUrl = await StorageMethod()
        //     .uploadImageToStorage("profilePics", file, false);
        String photoUrl =
            'https://a.storyblok.com/f/191576/1200x800/215e59568f/round_profil_picture_after_.webp';
        // add user to our data base
        // we are telling firebase firestore to add a new document to the collection name called users
        model.User user = model.User(
          username: username,
          uid: cred.user!.uid,
          email: email,
          bio: bio,
          photoUrl: photoUrl,
          followers: [],
          following: [],
        );

        await _firestore
            .collection('users')
            .doc(cred.user!.uid)
            .set(user.toJson());
        // returns a map for us

        // suppose we dont want the uid accessed anywhere in the app
        // await _firestore.collection('users').add({
        //   'username': username,
        //   'uid': cred.user!.uid, // this is the uid of the user
        //   'email': email,
        //   'bio': bio,
        //   'followers': [],
        //   'following': [],
        // });

        res = "Success";
      }
    } catch (err) {
      res = err.toString();
    }

    return res;
  }

  // logging in user
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error occured";

    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = "Success";
      } else {
        res = "Please fill all the fields";
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        res = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        res = 'Wrong password provided for that user.';
      }
    } catch (err) {
      res = err.toString();
    }

    return res;
  }
}
