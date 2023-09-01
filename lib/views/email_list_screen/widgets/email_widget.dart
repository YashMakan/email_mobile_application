import 'package:email_mobile_application/models/email.dart';
import 'package:email_mobile_application/views/email_send_screen/email_send_screen.dart';
import 'package:flutter/material.dart';
import 'package:get_time_ago/get_time_ago.dart';

class EmailWidget extends StatelessWidget {
  final Email email;

  const EmailWidget({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    int emailBoyLimiter = 70;
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EmailSendScreen(email: email)));
      },
      child: SizedBox(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundImage: email.profileImage != null
                    ? NetworkImage(email.profileImage!)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(email.subject!,
                        style: Theme.of(context).textTheme.bodyMedium),
                    Text(
                      email.body == null
                          ? ""
                          : "${email.body!.substring(0, email.body!.length > emailBoyLimiter ? emailBoyLimiter : email.body!.length)}${email.body!.length > emailBoyLimiter ? '...' : ''}",
                      maxLines: 3,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(GetTimeAgo.parse(email.dateTime!))
            ],
          ),
        ),
      ),
    );
  }
}
