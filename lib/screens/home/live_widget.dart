import 'package:flutter/material.dart';

class LiveWidget extends StatefulWidget {
  @override
  _LiveWidgetState createState() => _LiveWidgetState();
}

class _LiveWidgetState extends State<LiveWidget> {
  double opacity = 1.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //changeOpacity();
  }
  changeOpacity() {
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        opacity = opacity == 0.0 ? 1.0 : 0.0;
        changeOpacity();
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Card(
        elevation: 0,
        color: Colors.red,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AnimatedOpacity(
                  opacity: opacity,
                  duration: Duration(seconds: 1),
                  child:  ClipOval(
                    child: Container(
                      color: Colors.white,
                      height: 7,
                      width: 7,
                    ),
                  ),
                ),
                SizedBox(width: 7),
                Text(
                  "LIVE",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
