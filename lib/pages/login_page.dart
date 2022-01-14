//Packages
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:messenger_app/pages/registration_page.dart';
import 'package:provider/provider.dart';
//Widgets
import '../widgets/custom_input_fields.dart';
import '../widgets/rounded_button.dart';
//Providers
import '../providers/authentication_provider.dart';
//Services
import '../services/navigation_service.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late double _deviceHeight;
  late double _deviceWidth;
  late AuthenticationProvider _auth;
  late NavigationService _navigation;

  // a unique key (for each state) for login text forms
  final _loginFormKey = GlobalKey<FormState>();

  String? _email;
  String? _password;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _auth = Provider.of<AuthenticationProvider>(context);
    _navigation = GetIt.instance.get<NavigationService>();

    return _buildUI();
  }

  // Builders

  Widget _buildUI() {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        margin: EdgeInsets.only(bottom: 0),
        padding: EdgeInsets.only(
          top: _deviceHeight * 0.1,
          bottom: _deviceHeight * 0.0,
          right: _deviceWidth * 0.1,
          left: _deviceWidth * 0.1,
        ),
        width: _deviceWidth * 1,
        height: _deviceHeight * 1,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // TODOs: change builder name and with "build..."
            _pageTitle(),
            SizedBox(height: 10),
            _loginForm(),
            SizedBox(height: 25),
            _loginButton(),
            SizedBox(height: 25),
            _registrationLink(),
          ],
        ),
      ),
    );
  }

  Widget _pageTitle() {
    return Container(
      height: _deviceHeight * 0.1,
      child: Text(
        'Messenger',
        style: TextStyle(
          color: Colors.blueGrey[800],
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _loginForm() {
    return Container(
      child: Form(
        key: _loginFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomTextFormField(
              onSaved: (value) {
                setState(() {
                  _email = value;
                });
              },
              placeholder: 'E-mail',
              regEx:
                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
              obscureText: false,
            ),
            SizedBox(height: 13),
            CustomTextFormField(
              onSaved: (value) {
                setState(() {
                  _password = value;
                });
              },
              placeholder: 'Password',
              regEx: r".{6,}",
              obscureText: true,
            )
          ],
        ),
      ),
    );
  }

  Widget _loginButton() {
    return RoundedButton(
      title: 'Login',
      height: _deviceHeight * 0.07,
      width: _deviceHeight * 0.3,
      onPressed: () {
        // checks whether the user input is valid (according to the rules we defined in "validator:" inside custom_input_fields.dart)
        if (_loginFormKey.currentState!.validate()) {
          // calls the onSaved function defined in Widget _loginForm
          _loginFormKey.currentState!.save();
          _auth.loginUsingEmailAndPassword(_email!, _password!);
        }
      },
    );
  }

  Widget _registrationLink() {
    return GestureDetector(
      onTap: () => _navigation.navigateToRoute('/registration'),
      child: Container(
        child: Text(
          'Or register an account here',
          style: TextStyle(
            color: Colors.blue[400],
          ),
        ),
      ),
    );
  }
}
