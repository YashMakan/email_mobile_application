import 'dart:convert';

import 'package:email_mobile_application/local_db/local_db.dart';
import 'package:email_mobile_application/models/email.dart';
import 'package:flutter/material.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:http/http.dart';

class EmailSendScreen extends StatefulWidget {
  final Email? email;

  const EmailSendScreen({super.key, this.email});

  @override
  State<EmailSendScreen> createState() => _EmailSendScreenState();
}

class _EmailSendScreenState extends State<EmailSendScreen> {
  bool get isSendEmail => widget.email == null;

  final TextEditingController email = TextEditingController();
  final TextEditingController subject = TextEditingController();
  final TextEditingController body = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: !isSendEmail
          ? null
          : ElevatedButton(
              onPressed: () async {
                final response =
                    await put(Uri.parse('http://10.0.2.2:8000/send-email'),
                        headers: {'Content-type': 'application/json'},
                        body: jsonEncode({
                          "email": LocalDB.email,
                          "to_email": "${email.text}@gmail.com",
                          "subject": subject.text,
                          "body": body.text
                        }));
                if (response.statusCode == 200) {
                  print("EMAIL SENT!");
                } else {
                  throw Exception("Unable to send the email at the moment!");
                }
              },
              child: const Text("Send"),
            ),
      appBar: AppBar(
        title: isSendEmail ? const Text('Draft') : null,
        actions: isSendEmail
            ? []
            : [
                IconButton(
                    onPressed: () {
                      int currentEmailIndex = emails.indexWhere(
                          (element) => element.id == widget.email!.id);
                      if (currentEmailIndex != 0) {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EmailSendScreen(
                                      email: emails[currentEmailIndex - 1],
                                    )));
                      }
                    },
                    icon: const Icon(Icons.chevron_left)),
                IconButton(
                    onPressed: () {
                      int currentEmailIndex = emails.indexWhere(
                          (element) => element.id == widget.email!.id);
                      if (currentEmailIndex != emails.length - 1) {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EmailSendScreen(
                                      email: emails[currentEmailIndex + 1],
                                    )));
                      }
                    },
                    icon: const Icon(Icons.chevron_right))
              ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              onTap: () {},
              leading: isSendEmail
                  ? null
                  : CircleAvatar(
                      backgroundImage: widget.email?.profileImage != null
                          ? NetworkImage(widget.email!.profileImage!)
                          : const NetworkImage(""),
                    ),
              title: isSendEmail
                  ? Row(
                      children: [
                        Flexible(
                          child: TextField(
                            controller: email,
                            decoration: const InputDecoration(
                              hintText: "email address",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const Text('@gmail.com')
                      ],
                    )
                  : Text(widget.email!.userName!),
              trailing: isSendEmail
                  ? null
                  : Text(GetTimeAgo.parse(widget.email?.dateTime != null
                      ? widget.email!.dateTime!
                      : DateTime.now())),
            ),
            if (!isSendEmail) ...[
              const SizedBox(height: 16),
              Text(
                widget.email != null ? widget.email!.subject! : "",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    widget.email?.body != null ? widget.email!.body! : "",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ] else ...[
              TextField(
                controller: subject,
                decoration: const InputDecoration(
                  hintText: "Subject",
                  border: InputBorder.none,
                ),
              ),
              Expanded(
                child: Material(
                  borderRadius: BorderRadius.circular(10),
                  child: TextField(
                    controller: body,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Description",
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
