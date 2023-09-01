import 'dart:convert';
import 'package:email_mobile_application/constants/strings.dart';
import 'package:email_mobile_application/local_db/local_db.dart';
import 'package:email_mobile_application/models/email.dart';
import 'package:email_mobile_application/models/email_tab.dart';
import 'package:email_mobile_application/views/email_send_screen/email_send_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';

import 'widgets/email_widget.dart';

class EmailListScreen extends StatefulWidget {
  const EmailListScreen({super.key});

  @override
  State<EmailListScreen> createState() => _EmailListScreenState();
}

class _EmailListScreenState extends State<EmailListScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  List<EmailTab> tabs = [
    EmailTab("Inbox", Icons.inbox_outlined),
    EmailTab("Sent", Icons.send_outlined),
    EmailTab("Star", Icons.star_border),
  ];

  @override
  void initState() {
    if (LocalDB.email == null) {
      getAuthenticationTokenAndStoreEmail();
    } else {
      fetchEmails(0);
    }
    tabController = TabController(length: tabs.length, vsync: this);
    tabController.addListener(() {
      fetchEmails(tabController.index);
    });
    super.initState();
  }

  String convertExpiry(timestampInSeconds) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
        timestampInSeconds * 1000,
        isUtc: true);
    return dateTime.toIso8601String();
  }

  getAuthenticationTokenAndStoreEmail() async {
    GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: [
        'https://www.googleapis.com/auth/gmail.modify',
        'https://www.googleapis.com/auth/gmail.settings.basic',
      ],
    );
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final credentials = await googleSignIn.currentUser!.authentication;
        final url = Uri.parse(
            'https://identitytoolkit.googleapis.com/v1/accounts:signInWithIdp?key=$FIREBASE_API');

        final response = await post(url,
            headers: {'Content-type': 'application/json'},
            body: jsonEncode({
              'postBody':
                  'id_token=${credentials.idToken}&providerId=google.com',
              'requestUri': 'http://localhost',
              'returnIdpCredential': true,
              'returnSecureToken': true
            }));
        if (response.statusCode != 200) {
          throw 'Refresh token request failed: ${response.statusCode}';
        }

        final data = Map<String, dynamic>.of(jsonDecode(response.body));

        var payload = {
          "access_token": credentials.accessToken,
          "client_id": CLIENT_ID,
          "client_secret": CLIENT_SECRET,
          "refresh_token": data['refreshToken'],
          "token_expiry": convertExpiry(jsonDecode(data['rawUserInfo'])['exp']),
          "token_uri": "https://oauth2.googleapis.com/token",
          "user_agent": null,
          "revoke_uri": "https://oauth2.googleapis.com/revoke",
          "id_token": null,
          "id_token_jwt": null,
          "token_response": {
            "access_token": credentials.accessToken,
            "expires_in": data['expiresIn'],
            "scope":
                "https://www.googleapis.com/auth/gmail.modify https://www.googleapis.com/auth/gmail.settings.basic",
            "token_type": "Bearer"
          },
          "scopes": [
            "https://www.googleapis.com/auth/gmail.settings.basic",
            "https://www.googleapis.com/auth/gmail.modify"
          ],
          "token_info_uri": "https://oauth2.googleapis.com/tokeninfo",
          "invalid": false,
          "_class": "OAuth2Credentials",
          "_module": "oauth2client.client"
        };

        final authResponse = await post(
            Uri.parse('http://10.0.2.2:8000/authenticate'),
            headers: {'Content-type': 'application/json'},
            body: jsonEncode({
              "email": googleSignIn.currentUser!.email,
              "gmail_payload": payload
            }));

        if (authResponse.statusCode == 200) {
          LocalDB.setEmail(googleSignIn.currentUser!.email);
          LocalDB.setName(googleSignIn.currentUser!.displayName ?? "");
          LocalDB.setPhoto(googleSignIn.currentUser!.photoUrl ?? "");
          fetchEmails(0);
        } else {
          throw Exception("Authenticate endpoint not working!");
        }
      }
    } catch (error) {
      print('Error signing in: $error');
    }
  }

  fetchEmails(int reqType) async {
    final response = await post(Uri.parse('http://10.0.2.2:8000/get-emails'),
        headers: {'Content-type': 'application/json'},
        body: jsonEncode({"email": LocalDB.email, "req_type": reqType}));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body)['data'];
      emails = data.map((e) => Email.fromJson(e)).toList();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const EmailSendScreen()));
        },
        child: const Icon(Icons.edit),
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(82),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              TabBar(
                controller: tabController,
                tabs: List.generate(
                  tabs.length,
                  (index) => Tab(
                    height: 50,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(tabs[index].iconData),
                        const SizedBox(
                          height: 2,
                        ),
                        Text(tabs[index].text),
                        const SizedBox(
                          height: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      body: ListView.separated(
          itemBuilder: (context, index) => EmailWidget(email: emails[index]),
          separatorBuilder: (context, index) => Divider(
                thickness: 0.3,
                indent: MediaQuery.of(context).size.width * 0.1,
                endIndent: MediaQuery.of(context).size.width * 0.1,
              ),
          itemCount: emails.length),
    );
  }
}
