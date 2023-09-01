class Email {
  final String? profileImage;
  final String? userName;
  final String? subject;
  final String? body;
  final DateTime? dateTime;
  final String? email;
  final String id;

  Email(
      {this.profileImage,
      required this.id,
      this.userName,
      this.email,
      this.subject,
      this.body,
      this.dateTime});

  factory Email.fromJson(Map json) {
    DateTime parseDateTimeWithOffset(String dateTimeString) {
      List<String> parts = dateTimeString.split('+');
      String dtStr = parts[0]; // "2023-08-31 23:50:14"
      String offsetStr = parts[1]; // "05:30"
      DateTime dt = DateTime.parse(dtStr);
      List<String> offsetParts = offsetStr.split(':');
      int offsetHours = int.parse(offsetParts[0]);
      int offsetMinutes = int.parse(offsetParts[1]);
      int totalOffsetSeconds = (offsetHours * 3600) + (offsetMinutes * 60);

      Duration offset = Duration(seconds: totalOffsetSeconds);
      DateTime parsedDateTime = dt.subtract(offset);
      return parsedDateTime;
    }
    return Email(
      id: json['id'],
      body: json['body'],
      userName: json['name'],
      subject: json['subject'],
      dateTime: parseDateTimeWithOffset(json['datetime']),
      email: json['email'],
      profileImage: json['image']);
  }
}

List<Email> emails = [];
