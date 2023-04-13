import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child:  SpinKitFoldingCube(
        size: 35,
        duration: Duration(seconds: 2),
        itemBuilder: (BuildContext context, int index) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color: index.isEven ? Theme.of(context).accentColor : Theme.of(context).accentColor,
            ),
          );
        },
      ),
    );
  }
}
