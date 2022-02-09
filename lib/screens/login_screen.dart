import 'package:flutter/material.dart';
import 'package:health/components/app_container.dart';

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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: const [
                        SizedBox(height: kToolbarHeight),
                        SizedBox(height: 20.0),
                      ],
                    ),
                    Column(
                      children: [
                        // OnFormSubmissionBuilder(
                        //   listenTo: signUpForm,
                        //   onSubmitting: () => SizedBox(
                        //     width: 200,
                        //     child: ElevatedButton(
                        //       onPressed: null,
                        //       child: Row(
                        //           mainAxisAlignment:
                        //               MainAxisAlignment.spaceBetween,
                        //           children: [
                        //             const CircularProgressIndicator(),
                        //             Text(_i18n.next)
                        //           ]),
                        //     ),
                        //   ),
                        //   child: ElevatedButton(
                        //       child: Text(_i18n.next),
                        //       onPressed: () {
                        //         signUpForm.submit();
                        //       }),
                        // ),
                        // DotsIndicator(
                        //   dotsCount: 5,
                        //   position: 0,
                        //   decorator: DotsDecorator(
                        //     activeColor:
                        //         Theme.of(context).colorScheme.onSurface,
                        //     color: Theme.of(context).colorScheme.onSecondary,
                        //     spacing: const EdgeInsets.all(10.0),
                        //     activeSize: const Size(10.0, 10.0),
                        //   ),
                        // ),
                      ],
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
