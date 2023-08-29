import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_homework/network/user_item.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListException extends Equatable implements Exception {
  final String message;

  const ListException(this.message);

  @override
  List<Object?> get props => [message];
}

class ListModel extends ChangeNotifier{
  var isLoading = false;
  var users = <UserItem>[];

  Future loadUsers() async {
    isLoading = true;
    notifyListeners();
    final Dio dio = GetIt.I<Dio>();
    final SharedPreferences sharedPreferences = GetIt.I<SharedPreferences>();



    try{
      final String? loginToken = sharedPreferences.getString('loginAccessToken');
      dio.options.headers['Authorization'] = 'Bearer $loginToken';

      final response = await dio.get('/users');
      final List<dynamic> responseData = response.data as List<dynamic>;

      users = responseData.map((item) => UserItem(item['name'], item['avatarUrl'])).cast<UserItem>().toList();

      isLoading = false;
      notifyListeners();
    }on DioError catch(e){
      isLoading = false;
      throw ListException(e.response?.data['message']);
    }


  }

  void removeToken() {
    final SharedPreferences sharedPreferences = GetIt.I<SharedPreferences>();

    sharedPreferences.remove('loginAccessToken');
  }
}