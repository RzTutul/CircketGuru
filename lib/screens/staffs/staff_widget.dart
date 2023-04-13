import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:app/config/colors.dart';
import 'package:app/model/staff.dart';
import 'package:app/screens/staffs/staff_detail.dart';

class StaffWidget extends StatelessWidget {
  Staff staff;

  StaffWidget({this.staff});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Route route = MaterialPageRoute(builder: (context) => StaffDetail(staff: staff));
        Navigator.push(context, route);
      },
      child: Container(
        margin: const EdgeInsets.all(7),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Theme.of(context).primaryColor,
            boxShadow: [BoxShadow(
                color: Colors.black54.withOpacity(0.2),
                offset: Offset(0,0),
                blurRadius: 5
            )]
        ),
        child: Stack(
          children: [


            Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                top: 0,
                child:  ClipRRect(
                    borderRadius: BorderRadius.only(topLeft:Radius.circular(5),topRight: Radius.circular(5)),
                    child: CachedNetworkImage(imageUrl:staff.image, fit: BoxFit.cover)
                )
            ),



            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child:
              Container(
                  height: 50,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5),bottomRight: Radius.circular(5)),
                    color: Theme.of(context).accentColor,
                  )
              ),
            ),
            Positioned(
                bottom: 0,
                left: 5,
                right: 0,
                child:
                Container(
                  height: 50,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(staff.name.toUpperCase(),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13
                        ),
                      ),
                      Text(staff.status,
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11
                        ),
                      )
                    ],
                  ),
                )
            ),
          ],
        ),
      ),
    );
  }
}
