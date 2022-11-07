import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:training_app/screens/certain_group.dart'
    show CertainGroupScreen;

class MuscleGroupCard extends StatelessWidget {
  final String text;

  const MuscleGroupCard(this.text);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: (() {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>  CertainGroupScreen(text.toLowerCase()),
            ),
          );
        }),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white54,
              boxShadow: [
                BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6.0,
                    offset: Offset(0, 2))
              ]),
          child: Center(
            child: Text(
              text,
              // style: Theme.of(context).textTheme.bodyLarge,
              style: GoogleFonts.roboto(
                  color: Theme.of(context).secondaryHeaderColor, fontSize: 15),
            ),
          ),
        ));
  }
}
