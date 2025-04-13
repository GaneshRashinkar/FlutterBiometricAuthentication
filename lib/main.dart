import 'package:authentication_demo/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final LocalAuthentication auth;
  bool _supportState = false;
  @override
  void initState() {
    super.initState();
    auth = LocalAuthentication();
    auth.isDeviceSupported().then(
      (bool isSupported) {
        setState(() {
          _supportState = isSupported;
        });

        if (isSupported) {
          var availableBio = _getAvailableBiometrics();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Biometric Authentication")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_supportState)
            const Text("This Device is supported for biometric auth")
          else
            const Text("This Device is not supported"),
          SizedBox(
            height: 20,
            width: double.infinity,
          ),
          ElevatedButton(
            onPressed: _authenticate,
            child: const Text("Authenticate"),
          ),
        ],
      ),
    );
  }

  Future<void> _getAvailableBiometrics() async {
    List<BiometricType> availableBiometrics =
        await auth.getAvailableBiometrics();
    print("List of available biometrics: $availableBiometrics");
    if (availableBiometrics.isNotEmpty) {
      _authenticate();
    } else {
      Fluttertoast.showToast(msg: "Biometrics Not Enrolled");
      SystemNavigator.pop();
    }
    if (!mounted) {
      return;
    }
  }

  Future<void> _authenticate() async {
    try {
      bool authenticated = await auth.authenticate(
          localizedReason: 'Authenticate to enter in the app',
          options: AuthenticationOptions(
              stickyAuth: true,
              biometricOnly: true,
              sensitiveTransaction: true));

      if (authenticated) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => WelcomePage()));
      } else {
        Fluttertoast.showToast(msg: "Authentication Failed");
      }
    } on PlatformException catch (e) {
      print(e);
    }
  }
}
