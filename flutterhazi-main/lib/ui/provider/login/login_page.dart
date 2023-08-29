import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_homework/ui/provider/login/login_model.dart';
import 'package:validators/validators.dart';

class LoginPageProvider extends StatefulWidget {
  const LoginPageProvider({super.key});

  @override
  State<LoginPageProvider> createState() => _LoginPageProviderState();
}

class _LoginPageProviderState extends State<LoginPageProvider> {
  LoginModel loginModel = LoginModel();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String? _emailErrorText;
  String? _passwordErrorText;
  bool _stayLoggedIn = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => _initializePage());
  }

  //TODO: Try auto-login on model
  void _initializePage() async {
    bool response = await loginModel.tryAutoLogin();
    if(response){
      Navigator.pushReplacementNamed(context, '/list');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Page'),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  errorText: _emailErrorText,
                ),
                enabled: !loginModel.isLoading,
                onChanged: (_) => setState(() => _emailErrorText = null)),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                errorText: _passwordErrorText,
              ),
              enabled: !loginModel.isLoading,
              onChanged: (_) => setState(() => _passwordErrorText = null),
              obscureText: true,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _stayLoggedIn,
                  onChanged: loginModel.isLoading
                      ? null
                      : (value) {
                          setState(() {
                            _stayLoggedIn = value!;
                          });
                        },
                ),
                Text('Remember me'),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: loginModel.isLoading ? null : _login,
              child: Text('Log in'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateEmail(String value) {
    bool valid = false;
    setState(() {
      if (value.isEmpty) {
        _emailErrorText = 'Email is required';
      } else if (!isEmail(value)) {
        _emailErrorText = 'Invalid email format';
      } else {
        _emailErrorText = null;
        valid = true;
      }
    });
    return valid;
  }

  bool _validatePassword(String value) {
    bool valid = false;
    setState(() {
      if (value.isEmpty) {
        _passwordErrorText = 'Password is required';
      } else if (value.length < 6) {
        _passwordErrorText = 'Password must be at least 6 characters long';
      } else {
        _passwordErrorText = null;
        valid = true;
      }
    });
    return valid;
  }

  void _login() async {
    String email = _emailController.text;
    String password = _passwordController.text;
    bool emailValid = _validateEmail(email);
    bool passwValid = _validatePassword(password);
    if (emailValid && passwValid) {
      try {
        await loginModel.login(email, password, _stayLoggedIn);
        Navigator.pushReplacementNamed(context, '/list');
      } catch (e) {
        if (e is LoginException) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message)),
          );
        }

      }

    }
    setState(() {});
  }


}
