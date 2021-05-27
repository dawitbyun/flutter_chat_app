import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/components/rounded_button.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'chat_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = 'registration_screen';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  //We create a new authentication instance

  final _auth = FirebaseAuth.instance;
  // final because I will never change it once I created it. And make it a private so other classes can't accidently mess with my variable
  // and use this _auth  object to authenticate user's email and password.
  String email;
  String password;
  bool showSpinner =
      false; // start value is false because it shouldn't be spinning right in the beginning.
  // when its false, it isn't spinning. it is not final because we are going to redefine it later
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
                SizedBox(
                  height: 48.0,
                ),
                TextField(
                  keyboardType: TextInputType
                      .emailAddress, //keyboardtype을 이메일 넣기 쉬운 이메일 형식으로 바꾸어줌
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    email = value;
                  },
                  decoration: kTextFieldDecoration.copyWith(
                      hintText: 'Enter your email'),
                ),
                SizedBox(
                  height: 8.0,
                ),
                TextField(
                  obscureText: true, //password를 문자에서 점으로 바꿔준다.
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    //firebase password는 최소 6자리 이상 되어야 한다.아니면 fail
                    password = value;
                  },
                  decoration: kTextFieldDecoration.copyWith(
                      hintText: 'enter your password'),
                ),
                SizedBox(
                  height: 24.0,
                ),
                RoundedButton(
                  title: 'Register',
                  colour: Colors.blueAccent,
                  onPressed: () async {
                    setState(() {
                      showSpinner = true; //누르면 spinner가 돌고, 정보를 가져오면 멈춘다.
                    });
                    try {
                      // try and catch because there could be errors
                      final newUser =
                          await _auth.createUserWithEmailAndPassword(
                              //tap into _auth object
                              email: email,
                              password: password);
                      if (newUser != null) {
                        Navigator.pushNamed(context,
                            ChatScreen.id); // 여기서 chat_screen.dart를 import 해준다.
                      }

                      setState(() {
                        showSpinner = false; // 정보를 가져오면 멈춘다.
                      });
                    } catch (e) {
                      print(e);
                    }
                  },
                ),
              ],
            )),
      ),
    );
  }
}
