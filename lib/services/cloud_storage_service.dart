import 'package:flutter/material.dart';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

const String USER_COLLECTION = 'Users';

class CloudStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CloudStorageService() {}

  // Function that picks profile picture/image and store it into the firebase storage
  Future<String?> saveUserImageToStorage(
      String _uid, PlatformFile _fileToBeUploaded) async {
    try {
      // Get reference to where we can store our uploaded user profile image in firebase "Storage"
      print('REEEEEE');
      Reference _ref = _storage
          .ref()
          .child('images/users/$_uid/profile.${_fileToBeUploaded.extension}');
      // create a task which uploads the image(path) to the specified path
      UploadTask _task = _ref.putFile(
        File(_fileToBeUploaded.path!),
      );
      // return a URL so we can download/ get acces to that image
      return await _task.then((_taskSnapshot) => _taskSnapshot.ref.getDownloadURL());
    } catch (e) {
      print(e);
    }
  }

  // Function to be used for later, it saves image attachments that are sent in chats to the Firebase storage
  Future<String?> saveChatImageToStorage(
      String _chatID, String _userID, PlatformFile _fileToBeUploaded) async {
    try {
      Reference _ref = _storage.ref().child(
          'images/chats/$_chatID/${_userID}_${Timestamp.now().millisecondsSinceEpoch}.${_fileToBeUploaded.extension}');
      UploadTask _task = _ref.putFile(
        File(_fileToBeUploaded.path!),
      );
      return await _task.then((_taskSnapshot) => _taskSnapshot.ref.getDownloadURL());
    } catch (e) {
      print(e);
    }
  }
}
