import 'package:flutter/material.dart';
import 'package:health/screens/sign_up_screen.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

final loginForm = RM.injectForm(submit: () async {
  await new Future.delayed(const Duration(seconds: 5));
});

final username = RM.injectTextEditing(validators: [
  (value) {
    if (value!.length < 5) {
      return "This username needs to be atleast 5 characters";
    }

    return null;
  }
]);

goToLogin() {
  Navigator.of(RM.context!).push(MaterialPageRoute(builder: (context) {
    return const SignUp();
  }));
}

final password = RM.injectTextEditing();
