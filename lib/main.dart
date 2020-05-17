import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:insta_clone/models/current_user.dart';
import 'package:insta_clone/pages/create_account.dart';
import 'package:insta_clone/pages/insta_screen.dart';
import 'package:insta_clone/pages/login_screen.dart';

import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './models/auth.dart';
import './models/custom_route.dart';
var email;
Future<void> main() async{ 
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  email = prefs.getString('email');
  print("login:" + email.toString());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp();
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.blue, // navigation bar color
    statusBarColor: Colors.white,
    statusBarBrightness: Brightness.light,

    // Color(0xfff8faf8), // status bar color
  ));
    getCurrentUser() async {
      final user = FirebaseAuth.instance.currentUser();
      return user;
    }
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Auth()),
        ChangeNotifierProvider.value(value: CurrentUser()),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Instagram Clone',
          theme: ThemeData(
            primaryColor: Color(0xffE25E60),
            primaryIconTheme: IconThemeData(color: Colors.black),
            primaryTextTheme: TextTheme(
              title: TextStyle(color: Colors.black, fontFamily: 'Aveny'),
            ),
            textTheme: TextTheme(
              title: TextStyle(color: Colors.black),
            ),
            pageTransitionsTheme: PageTransitionsTheme(
              builders: {
                TargetPlatform.android : CustomPageTransitionBuilder(),
                TargetPlatform.iOS : CustomPageTransitionBuilder(),

              }
            )
          ),
          home: email == null ? LoginScreen() : InstaScreen(), 
          
              
              // getCurrentUser() != null
              //     ? InstaScreen()
              //     : FutureBuilder(
              //         future: auth.tryAutoLogin(),
              //         builder: (ctx, authResultSnapshot) =>
              //             authResultSnapshot.connectionState ==
              //                     ConnectionState.waiting
              //                 ? SplashScreen()
              //                 : LoginScreen(),
              //       ),
              
          routes: {
            LoginScreen.routeName: (ctx) => LoginScreen(),
            CreateAccount.routeName: (ctx) => CreateAccount(),
            InstaScreen.routeName: (ctx) => InstaScreen(),
          },
        ),
      ),
    );
  }
}



