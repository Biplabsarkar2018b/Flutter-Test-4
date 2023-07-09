import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:test4/pages/home_page.dart';
import 'package:test4/providers/auth_provider.dart';
import 'package:test4/widgets/loading_view.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);

    switch (authProvider.status) {
      case Status.authenticateError:
        Fluttertoast.showToast(msg: "Sign In Fail...");
        break;

      case Status.authenticateCanceled:
        Fluttertoast.showToast(msg: "Sign In Canceled...");
        break;

      case Status.authenticated:
        Fluttertoast.showToast(msg: "Sign In Success");
        break;
      default:
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Login Page"),
      ),
      body: Stack(
        children: [
          //a text button----------------------
          Center(
            child: TextButton(
              onPressed: () async {
                authProvider.handleSignIn().then(
                  (isSuccess) {
                    if (isSuccess) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePage(),
                        ),
                      );
                    }
                  },
                ).catchError(
                  (error, stackTrace) {
                    Fluttertoast.showToast(
                      msg: error.toString(),
                    );
                    authProvider.handleExceptions();
                  },
                );
              },
              child: Text('Sign In With Google'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed))
                      return Color(0xffdd4b39).withOpacity(0.8);
                    return Color(0xffdd4b39);
                  },
                ),
                splashFactory: NoSplash.splashFactory,
                padding: MaterialStateProperty.all<EdgeInsets>(
                  EdgeInsets.fromLTRB(30, 15, 30, 15),
                ),
              ),
            ),
          ),
          Positioned(
            child: authProvider.status == Status.authenticating
                ? LoadingView()
                : SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
