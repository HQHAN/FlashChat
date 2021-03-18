import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'login_screen.dart';
import 'registration_screen.dart';

class WelcomeScreen extends StatefulWidget {
  static const id = "WelcomeScreen";
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation animation;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.dispose();
  }

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    animation = ColorTween(
      begin: Colors.blueAccent,
      end: Colors.white,
    ).animate(controller);
    controller.forward();
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
      } else if (status == AnimationStatus.dismissed) {}
      print(status);
    });
    controller.addListener(() {
      setState(() {});
      print(animation.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animation.value,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Container(
                    child: Image.asset('images/logo.png'),
                    height: 60,
                  ),
                ),
                TypewriterAnimatedTextKit(
                  text: ['Hans&Tory Chat'],
                  textStyle: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            ChatButton(
              text: 'Login',
              backgroundColor: Colors.blueAccent,
              onPressed: () => Navigator.pushNamed(
                context,
                LoginScreen.id,
              ),
            ),
            ChatButton(
              text: 'Register',
              backgroundColor: Colors.yellow,
              onPressed: () => Navigator.pushNamed(
                context,
                RegistrationScreen.id,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatButton extends StatelessWidget {
  const ChatButton({
    this.text,
    this.backgroundColor,
    this.onPressed,
  });

  final String text;
  final Color backgroundColor;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: onPressed,
          minWidth: 200.0,
          height: 42.0,
          child: Text(
            text,
          ),
        ),
      ),
    );
  }
}
