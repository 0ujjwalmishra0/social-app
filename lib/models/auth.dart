import 'dart:convert';
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/Exception.dart';


class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;
  bool isAuthGoogle=false;
  
  bool get isAuth {
    // if token is not null we are authenticated
    return token != null;
  }

 

  String get token {
    if (_expiryDate != null &&
        _token != null &&
        _expiryDate.isAfter(DateTime.now())) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> signin(
    String email,
    String password,
  ) async {
    return _authenticate(email, password, 'signInWithPassword');
  }
 
  Future<void> _authenticate(
      //we login here
      String email,
      String password,
      String urlSegment) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyCOgpyi8uathSLNJjEVM03eSpKBUmOV17c';
    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
       print(json.decode(response.body));

      /** output-
     * {error: {code: 400, message: INVALID_PASSWORD, 
     * errors: [{message: INVALID_PASSWORD, domain: global, reason: invalid}]}}
     * 
     */

      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      // we are getting idToken from firebase.// check official docs
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      // for expiryDate we only get back expiresIn- no. of sec,in which it expires
      // expiryDate = currentTime + expiresIn
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData['expiresIn']),
        ),
      );



      _autoLogOut();





      // call notifyListerner to update UI
      notifyListeners();
      /*** shared_preferences is on devixce storage
       *   it involves working with futures hence use async in function
       */
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
          'userId': userId,
          'expiryDate': _expiryDate.toIso8601String(),
        },
      );
      //storing data on device
      prefs.setString('userData', userData);

    } catch (error) {
      throw error;
    }
  }
  // tryAutoLogin returns boolean bcz it tells if we were successful
  //  to auto log the user
  Future<bool> tryAutoLogin() async{
    final prefs = await SharedPreferences.getInstance();
    if(!prefs.containsKey('userData')){
      return false;
    }
    final extractedUserData = json.decode(prefs.getString('userData')) as Map<String,Object>;
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);
    
    if(expiryDate.isBefore(DateTime.now())){
      return false;
    }
    // if we make past if check then, we have a valid token
    
    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogOut();
    return true;


  }

  Future <void> logout() async{
    //call this method from app_drawer.dart
    _token = null;
    _userId = null;
    _expiryDate = null;
    if(_authTimer!= null){
      _authTimer.cancel();
    _authTimer = null;
    }
    
    //print('logged out!');
    notifyListeners();
    //when logging out clear all data in shared preferences to avoid logging in immediately
    final prefs= await SharedPreferences.getInstance();
    prefs.clear();
    //prefs.remove('userData');
    /**prefs.remove- remove particular data
     * prefs.clear - remove all data of app
     */  
  }

  void _autoLogOut() {
    //set a timer using async library
    //check and cancel any existing authTimer
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    Timer(Duration(seconds: timeToExpiry), logout);
    print('Automatically logged out!');
  }


}

