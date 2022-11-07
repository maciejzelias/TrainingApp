import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/authentication.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({Key? key}) : super(key: key);
  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  Future<void> _launch(Uri url) async {
    await canLaunchUrl(url)
        ? await launchUrl(url)
        : ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Could_not_launch_this_url")));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).primaryColor,
        body: Stack(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height * 0.4,
              width: MediaQuery.of(context).size.width,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.only(
                      bottomLeft: const Radius.circular(90),
                      bottomRight: const Radius.circular(90)),
                  boxShadow: [
                    new BoxShadow(
                        color: Theme.of(context).shadowColor, blurRadius: 15.0)
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 50),
              height: MediaQuery.of(context).size.height * 0.3,
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/dzikbialy1.png"),
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
            Authentication(),
            _buttonsWithUrls()
          ],
        ),
      ),
    );
  }

  Widget _facebookButtonWithUrl() {
    return SizedBox.fromSize(
      size: Size(50, 50),
      child: ClipOval(
        child: Material(
          color: Theme.of(context).colorScheme.secondary,
          child: InkWell(
            splashColor: Theme.of(context).primaryColor,
            onTap: () =>
                _launch(Uri.parse("https://www.facebook.com/warszawskikokss")),
            child: Icon(
              FontAwesomeIcons.facebookSquare,
              color: Theme.of(context).secondaryHeaderColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _instagramButtonWithUrl() {
    return SizedBox.fromSize(
      size: Size(50, 50),
      child: ClipOval(
        child: Material(
          color: Theme.of(context).colorScheme.secondary,
          child: InkWell(
            splashColor: Theme.of(context).primaryColor,
            onTap: () =>
                _launch(Uri.parse("https://www.instagram.com/warszawskikoks/")),
            child: Icon(
              FontAwesomeIcons.instagram,
              color: Theme.of(context).secondaryHeaderColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _pageButtonWithUrl() {
    return SizedBox.fromSize(
      size: Size(50, 50),
      child: ClipOval(
        child: Material(
          color: Theme.of(context).colorScheme.secondary,
          child: InkWell(
            splashColor: Theme.of(context).primaryColor,
            onTap: () => _launch(Uri.parse("https://wkdzik.pl/")),
            child: ImageIcon(
                size: 50,
                AssetImage("assets/dzikbialy.png"),
                color: Theme.of(context).secondaryHeaderColor),
          ),
        ),
      ),
    );
  }

  Widget _buttonsWithUrls() {
    return Container(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _facebookButtonWithUrl(),
              SizedBox(
                width: 50,
              ),
              _instagramButtonWithUrl(),
              SizedBox(
                width: 50,
              ),
              _pageButtonWithUrl(),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          )
        ],
      ),
    );
  }
}
