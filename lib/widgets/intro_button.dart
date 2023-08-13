import 'package:flutter/material.dart';

class IntroButton extends StatelessWidget {
  double height;
  double width;
  String title;
  VoidCallback? onTap;

  IntroButton({Key? key, this.onTap, required this.title,required this.height,required this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
            color: const Color(0xff1C208F),
            borderRadius: BorderRadius.circular(16)),
        child:  Center(
            child: Text(title,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500))),
      ),
    );
  }
}
