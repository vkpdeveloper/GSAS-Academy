import 'package:flutter/material.dart';

class OptionWidget extends StatelessWidget {
  final Function onPressed;
  final String label;
  final ImageProvider<dynamic> optionImage;
  final Widget profileImage;

  const OptionWidget({Key key, this.onPressed, this.label, this.optionImage, this.profileImage})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: (MediaQuery.of(context).size.width / 2) - 40,
        height: MediaQuery.of(context).size.height / 4,
        padding: EdgeInsets.all(20.0),
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  blurRadius: 14,
                  color: Colors.black12.withOpacity(0.1),
                  offset: Offset(10, 10)),
              BoxShadow(
                  blurRadius: 14,
                  color: Colors.black12.withOpacity(0.1),
                  offset: Offset(-10, -10))
            ],
            borderRadius: BorderRadius.circular(15.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            profileImage ?? CircleAvatar(
              radius: 45.0,
              backgroundColor: Colors.white,
              backgroundImage: optionImage,
            ),
            SizedBox(
              height: 10.0,
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black),
            )
          ],
        ),
      ),
    );
  }
}
