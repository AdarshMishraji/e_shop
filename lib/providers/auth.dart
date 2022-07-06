import 'dart:async';
import 'dart:convert';

import 'package:e_shop/models/httpExpection.dart';
import 'package:e_shop/network/endpoints.dart';
import 'package:e_shop/network/index.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  Timer? _authTimer;

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  bool get isUserAuthenticated {
    return token != null;
  }

  String? get userId {
    return _userId;
  }

  Future _authenticate(String email, String password,
      {bool isLogin = false}) async {
    try {
      final Map<String, dynamic> response = await Http.post(
          Http.authBaseURL,
          '${isLogin ? Endpoints.login.url : Endpoints.signup.url}${Http.API_KEY}',
          json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true
          })).then((res) => json.decode(res.body));
      if (response['error'] != null) {
        throw HttpException(response['error']['message']);
      } else {
        _token = response['idToken'];
        _userId = response['localId'];
        _expiryDate = DateTime.now()
            .add(Duration(seconds: int.parse(response['expiresIn'])));
        _autoLogout();
        notifyListeners();
        (await SharedPreferences.getInstance()).setString(
            'userData',
            json.encode({
              'userId': _userId,
              'token': _token,
              'expiryDate': _expiryDate!.toIso8601String()
            }));
      }
    } on HttpException catch (e) {
      final String errorString = e.toString();
      String errorMessage = '';
      if (errorString.contains('EMAIL_EXISTS')) {
        errorMessage = 'This email already in use.';
      } else if (errorString.contains('WEAK_PASSWORD')) {
        errorMessage = 'Password is too weak.';
      } else if (errorString.contains('INVALID_EMAIL')) {
        errorMessage = 'This is an invalid email. ';
      } else if (errorString.contains('OPERATION_NOT_ALLOWED')) {
        errorMessage = 'Auth not allowed.';
      } else if (errorString.contains('TOO_MANY_ATTEMPTS_TRY_LATER')) {
        errorMessage = 'Too many attempt.';
      } else if (errorString.contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'This may be not a valid email address, or not exists.';
      } else if (errorString.contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password.';
      } else if (errorString.contains('USER_DISABLED')) {
        errorMessage = 'You have been disabled for authentication.';
      } else {
        errorMessage = 'Authenticated Failed';
      }
      throw HttpException(errorMessage);
    } catch (e) {
      print(e);
      const String errorMessage =
          'Could not authenticated you. Please try again later.';
      throw const HttpException(errorMessage);
    }
  }

  Future signup(String email, String password) async {
    return _authenticate(email, password);
  }

  Future login(String email, String password) async {
    return _authenticate(email, password, isLogin: true);
  }

  void logout() {
    _expiryDate = null;
    _token = null;
    _userId = null;
    SharedPreferences.getInstance().then((res) => res.clear());

    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    notifyListeners();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    _authTimer = Timer(
        Duration(seconds: _expiryDate!.difference(DateTime.now()).inSeconds),
        logout);
  }

  Future tryAutoLogin() async {
    final userDataString = (await SharedPreferences.getInstance()).getString(
      'userData',
    );
    if (userDataString != null) {
      final userData = json.decode(userDataString) as Map<String, dynamic>;
      final expiryDate = DateTime.parse(userData['expiryDate']);
      if (expiryDate.isBefore(DateTime.now())) {
        return false;
      } else {
        _token = userData['token'];
        _userId = userData['userId'];
        _expiryDate = expiryDate;
        print(true);
        notifyListeners();
        _autoLogout();
        return true;
      }
    } else {
      return false;
    }
  }
}
