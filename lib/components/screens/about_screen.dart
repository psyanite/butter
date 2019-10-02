import 'dart:io';

import 'package:butter/components/screens/privacy_screen.dart';
import 'package:butter/components/screens/terms_screen.dart';
import 'package:butter/presentation/components.dart';
import 'package:butter/presentation/theme.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:butter/components/common/store_banner.dart';


class AboutScreen extends StatelessWidget {

  AboutScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView(padding: EdgeInsets.zero, children: <Widget>[
          _appBar(),
          _title(),
          ListTile(
            title: Text('Contact Us', style: TextStyle(fontSize: 22.0)),
            onTap: () => launch('mailto:burntoastfix@gmail.com?body=Hi there,\n\n\n'),
          ),
          ListTile(
            title: Text('Report an Issue', style: TextStyle(fontSize: 22.0)),
            onTap: () => _reportAnIssue(),
          ),
          ListTile(
            title: Text('Terms of Use', style: TextStyle(fontSize: 22.0)),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TermsScreen())),
          ),
          ListTile(
            title: Text('Privacy Policy', style: TextStyle(fontSize: 22.0)),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PrivacyScreen())),
          ),
        ]),
      ),
    );
  }

  Widget _appBar() {
    return Stack(
      alignment: Alignment.bottomLeft,
      children: <Widget>[
        StoreBanner(),
        Container(height: 60.0, child: BackArrow(color: Colors.white)),
      ],
    );
  }

  Widget _title() {
    return Padding(
      padding: EdgeInsets.only(left: 15.0, top: 30.0, bottom: 10.0),
      child: Text('About', style: Burnt.display4),
    );
  }

  _reportAnIssue() async {
    var info;
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var data = await deviceInfo.androidInfo;
        info = """
          platform: android
          type: ${data.isPhysicalDevice ? 'physical' : 'non-physical'}
          brand: ${data.brand}
          manufacturer: ${data.manufacturer}
          hardware: ${data.hardware}
          model: ${data.model}
          device: ${data.device}
          version: ${data.version.baseOS}-${data.version.release}-${data.version.sdkInt}-${data.version.securityPatch}
        """;
      } else if (Platform.isIOS) {
        var data = await deviceInfo.iosInfo;
        info = """
          platform: android
          type: ${data.isPhysicalDevice ? 'physical' : 'non-physical'}
          name: ${data.name}
          systemName: ${data.systemName}
          systemVersion: ${data.systemVersion}
          model: ${data.model}
        """;
      } else {
        info = 'error-could-not-determine-platform';
      }
    } on PlatformException {
      info = 'platform-exception-could-not-get-device-info';
    }
    launch('mailto:burntoastfix@gmail.com?body=Hi there,\n\n\n<insert-your-query-here>\n\n\n\n\n\nDiagnostics\n\n$info');
  }
}
