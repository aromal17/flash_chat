import 'package:flutter/material.dart';
import 'package:flutter_flash_chat/screens/registration_screen.dart';
import 'login_screen.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_flash_chat/components/rounded_button.dart';

class WelcomeScreen extends StatefulWidget {
  static String id = "welcome_screen";
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin{
  AnimationController controller;
  AnimationController controllerTween;
  Animation animation;
  Animation animationTween;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: Duration(seconds: 3),
        vsync:this,
    );
    controllerTween = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    animation = CurvedAnimation(parent: controller,curve: Curves.elasticOut);
    animationTween = ColorTween(begin: Colors.blueGrey,end: Colors.white).animate(controllerTween);
    controller.forward();
    controllerTween.forward();

    animation.addStatusListener((status) {
       if(status == AnimationStatus.completed)
         controller.reverse(from: 1.0);
       else if(status == AnimationStatus.dismissed)
         controller.forward();
    });

    controller.addListener(() {
      setState(() {});
    });

  }

  @override
  void dispose() {
    controller.dispose();
    controllerTween.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animationTween.value,
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
                    height: animation.value*60,
                  ),
                ),
                TypewriterAnimatedTextKit(
                  speed: Duration(milliseconds: 500),
                  totalRepeatCount: 4,
                  text:['Flash Chat'],
                  textStyle: TextStyle(
                    fontSize: 45.0,
                    fontWeight: FontWeight.w900,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            RoundedButton(buttonColor: Colors.lightBlueAccent,buttonTitle: 'Log In',buttonOnPressed:() {
              Navigator.pushNamed(context, LoginScreen.id);
            }),
            RoundedButton(buttonColor: Colors.blueAccent,buttonTitle:'Register',buttonOnPressed: () {
              Navigator.pushNamed(context, RegistrationScreen.id);
            }),
          ],
        ),
      ),
    );
  }
}

