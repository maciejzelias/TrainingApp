import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:training_app/widgets/historyTrainingDialog.dart';

class CustomCalendar extends StatefulWidget {
  const CustomCalendar({Key? key}) : super(key: key);

  @override
  State<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  List<Map<String, dynamic>> actualDay = [];
  bool _isLoading = false;
  List result = [];
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime? _focusedDay;
  late final String id;
  Map trains = {};
  _CustomCalendarState() {
    _isLoading = false;
    this.id = FirebaseAuth.instance.currentUser!.uid;
    dupa();
  }

  void fetchData(DocumentReference reference, Map<String, dynamic> map) async {
    late QuerySnapshot exercises;
    exercises = await reference.collection('exercises').get();
    List ex = exercises.docs.map((doc) => doc.data()).toList();
    map.addAll({'exercises': ex});
    trains.addAll({map['date']: map});
    setState(() {
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    List<Map<String, dynamic>> result = [];
    trains.forEach((key, value) {
      if (day.year == DateTime.fromMillisecondsSinceEpoch(key).year &&
          day.month == DateTime.fromMillisecondsSinceEpoch(key).month &&
          day.day == DateTime.fromMillisecondsSinceEpoch(key).day)
        result.add(value);
    });
    return result;
  }

  void dupa() async {
    Stream<QuerySnapshot<Map<String, dynamic>>> stream = await FirebaseFirestore
        .instance
        .collection('users/$id/history')
        .where('title', isNull: false)
        .snapshots();
    // QuerySnapshot<Map<String, dynamic>> x = await FirebaseFirestore.instance
    //     .collection('users/$id/history')
    //     .where('title', isNull: false)
    //     .get();
    stream.forEach((element) {
      // List lista = x.docs.toList();
      // for (int i = 0; i < lista.length; i++) {
      var documents = element.docs;
      documents.sort(
        (a, b) => (a['date'].compareTo(b['date'])),
      );
      for (int i = 0; i < documents.length; i++) {
        var reference = documents[i].reference;
        Map<String, dynamic> dokumentMap =
            documents[i].data();
        fetchData(reference, dokumentMap);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : TableCalendar(
            calendarBuilders: CalendarBuilders(),
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              actualDay = _getEventsForDay(selectedDay);
              if (!actualDay.isEmpty)
                showDialog(
                    context: context,
                    builder: (context) => HistoryTrainingDialog(actualDay));
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            pageJumpingEnabled: true,
            eventLoader: (day) {
              return _getEventsForDay(day);
            },
            calendarFormat: _calendarFormat,
            headerStyle: HeaderStyle(formatButtonVisible: false),
            calendarStyle: CalendarStyle(
                todayDecoration:
                    BoxDecoration(color: Theme.of(context).primaryColor),
                weekendDecoration: BoxDecoration(color: Colors.grey),
                holidayDecoration: BoxDecoration(color: Colors.grey),
                defaultDecoration: BoxDecoration(color: Colors.white)),
            startingDayOfWeek: StartingDayOfWeek.monday,
            weekendDays: [6, 7],
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: DateTime.now(),
            daysOfWeekVisible: true,
          );
  }
}
