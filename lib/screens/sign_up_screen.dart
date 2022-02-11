import 'package:flutter/material.dart';
import 'package:health/components/app_container.dart';
import 'package:health/screens/sign_up_model.dart';

import '../components/app_constraints.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
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
                    Text("Sign Up"),
                    TextFormField(
                      controller: firstName.controller,
                      focusNode: firstName.focusNode,
                      decoration: InputDecoration(
                        label: Text("First Name"),
                        errorText: firstName.error,
                      ),
                    ),
                    TextFormField(
                      controller: lastName.controller,
                      focusNode: lastName.focusNode,
                      obscureText: true,
                      decoration: InputDecoration(
                        label: Text("Last Name"),
                        errorText: lastName.error,
                      ),
                    ),
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
