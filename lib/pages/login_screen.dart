import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:insta_clone/models/Exception.dart';
import 'package:insta_clone/models/current_user.dart';
import 'package:insta_clone/pages/create_account.dart';
import 'package:insta_clone/pages/create_account_google.dart';
import 'package:insta_clone/pages/insta_screen.dart';
import 'package:provider/provider.dart';
import '../models/constants.dart';
import '../models/auth.dart';
import 'package:flutter/foundation.dart';

enum AuthMode { Signup, Login }
// final usersRef = Firestore.instance.collection('users');

class LoginScreen extends StatefulWidget with ChangeNotifier {
  static const routeName = '/login-screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin, ChangeNotifier {
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool _rememberMe = false;
  bool isAuth = false;
  var _isLoading = false;
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();

  bool get isAuthGoogle {
    // if token is not null we are authenticated
    return isAuth;
  }

  final GoogleSignIn googleSign = GoogleSignIn();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  AnimationController _controller;
  // Animation<Offset> _slideAnimation;
  // Animation<double> _opacityAnimation;

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        // Log user in
        await Provider.of<Auth>(context, listen: false).signin(
          _authData['email'],
          _authData['password'],
        );
        SnackBar(
          content: Text('Sign In success!'),
        );
      } else {
        // Sign user up
        await Provider.of<Auth>(context, listen: false).signup(
          _authData['email'],
          _authData['password'],
        );
        SnackBar(
          content: Text('Sign Up success!'),
        );
      }
    } on HttpException catch (error) {
      var errorMsg = 'Authentication failed';
      if (errorMsg.toString().contains('EMAIL_EXISTS')) {
        errorMsg = 'This email address is already registered';
      } else if (errorMsg.toString().contains('INVALID_EMAIL')) {
        errorMsg = 'This is not a valid email address';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMsg = 'This password is too weak';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMsg = 'Could not find a user with that email';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMsg = 'Invalid Password';
      }
      _showErrorDialog(errorMsg);
    } catch (error) {
      const errorMsg = 'Could not authenticate you. Please try again later.';

      _showErrorDialog(errorMsg);
    }

    setState(() {
      _isLoading = false;
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

  // void _switchAuthMode() {
  //   if (_authMode == AuthMode.Login) {
  //     setState(() {
  //       _authMode = AuthMode.Signup;
  //     });
  //     //animation controller start

  //   } else {
  //     setState(() {
  //       _authMode = AuthMode.Login;
  //     });
  //   }
  // }

  @override
  void initState() {
    super.initState();
    googleSign.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (error) {
      print("error signig in $error");
    });
  }

  // method for handling account Sign in
  handleSignIn(GoogleSignInAccount account) {
    if (account != null) {
      print(account);
      setState(() {
        isAuth = true;
        print(isAuth);
        notifyListeners();
      });
      // Navigator.of(context).push(CustomRouteRoute(builder: (ctx)=> MyApp(isAuth)));
    } else {
      setState(() {
        isAuth = false;
        notifyListeners();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  getCurrentUser() async {
    FirebaseUser _user = await FirebaseAuth.instance.currentUser();
    return _user;
  }

  createUserInFirestore() async {
    final user = googleSign.currentUser;
    final doc = await usersRef.document(user.id).get();

    //take them to SignUp page
    final username =
        await Navigator.push(context, MaterialPageRoute(builder: (ctx) {
      CreateAccountGoogle();
    }));

    usersRef.document(user.id).setData({
      'id': user.id,
      'username': username,
      'photoaUrl': user.photoUrl,
      'email': user.email,
      'displayName': user.displayName,
      'bio': '',
      'timestamp': DateTime.now(),
    });
  }

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
                    hintText: 'Enter your Email',
                    hintStyle: kHintTextStyle,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 30.0,
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
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 30.0,
          ),

          // SizedBox(
          //   height: 20,
          // ),
        ],
      ),
    );
  }

  Widget _buildForgotPasswordBtn() {
    return Container(
      alignment: Alignment.centerRight,
      child: FlatButton(
        onPressed: () => print('Forgot Password Button Pressed'),
        padding: EdgeInsets.only(right: 0.0),
        child: Text(
          'Forgot Password?',
          style: kLabelStyle,
        ),
      ),
    );
  }

  Widget _buildRememberMeCheckbox() {
    return Container(
      height: 20.0,
      child: Row(
        children: <Widget>[
          Theme(
            data: ThemeData(unselectedWidgetColor: Colors.white),
            child: Checkbox(
              value: _rememberMe,
              checkColor: Colors.green,
              activeColor: Colors.white,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value;
                });
              },
            ),
          ),
          Text(
            'Remember me',
            style: kLabelStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildLoginBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: _isLoading
          ? CircularProgressIndicator()
          : RaisedButton(
              elevation: 5.0,
              onPressed:
                  // _submit,
                  () {
                // FirebaseAuth.instance
                //     .signInWithEmailAndPassword(
                //         email: _emailController.text,
                //         password: _passwordController.text)
                //     .then((user) {
                //   Navigator.of(context)
                //       .pushReplacementNamed(InstaScreen.routeName);
                //   print('Signed IN!');
                //   FirebaseAuth.instance.currentUser().then((curUser) {
                //     print(curUser.email);
                //     print(curUser.uid);
                //   });
                // }).catchError((e) {
                //   print(e);
                // });

                Provider.of<CurrentUser>(context).signInUsingFirebase(_emailController.text, _passwordController.text, context);
              },
              // googleSign.signIn();

              padding: EdgeInsets.all(15.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              color: Colors.white,
              child: Text(
                _authMode == AuthMode.Login ? 'Login' : 'Sign Up',
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

  Widget _buildSignInWithText() {
    return Column(
      children: <Widget>[
        Text(
          '- OR -',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 20.0),
        Text(
          'Sign in with',
          style: kLabelStyle,
        ),
      ],
    );
  }

  Widget _buildSocialBtn(Function onTap, AssetImage logo) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60.0,
        width: 60.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 6.0,
            ),
          ],
          image: DecorationImage(
            image: logo,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialBtnRow() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _buildSocialBtn(
            () {
              print('Login with Facebook');
            },
            AssetImage(
              'assets/images/facebook.jpg',
            ),
          ),
          _buildSocialBtn(
            () => googleSign.signIn(),
            AssetImage(
              'assets/images/google.jpg',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignupOrLoginBtn() {
    return GestureDetector(
      onTap: () {
        print('Sign Up Button Pressed');
        // switches auth mode
        // _switchAuthMode();

        Navigator.of(context).pushReplacementNamed(CreateAccount.routeName);
      },
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text:
                  '${_authMode == AuthMode.Login ? 'Don\'t have an Account?' : 'Already have an Account?'} ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'}',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   // brightness: Brightness.light,
      // ),
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
                        'Sign In',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'OpenSans',
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 30.0),
                      _buildEmailTF(),
                      SizedBox(
                        height: 30.0,
                      ),
                      //_buildPasswordTF(),
                      _buildForgotPasswordBtn(),
                      _buildRememberMeCheckbox(),
                      _buildLoginBtn(),
                      //used to switch auth mode, now in SignupOrLoginBtn()
                      //_buildFlatBtn(),

                      /*** disabled for now  */

                      // _buildSignInWithText(),
                      // _buildSocialBtnRow(),
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
