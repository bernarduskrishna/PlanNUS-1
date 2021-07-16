import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:planaholic/elements/MyButtons.dart';
import 'package:planaholic/models/Event.dart';
import 'package:planaholic/services/AuthService.dart';
import 'package:planaholic/services/DbService.dart';
import 'package:planaholic/util/PresetColors.dart';
import 'package:planaholic/util/Validate.dart';
import 'package:ical/serializer.dart' as ICal;

class Settings extends StatefulWidget {
  const Settings({Key key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    final _formKey = GlobalKey<FormState>();

    AuthService _auth = new AuthService();
    DbService _db = new DbService();

    // Text field changes
    // change password:
    String passwordOld = "";
    String password_1 = "";
    String password_2 = "";
    // delete account:
    String passwordDelete_1 = "";
    String passwordDelete_2 = "";

    return Scaffold(
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16, top: 25, right: 16),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.settings,
                    color: PresetColors.blue,
                  ),
                  SizedBox(
                    width: screenWidth * 0.01,
                  ),
                  Text(
                    "Settings",
                    style: TextStyle(
                        fontSize: screenHeight * 0.04,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              SizedBox(
                height: screenHeight * 0.02,
              ),
              Row(
                children: [
                  Icon(
                    Icons.person,
                    color: PresetColors.blue,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    "Account",
                    style: TextStyle(
                        fontSize: screenHeight * 0.038,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Divider(
                height: screenHeight * 0.02,
                thickness: 2,
              ),
              SizedBox(
                height: screenHeight * 0.01,
              ),
              buildSettingOptions(
                  context: context,
                  title: "Change password",
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Change Password"),
                            scrollable: true,
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      TextFormField(
                                        key: ValueKey("enter-old-password"),
                                        decoration: InputDecoration(
                                          icon: Icon(Icons.lock),
                                          hintText: 'Enter old password',
                                          labelText: 'Old Password',
                                          errorMaxLines: 3,
                                        ),
                                        obscureText: true,
                                        onChanged: (value) {
                                          setState(() => passwordOld = value);
                                        },
                                        validator: Validate().validatePassword,
                                      ),
                                      TextFormField(
                                        key: ValueKey("change-new-password"),
                                        decoration: InputDecoration(
                                          icon: Icon(Icons.lock),
                                          hintText: 'Enter new password',
                                          labelText: 'New Password',
                                          errorMaxLines: 3,
                                        ),
                                        validator: Validate().validatePassword,
                                        obscureText: true,
                                        onChanged: (value) {
                                          setState(() => password_1 = value);
                                        },
                                      ),
                                      TextFormField(
                                        key: ValueKey("repeat-new-password"),
                                        decoration: InputDecoration(
                                          icon: Icon(Icons.lock),
                                          hintText: 'Repeat new password',
                                          labelText: 'Repeat New Password',
                                        ),
                                        obscureText: true,
                                        onChanged: (value) {
                                          setState(() => password_2 = value);
                                        },
                                        validator: (value) =>
                                            value != password_1
                                                ? "Passwords do not match"
                                                : null,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                  key: ValueKey(
                                      "confirm-change-password-button"),
                                  onPressed: () async {
                                    if (_formKey.currentState.validate()) {
                                      dynamic result = await _auth
                                          .signInWithEmailAndPassword(
                                              await _db.getEmail(),
                                              passwordOld);

                                      if (result != null) {
                                        _auth
                                            .changePassword(
                                                password: password_1)
                                            .then((_) {
                                          Navigator.pop(context);
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  content: Text(
                                                      "Your password has been changed successfully."),
                                                  actions: [
                                                    TextButton(
                                                      child: Text("Confirm"),
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context),
                                                    ),
                                                  ],
                                                );
                                              });
                                        });
                                      } else {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text(
                                                  "Failed to change password."),
                                              content: Text(
                                                  "Your old password could be incorrect."),
                                              actions: [
                                                TextButton(
                                                  child: Text("Ok"),
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    }
                                  },
                                  child: Text("Confirm")),
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("Cancel")),
                            ],
                          );
                        });
                  }),
              buildSettingOptions(
                  context: context,
                  title: "Delete account",
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(
                              "WARNING",
                              style: TextStyle(
                                color: Colors.red[700],
                              ),
                            ),
                            content: Text(
                              "Are you sure you want to delete your account? All of your user information will be deleted.\n\nThis process cannot be reverted.",
                              style: TextStyle(fontSize: screenHeight * 0.03),
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text("Enter Password"),
                                            scrollable: true,
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Form(
                                                  key: _formKey,
                                                  child: Column(
                                                    children: [
                                                      TextFormField(
                                                        key: ValueKey(
                                                            "delete-password"),
                                                        decoration:
                                                            InputDecoration(
                                                          icon:
                                                              Icon(Icons.lock),
                                                          hintText:
                                                              'Enter your password',
                                                          labelText: 'Password',
                                                          errorMaxLines: 3,
                                                        ),
                                                        validator: Validate()
                                                            .validatePassword,
                                                        obscureText: true,
                                                        onChanged: (value) {
                                                          setState(() =>
                                                              passwordDelete_1 =
                                                                  value);
                                                        },
                                                      ),
                                                      TextFormField(
                                                        key: ValueKey(
                                                            "delete-repeat-password"),
                                                        decoration:
                                                            InputDecoration(
                                                          icon:
                                                              Icon(Icons.lock),
                                                          hintText:
                                                              'Repeat your password',
                                                          labelText:
                                                              'Repeat Password',
                                                        ),
                                                        obscureText: true,
                                                        onChanged: (value) {
                                                          setState(() =>
                                                              passwordDelete_2 =
                                                                  value);
                                                        },
                                                        validator: (value) => value !=
                                                                passwordDelete_1
                                                            ? "Passwords do not match"
                                                            : null,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                  key: ValueKey(
                                                      "confirm-delete-account-button"),
                                                  onPressed: () async {
                                                    print("passwordDelete_1: " +
                                                        passwordDelete_1 +
                                                        "\npasswordDelete_2: " +
                                                        passwordDelete_2);

                                                    if (_formKey.currentState
                                                        .validate()) {
                                                      dynamic result = await _auth
                                                          .signInWithEmailAndPassword(
                                                              await _db
                                                                  .getEmail(),
                                                              passwordDelete_1);

                                                      print(
                                                          "Delete Account Sign In Result:\n" +
                                                              result
                                                                  .toString());

                                                      if (result != null) {
                                                        // delete account here!
                                                        await _db
                                                            .deleteUserData()
                                                            .then((_) async {
                                                          // This line would actually delete user auth! Use with care.
                                                          // await _auth
                                                          //     .deleteUser();

                                                          Navigator.pop(
                                                              context);
                                                          showDialog(
                                                            context: context,
                                                            builder: (context) {
                                                              return AlertDialog(
                                                                title: Text(
                                                                    "Account deleted."),
                                                                content: Text(
                                                                    "Your account has been deleted successfully.\nThank you for using Planaholic!"),
                                                                actions: [
                                                                  TextButton(
                                                                      child: Text(
                                                                          "Confirm"),
                                                                      onPressed: () => Navigator.of(
                                                                              context)
                                                                          .popUntil((route) =>
                                                                              route.isFirst)),
                                                                ],
                                                              );
                                                            },
                                                          );
                                                        });
                                                      } else {
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return AlertDialog(
                                                              title: Text(
                                                                  "Failed to delete account."),
                                                              content: Text(
                                                                  "Your password could be incorrect."),
                                                              actions: [
                                                                TextButton(
                                                                  child: Text(
                                                                      "Ok"),
                                                                  onPressed: () =>
                                                                      Navigator.pop(
                                                                          context),
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      }
                                                    }
                                                  },
                                                  child: Text("Confirm")),
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text("Cancel")),
                                            ],
                                          );
                                        });
                                  },
                                  child: Text("Confirm")),
                              MyButtons.roundedRed(
                                  onPressed: () => Navigator.pop(context),
                                  text: "Cancel",
                                  key: ValueKey("cancel-delete-account")),
                            ],
                          );
                        });
                  }),
              SizedBox(
                height: screenHeight * 0.02,
              ),
              Row(
                children: [
                  Icon(
                    Icons.import_export_outlined,
                    color: PresetColors.blue,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    "Import & Export",
                    style: TextStyle(
                        fontSize: screenHeight * 0.038,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Divider(
                height: screenHeight * 0.02,
                thickness: 2,
              ),
              SizedBox(
                height: screenHeight * 0.01,
              ),
              buildSettingOptions(
                context: context,
                title: "Import ics file",
                onTap: _importICS,
              ),
              buildSettingOptions(
                context: context,
                title: "Export all activities as ics",
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Export all activities"),
                          content: Text(
                              "Do you want to export all of your activities as an .ics file?"),
                          actions: [
                            TextButton(
                                onPressed: () async {
                                  _generateEventIcs(await _db.getAllEvents())
                                      .then((filePath) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content:
                                          Text("Saved .ics file as $filePath."),
                                      backgroundColor:
                                          Colors.black26.withOpacity(0.8),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(
                                                screenHeight * 0.1)),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: screenWidth * 0.08),
                                      margin: EdgeInsets.symmetric(
                                          horizontal: screenWidth * 0.05,
                                          vertical: screenWidth * 0.02),
                                    ));
                                  });
                                },
                                child: Text("Confirm")),
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("Cancel")),
                          ],
                        );
                      });
                },
              ),
              SizedBox(
                height: screenHeight * 0.02,
              ),
              Row(
                children: [
                  Icon(
                    Icons.volume_up_outlined,
                    color: PresetColors.blue,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    "Notifications",
                    style: TextStyle(
                        fontSize: screenHeight * 0.038,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Divider(
                height: screenHeight * 0.02,
                thickness: 2,
              ),
              SizedBox(
                height: screenHeight * 0.01,
              ),
              buildSettingOptions(
                  context: context, title: "[Placeholder]", onTap: () {}),
              SizedBox(
                height: screenHeight * 0.02,
              ),
              Center(
                child: Container(
                  width: screenWidth * 0.7,
                  child: MyButtons.roundedRed(
                    key: ValueKey("sign-out-button"),
                    text: "Sign Out",
                    onPressed: () async {
                      await _auth.signOut();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                ),
              )
            ]),
          ),
        ],
      ),
    );
  }

  GestureDetector buildSettingOptions(
      {@required BuildContext context,
      @required String title,
      @required Function onTap}) {
    double screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: screenHeight * 0.036,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _importICS() async {
    FilePickerResult result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: [
      "ics",
    ]);

    if (result != null) {
      File file = File(result.files.single.path);
      ICalendar icsObj = ICalendar.fromLines(file.readAsLinesSync());
      Map eventMap = icsObj.toJson();
      List data = eventMap["data"];

      // iterate over all events
      for (int i = 2; i < data.length; i++) {
        Map eventData = data[i];

        String dtStart = eventData["dtstart"]["dt"];
        String dtEnd = eventData["dtend"]["dt"];
        String summary = eventData["summary"];

        DateTime startTime = _parseIcsTimeToDateTime(dtStart);
        DateTime endTime = _parseIcsTimeToDateTime(dtEnd);

        Event event = new Event(
          category: "Others",
          // By default. User can edit later.
          description: summary,
          startTime: startTime,
          endTime: endTime,
          completed: false,
          passed: endTime.compareTo(DateTime.now()) == -1 ? true : false,
          difficulty: 5,
        );

        dynamic ref = await DbService().addNewEvent(event); // DocumentReference
        DbService().syncEventId(ref.id);
      }
    } else {
      // User canceled the picker
    }
  }

  DateTime _parseIcsTimeToDateTime(String dt) {
    int year = int.parse(dt.substring(0, 4));
    int month = int.parse(dt.substring(4, 6));
    int day = int.parse(dt.substring(6, 8));
    int hour = int.parse(dt.substring(9, 11));
    int min = int.parse(dt.substring(11, 13));

    return new DateTime(year, month, day, hour, min);
  }

  Future<String> _generateEventIcs(List<Event> events) async {
    ICal.ICalendar cal = ICal.ICalendar();
    events.forEach((event) {
      cal.addElement(ICal.IEvent(
        uid: "bogoplan@gmail.com",
        start: event.startTime,
        end: event.endTime,
        status: ICal.IEventStatus.CONFIRMED,
        description: event.description,
        summary: event.description,
      ));
    });

    String path = (await getExternalStorageDirectory()).path;
    // print(path);

    String filePath =
        "$path/Planaholic_Export_${DateTime.now().toString()}.ics";
    File testFile = new File(filePath);
    testFile.writeAsString(cal.serialize());

    return filePath;
  }
}
