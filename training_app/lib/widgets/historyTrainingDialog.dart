import 'package:flutter/material.dart';
import 'package:training_app/widgets/historyTrainingCard.dart';
import 'package:intl/intl.dart';

class HistoryTrainingDialog extends StatelessWidget {
  @required
  List<Map<String, dynamic>> trainings;

  HistoryTrainingDialog(this.trainings);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
                style: TextStyle(fontSize: 20),
                DateFormat('yyyy-MM-dd').format(
                    DateTime.fromMillisecondsSinceEpoch(trainings[0]['date']))),
          ),
          Expanded(
            child: ListView.builder(
                shrinkWrap: true,
                itemBuilder: ((context, index) {
                  return HistoryTrainingCard(trainings[index]);
                }),
                itemCount: trainings.length),
          ),
        ],
      ),
    );
  }
}
