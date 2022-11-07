import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:training_app/widgets/group_card.dart';

class Excersises extends StatefulWidget {
  const Excersises({Key? key}) : super(key: key);

  @override
  State<Excersises> createState() => _ExcersisesState();
}

class _ExcersisesState extends State<Excersises> {
  final List<String> gropus = [
    'Back',
    'Chest',
    'Legs',
    'Shoulders',
    'Core',
    'Arms'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          stops: [0.0, 1.0],
          tileMode: TileMode.clamp,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.secondary,
            Theme.of(context).colorScheme.tertiary,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 25),
            child: Text('Exercises',
                style: GoogleFonts.roboto(
                    color: Theme.of(context).secondaryHeaderColor,
                    fontSize: 30)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.center,
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: gropus.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3 / 2,
                    crossAxisSpacing: MediaQuery.of(context).size.width * 0.05,
                    mainAxisSpacing: MediaQuery.of(context).size.height * 0.02),
                itemBuilder: (context, index) {
                  return MuscleGroupCard(gropus[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
