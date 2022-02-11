import 'package:flutter/material.dart';
import 'package:health/components/app_container.dart';
import 'package:health/screens/login_model.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../components/app_constraints.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: AppContainer(
          child: SingleChildScrollView(
            primary: true,
            child: Center(
              child: AppConstraintsContainer(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: kToolbarHeight),
                    OnFormBuilder(
                      listenTo: loginForm,
                      builder: () {
                        return Column(
                          children: [
                            Text("Login To Your Account"),
                            TextFormField(
                              controller: username.controller,
                              focusNode: username.focusNode,
                              decoration: InputDecoration(
                                label: Text("Username"),
                                errorText: username.error,
                              ),
                            ),
                            TextFormField(
                              controller: password.controller,
                              focusNode: password.focusNode,
                              obscureText: true,
                              decoration: InputDecoration(
                                label: Text("Password"),
                                errorText: password.error,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    OnFormSubmissionBuilder(
                      listenTo: loginForm,
                      onSubmitting: () => SizedBox(
                        width: 200,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CircularProgressIndicator(),
                              Text("Logging In..")
                            ]),
                      ),
                      child: ElevatedButton(
                          child: Text("Login"),
                          onPressed: () {
                            loginForm.submit();
                          }),
                    ),
                    ElevatedButton(
                        child: Text("Sign Up"),
                        onPressed: () {
                          goToLogin();
                        }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
