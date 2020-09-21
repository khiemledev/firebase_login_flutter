import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _message = 'You are not sign in';

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  FirebaseAuth _auth;
  GoogleSignIn _googleSignIn;

  Future<User> _handleSignIn() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final User user = (await _auth.signInWithCredential(credential)).user;
    print("signed in " + user.displayName);
    setState(() {
      // User đã login thì hiển thị đã login
      _message = "You are signed in";
    });
    return user;
  }

  Future _handleSignOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    setState(() {
      // Hiển thị thông báo đã log out
      _message = "You are not sign out";
    });
  }

  Future _checkLogin() async {
    // Khi mở app lên thì check xem user đã login chưa
    final User user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _message = "You are signed in";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Login'),
      ),
      body: FutureBuilder(
          future: _initialization,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.done) {
              _auth = FirebaseAuth.instance;
              _googleSignIn = GoogleSignIn();
              _checkLogin();
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(_message),
                    OutlineButton(
                      onPressed: () {
                        _handleSignIn();
                      },
                      child: Text('Login'),
                    ),
                    OutlineButton(
                      onPressed: () {
                        _handleSignOut();
                      },
                      child: Text('Logout'),
                    ),
                  ],
                ),
              );
            }

            return CircularProgressIndicator();
          }),
    );
  }
}
