import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginException extends Equatable implements Exception {
  final String message;

  const LoginException(this.message);

  @override
  List<Object?> get props => [message];
}

class LoginModel extends ChangeNotifier {
  var isLoading = false;

  Future login(String email, String password, bool rememberMe) async {
    isLoading = true;
    final Dio dio = GetIt.I<Dio>();
    final SharedPreferences sharedPreferences = GetIt.I<SharedPreferences>();

    final Map<String, dynamic> data = {
      'email': email,
      'password': password,
    };

    try{
      Response response = await dio.post('/login',data:data);
      Map<String, dynamic> responseData = response.data;
      if(rememberMe){
        sharedPreferences.setString('loginAccessToken', responseData['token']);
      }
    } on DioError catch(e){
      isLoading = false;
      throw LoginException(e.response?.data['message']);
    }
    isLoading = false;
  }

  Future<bool> tryAutoLogin() async {
    final SharedPreferences sharedPreferences = GetIt.I<SharedPreferences>();

    if(!sharedPreferences.containsKey('loginAccessToken')){
      return false;
    }
    String? token = sharedPreferences.getString('loginAccessToken');
    if(token == null){
      return false;
    }
    return true;
  }

}
