import 'package:flutter/material.dart';
import 'package:simple_waktu_solat/constants.dart';
import 'package:simple_waktu_solat/screens/solattime/components/body.dart';

class Solat_Time extends StatelessWidget {
  const Solat_Time({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      backgroundColor: kPrimaryColor,
      body: Body(),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      centerTitle: false,
      title: Text('Simple Waktu Solat'),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.info),
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Center(
                        child: Image.asset(
                      'assets/launcher/icon.png',
                      fit: BoxFit.cover,
                      width: 40,
                      height: 40,
                    )),
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            "Simple Waktu Solat v1.0",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: kPrimaryColor,
                                fontWeight: FontWeight.w800),
                          ),
                        )
                      ],
                    ),
                    backgroundColor: Color.fromARGB(220, 255, 255, 255),
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(15)),
                    actions: [
                      FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("Close"))
                    ],
                  );
                });
          },
        ),
      ],
    );
  }
}
