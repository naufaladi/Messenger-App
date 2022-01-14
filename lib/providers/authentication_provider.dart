import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

//Services
import '../services/database_service.dart';
import '../services/navigation_service.dart';

//Models
import '../models/chat_user.dart';

class AuthenticationProvider extends ChangeNotifier {
  late final FirebaseAuth _auth;
  late final NavigationService _navigationService;
  late final DatabaseService _databaseService;

  late ChatUser user;

  AuthenticationProvider() {
    _auth = FirebaseAuth.instance;
    _navigationService = GetIt.instance.get<NavigationService>();
    _databaseService = GetIt.instance.get<DatabaseService>();

    // TODOs: this is triggered whenever a user logs in
    _auth.authStateChanges().listen((_user) {
      if (_user != null) {
        print('Logged in as ${_user.email}');
        _databaseService.updateUserLastActive(_user.uid);

        /// gets the user as a document snapshot, and then convert that into a
        /// map of string keys and dynamic value, which then we pass onto the
        /// ChatUser class. Then finally navigate to Home Page.
        _databaseService.getUser(_user.uid).then(
          (_snapshot) {
            Map<String, dynamic> _userData =
                _snapshot.data()! as Map<String, dynamic>;
            user = ChatUser.fromJSON(
              {
                'uid': _user.uid,
                'name': _userData['name'],
                'email': _userData['email'],
                'image': _userData['image'],
                'last_active': _userData['last_active'],
              },
            );
            _navigationService.removeAndNavigateToRoute('/home');
          },
        );
      } else {
        print('Not authenticated');
        // _navigationService.removeAndNavigateToRoute('/login');
      }
    });
  }

  // custom function
  Future<void> loginUsingEmailAndPassword(String _email, String _password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: _email, password: _password);
      print(_auth.currentUser);
    } on FirebaseAuthException {
      print('Error logging user into Firebase');
    } catch (e) {
      print(e);
    }
  }

  //String is appended with ? becasue it is optional (in the case where we might fail registering a user)
  Future<String?> registerUsingNameAndEmailAndPassword(
      String _email, String _password) async {
    try {
      // createUserWithEmailAndPassword is provided by Flutter/ firebase_auth.dart
      UserCredential _credentials = await _auth.createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      return _credentials.user!.uid;
    } on FirebaseAuthException {
      print("error registering the user");
    } catch (error) {
      print(error);
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {}
    print(e);
  }
}
