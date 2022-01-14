import 'package:flutter/material.dart';
import 'package:messenger_app/providers/authentication_provider.dart';
import 'package:messenger_app/services/navigation_service.dart';
import 'package:messenger_app/widgets/rounded_image.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get_it/get_it.dart';

//Services
import '../services/media_service.dart';
import '../services/database_service.dart';
import '../services/cloud_storage_service.dart';

//Widgets
import '../widgets/custom_input_fields.dart';
import '../widgets/rounded_button.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  String? _name;
  String? _email;
  String? _password;

  late AuthenticationProvider _auth;
  late DatabaseService _databaseService;
  late CloudStorageService _cloudStorageService;
  late NavigationService _navigationService;

  final _registrationFormKey = GlobalKey<FormState>();

  // Class provided by FilePicker
  PlatformFile? _profileImage;

  @override
  Widget build(BuildContext context) {
    // this lets us "grab" the type AuthenticationProvider provider from the widgetTree which is located in main.dart (one of the multiProvider)
    _auth = Provider.of<AuthenticationProvider>(context);
    _databaseService = GetIt.instance.get<DatabaseService>();
    _cloudStorageService = GetIt.instance.get<CloudStorageService>();
    _navigationService = GetIt.instance.get<NavigationService>();

    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return _buildUI();
  }

  // Builders

  Widget _buildUI() {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: _deviceWidth * 0.97,
        height: _deviceHeight * 0.98,
        padding: EdgeInsets.symmetric(
          horizontal: _deviceWidth * 0.03,
          vertical: _deviceHeight * 0.02,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _profileImageField(),
            SizedBox(height: _deviceHeight * 0.1),
            _registrationForm(),
            SizedBox(height: _deviceHeight * 0.1),
            _registrationButton(),
          ],
        ),
      ),
    );
  }

  Widget _profileImageField() {
    return GestureDetector(
      onTap: () {
        GetIt.instance.get<MediaService>().pickImageFromLibrary().then((_image) {
          setState(() {
            _profileImage = _image;
          });
        });
      },
      child: () {
        if (_profileImage != null) {
          return RoundedImageFile(
            key: UniqueKey(),
            size: _deviceHeight * 0.2,
            image: _profileImage!,
          );
        } else {
          return RoundedImageNetwork(
            key: UniqueKey(),
            size: _deviceHeight * 0.2,
            imagePath: "https://i.ibb.co/mTP478B/default-profile-picture.jpg",
          );
        }
      }(),
    );
  }

  Widget _registrationForm() {
    return Container(
      height: _deviceHeight * 0.35,
      child: Form(
          key: _registrationFormKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomTextFormField(
                placeholder: 'Name',
                onSaved: (val) {
                  setState(() {
                    _name = val;
                  });
                },
                regEx: r".{5,}",
                obscureText: false,
              ),
              CustomTextFormField(
                placeholder: 'E-mail',
                onSaved: (val) {
                  setState(() {
                    _email = val;
                  });
                },
                regEx:
                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                obscureText: false,
              ),
              CustomTextFormField(
                placeholder: 'Password',
                onSaved: (val) {
                  setState(() {
                    _password = val;
                  });
                },
                regEx: r".{6,}",
                obscureText: true,
              ),
            ],
          )),
    );
  }

  Widget _registrationButton() {
    return RoundedButton(
      title: "Register",
      height: _deviceHeight * 0.07,
      width: _deviceWidth * 0.65,
      onPressed: () async {
        /// Steps to implement:
        /// 1. Validate the user input (just like in login page)
        if (_registrationFormKey.currentState!.validate() && _profileImage != null) {
          //Proceed, and save the input
          _registrationFormKey.currentState!.save();
          //Register the user with Firebase Authentication module
          String? _uid =
              await _auth.registerUsingNameAndEmailAndPassword(_email!, _password!);
          //upload profile image to firebase storage cloud and then retrieve the URL afterward
          String? _imageURL = await _cloudStorageService.saveUserImageToStorage(
              _uid!, _profileImage!);
          //create User and save
          await _databaseService.createUser(_uid, _email!, _name!, _imageURL!);
          await _auth.logout();
          await _auth.loginUsingEmailAndPassword(_email!, _password!);
        }

        ///
        /// 2. Register the user (upload their name email password and local image to database)
        /// 3. Copy over the information to an instance of Firestore Database so we have a representation of the user inside the Users collection in Firebase
        ///
      },
    );
  }
}
