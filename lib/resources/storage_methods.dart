import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';

class StorageMethod {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // adding image to firebase storage
  Future<String> uploadImageToStorage(
      String childName, Uint8List file, bool isPost) async {
    // ref method is pointer to the file in the storage
    Reference ref =
        _storage.ref().child(childName).child(_auth.currentUser!.uid);

    // upload task gives us ability to track the upload
    UploadTask uploadTask = ref.putData(file);

    TaskSnapshot snap = await uploadTask;
    String downlaoadUrl = await snap.ref.getDownloadURL();

    return downlaoadUrl;
  }
}
