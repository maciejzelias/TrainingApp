import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryTrainingCard extends StatelessWidget {
  @required
  Map<String, dynamic> training;

  HistoryTrainingCard(this.training);

  String matchText(Map exercise, indeks) {
    String result = "";
    switch (exercise['type']) {
      case 'weight':
        result = (exercise['lastTraining'][(indeks + 1).toString()][0]
                .toString() +
            ' kg x ' +
            exercise['lastTraining'][(indeks + 1).toString()][1].toString());
        break;
      case 'bodyweight+':
        result = result = ('+ ' +
            exercise['lastTraining'][(indeks + 1).toString()][0].toString() +
            'kg x ' +
            exercise['lastTraining'][(indeks + 1).toString()][1].toString());
        break;
      case 'time':
        int seconds = exercise['lastTraining'][(indeks + 1).toString()][0];
        Duration duration = Duration(seconds: seconds);
        result =
            "${duration.inHours}:${duration.inMinutes.remainder(60)}:${(duration.inSeconds.remainder(60))}";
        break;
      case 'bodyweight':
        result =
            exercise['lastTraining'][(indeks + 1).toString()][0].toString() +
                ' reps';
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(training['title']),
            Text(DateFormat('kk:mm')
                .format(DateTime.fromMillisecondsSinceEpoch(training['date']))),
            Text(training['duration'].toString())
          ],
        ),
        ListView.builder(
            itemCount: training['exercises'].length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: ((context, index) {
              return Card(
                child: Column(
                  children: [
                    Text(training['exercises'][index]['name']),
                    ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: training['exercises'][index]['numberOfSets'],
                        itemBuilder: ((context, indeks) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text((indeks + 1).toString()),
                              Text(matchText(
                                  training['exercises'][index], indeks))
                            ],
                          );
                        })),
                  ],
                ),
              );
            }))
      ]),
    );
  }
}
