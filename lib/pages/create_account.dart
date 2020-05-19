import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/constants.dart';
import '../models/user.dart';

import '../pages/login_screen.dart';
import '../pages/insta_screen.dart';

enum AuthMode { Signup, Login }
final usersRef = Firestore.instance.collection('users');

final commentsRef = Firestore.instance.collection('comments');

final activityFeedRef = Firestore.instance.collection('feed');

final followersRef = Firestore.instance.collection('followers');
final followingRef = Firestore.instance.collection('following');
final messageRef = Firestore.instance.collection('chats');

final conversationRef = Firestore.instance.collection('conversations');
User nowUser;

String firebaseId;

class CreateAccount extends StatefulWidget with ChangeNotifier {
  User currentUser;
  @override
  _CreateAccountState createState() => _CreateAccountState();
  static const routeName = '/signup-screen';
}

class _CreateAccountState extends State<CreateAccount> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _userNameController = TextEditingController();
  final _fullNameController = TextEditingController();
  var _isLoading = false;
  AuthMode _authMode = AuthMode.Signup;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
    'username': '',
    'displayName': '',
  };
  String emailValidator(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Email format is invalid';
    } else {
      return null;
    }
  }

  String hint;

  Widget _buildEmailTF() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Email address Form Field
              Text(
                'Username',
                style: kLabelStyle,
              ),
              SizedBox(height: 10.0),
              Container(
                alignment: Alignment.centerLeft,
                decoration: kBoxDecorationStyle,
                height: 60.0,
                child: TextFormField(
                  controller: _userNameController,
                  onSaved: (value) {
                    _authData['username'] = value;
                  },
                  
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'OpenSans',
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(top: 14.0),
                    prefixIcon: Icon(
                      Icons.account_circle,
                      color: Colors.white,
                    ),
                    hintText: 'Enter your username',
                    hintStyle: kHintTextStyle,
                  ),
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_)=> FocusScope.of(context).nextFocus(),
                ),
                
              ),
            ],
          ),
          SizedBox(
            height: 20.0,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Email address Form Field
              Text(
                'Full Name',
                style: kLabelStyle,
              ),
              SizedBox(height: 10.0),
              Container(
                alignment: Alignment.centerLeft,
                decoration: kBoxDecorationStyle,
                height: 60.0,
                child: TextFormField(
                  controller: _fullNameController,
                  onSaved: (value) {
                    _authData['displayName'] = value;
                  },
                  keyboardType: TextInputType.text,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'OpenSans',
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(top: 14.0),
                    prefixIcon: Icon(
                      Icons.account_circle,
                      color: Colors.white,
                    ),
                    hintText: 'Enter your Full Name',
                    hintStyle: kHintTextStyle,
                  ),
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_)=> FocusScope.of(context).nextFocus(),

                ),
              ),
            ],
          ),
          SizedBox(
            height: 20.0,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Email address Form Field
              Text(
                'Email',
                style: kLabelStyle,
              ),
              SizedBox(height: 10.0),
              Container(
                alignment: Alignment.centerLeft,
                decoration: kBoxDecorationStyle,
                height: 60.0,
                child: TextFormField(
                  onSaved: (value) {
                    _authData['email'] = value;
                  },
                  controller: _emailController,
                  validator: emailValidator,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'OpenSans',
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(top: 14.0),
                    prefixIcon: Icon(
                      Icons.email,
                      color: Colors.white,
                    ),
                    hintText: 'Enter your Email',
                    hintStyle: kHintTextStyle,
                  ),
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_)=> FocusScope.of(context).nextFocus(),

                ),
              ),
            ],
          ),
          SizedBox(
            height: 20.0,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Password Form Field
              Text(
                'Password',
                style: kLabelStyle,
              ),
              SizedBox(height: 10.0),
              Container(
                alignment: Alignment.centerLeft,
                decoration: kBoxDecorationStyle,
                height: 60.0,

                // key: _formKey,
                child: TextFormField(
                  onSaved: (value) {
                    _authData['password'] = value;
                  },
                  // autovalidate: true,

                  validator: (val) {
                    if (val.trim().length < 6 || val.isEmpty) {
                      return 'password must be 6 characters!';
                      // hint= 'username too short!';
                      
                    } 
                  },
                  controller: _passwordController,
                  obscureText: true,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'OpenSans',
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(top: 14.0),
                    prefixIcon: Icon(
                      Icons.lock,
                      color: Colors.white,
                    ),
                    hintText: 'Enter your Password',
                    hintStyle: kHintTextStyle,
                    errorStyle: TextStyle(height: 0.1),
                    
                  ),
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_){
                    FocusScope.of(context).nextFocus();
                    
                  } ,

                ),
              ),
            ],
          ),
          SizedBox(
            height: 20.0,
          ),

          //Confirm Password

          //Actual Confirm Password Field

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Password Form Field
              Text(
                'Confirm Password',
                style: kLabelStyle,
              ),
              SizedBox(height: 10.0),
              Container(
                alignment: Alignment.centerLeft,
                decoration: kBoxDecorationStyle,
                height: 60.0,

                // key: _formKey,
                child: TextFormField(
                  obscureText: true,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'OpenSans',
                  ),
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match!';
                    }
                  },
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(top: 14.0),
                    prefixIcon: Icon(
                      Icons.lock,
                      color: Colors.white,
                    ),
                    hintText: 'Confirm Password',
                    hintStyle: kHintTextStyle,
                  ),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_)=> FocusScope.of(context).unfocus(),

                ),
              ),
            ],
          ),

          
        ],
      ),
    );
  }

  //   _submit(){
  //   _formKey.currentState.save();
  //   Navigator.pop(context);
  // }

  // Future<void> _submit() async {
  //   if (!_formKey.currentState.validate()) {
  //     // Invalid!
  //     return;
  //   }
  //   if (_formKey.currentState.validate()) {
  //     _formKey.currentState.save();
  //   }

  //   setState(() {
  //     _isLoading = true;
  //   });
  //   try {
  //     if (_authMode == AuthMode.Login) {
  //       // Log user in
  //       await Provider.of<Auth>(context, listen: false).signin(
  //         _authData['email'],
  //         _authData['password'],
  //       );
  //       SnackBar(
  //         content: Text('Sign In success!'),
  //       );
  //     } else {
  //       // Sign user up
  //       await Provider.of<Auth>(context, listen: false).signup(
  //         _authData['email'],
  //         _authData['password'],
  //       );
  //       SnackBar(
  //         duration: Duration(seconds: 1),
  //         content: Text('Sign Up success!'),
  //       );
  //       Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
  //     }
  //   } on HttpException catch (error) {
  //     var errorMsg = 'Authentication failed';
  //     if (errorMsg.toString().contains('EMAIL_EXISTS')) {
  //       errorMsg = 'This email address is already registered';
  //     } else if (errorMsg.toString().contains('INVALID_EMAIL')) {
  //       errorMsg = 'This is not a valid email address';
  //     } else if (error.toString().contains('WEAK_PASSWORD')) {
  //       errorMsg = 'This password is too weak';
  //     } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
  //       errorMsg = 'Could not find a user with that email';
  //     } else if (error.toString().contains('INVALID_PASSWORD')) {
  //       errorMsg = 'Invalid Password';
  //     }
  //     _showErrorDialog(errorMsg);
  //   } catch (error) {
  //     const errorMsg = 'Could not authenticate you. Please try again later.';

  //     _showErrorDialog(errorMsg);
  //   }

  //   setState(() {
  //     _isLoading = false;
  //   });
  // }
  signUpUsingEmail(String email,String password,BuildContext context) {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
    }
    FirebaseAuth.instance
              .createUserWithEmailAndPassword(
                  email: email,password: password)
              .then((signedInUser) async {
            createUserWithEmail(signedInUser.user);
            
            
            //saving auto login

            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('email', email);
            
      Navigator.of(context).pushReplacementNamed(InstaScreen.routeName);
            print('create user inside then block');
          }).catchError((e) {
            print(e);
          });

}
  void _showErrorDialog(String message) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text('An error Ocurred'),
              content: Text(message),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: Text('OK'))
              ],
            ));
  }




  Widget _buildSignUpBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: ()=> signUpUsingEmail(_emailController.text,_passwordController.text,context),
        // googleSign.signIn();

        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.white,
        child: Text(
          'Sign Up',
          style: TextStyle(
            color: Color(0xFF527DAA),
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }

  Widget _buildSignupOrLoginBtn() {
    return GestureDetector(
      onTap: () {
        print('Sign Up Button Pressed');
        // switches auth mode
        // _switchAuthMode();

        Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
      },
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Already have an Account? ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: 'LOGIN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // createUserWithEmail() async {
  //   // storing auto generated firestore id in map-id
  //   String id = await usersRef.document().documentID.toString();
  //   DocumentSnapshot doc2 = await usersRef.document(id).get();
  //     final doc = await usersRef.document(id).setData({
  //       'id': id,
  //       'username': _authData['username'],
  //       'photourl':
  //           'https://www.awesomegreece.com/wp-content/uploads/2018/10/default-user-image.png',
  //       'email': _authData['email'],
  //       'displayName': _authData['displayName'],
  //       'bio': '',
  //       'timestamp': DateTime.now(),
  //     });
  //     print('id is ${id}');
  //     print('doc2 is ${doc2.data}');
  // }

  // createUserWithEmail() async {
  //   // storing auto generated firestore id in map-id
  //   final id = usersRef.document().documentID;
  //   // final id2= Uuid().v4();

  //   // var doc= await usersRef.document(id);
  //   usersRef.document(id).setData({
  //     'id': id,
  //     'username': _userNameController.text,
  //     'photourl':
  //         'https://www.awesomegreece.com/wp-content/uploads/2018/10/default-user-image.png',
  //     'email': _emailController.text,
  //     'displayName': _fullNameController.text,
  //     'bio': '',
  //     'timestamp': DateTime.now(),
  //   });
  //     print('id is ${id}');
  //     print('firebase id is ${firebaseId}');
  //   DocumentSnapshot doc2 = await usersRef.document(id).get();
  //   currentUser = User.fromDocument(doc2);
  // }

  createUserWithEmail(user) async {
    // storing auto generated firestore id in map-id
    final id = usersRef.document().documentID;
    // final id2= Uuid().v4();

    // var doc= await usersRef.document(id);
    usersRef.document(user.uid).setData({
      'id': user.uid,
      'username': _userNameController.text,
      'photourl':
          'https://www.awesomegreece.com/wp-content/uploads/2018/10/default-user-image.png',
      'email': _emailController.text,
      'displayName': _fullNameController.text,
      'bio': '',
      'timestamp': DateTime.now(),
      'isVerified': '0',
    });

    handleFollowUjjwal(user.uid);

    DocumentSnapshot doc2 = await usersRef.document(user.uid).get();
    // widget.currentUser = User.fromDocument(doc2);
    nowUser = User.fromDocument(doc2);
  }

  handleFollowUjjwal(userIdd) {
    // setState(() {
    //   isFollowing = true;
    // });
    followersRef
        .document('yxifLezAKXXjhfIDTjNEYBOu7EI3')
        .collection('userFollowers')
        .document(userIdd)
        .setData({});
    //Put that user on your following collection (update your following collection)

    followingRef
        .document(userIdd)
        .collection('userFollowing')
        .document('yxifLezAKXXjhfIDTjNEYBOu7EI3')
        .setData({});

    //add activity feed item for that user to notify about new follower(us)
    activityFeedRef
        .document('yxifLezAKXXjhfIDTjNEYBOu7EI3')
        .collection('feedItems')
        .document(userIdd)
        .setData({
      'type': 'follow',
      'ownerId': 'yxifLezAKXXjhfIDTjNEYBOu7EI3',
      'username':
          // users.data['username'],
          nowUser.username,
      'userId': userIdd,
      'userProfileImg':
          // users.data['photourl'],
          // currentUserData['photourl'],
          nowUser.photoUrl,
      'timestamp': DateTime.now(),
    });
    print('nowUser.username is ${nowUser.username}');
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: <Widget>[
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF73AEF5),
                      Color(0xFF61A4F1),
                      Color(0xFF478DE0),
                      Color(0xFF398AE5),
                    ],
                    stops: [0.1, 0.4, 0.7, 0.9],
                  ),
                ),
              ),
              Container(
                height: double.infinity,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 120.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'OpenSans',
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 40.0),
                      _buildEmailTF(),
                      SizedBox(
                        height: 30.0,
                      ),
                      _buildSignUpBtn(),
                      _buildSignupOrLoginBtn(),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
