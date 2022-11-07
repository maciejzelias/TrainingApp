import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class ExerciseDetailsScreen extends StatefulWidget {
  late List<Map<String, dynamic>> list;
  late String name;
  ExerciseDetailsScreen(this.list, this.name);

  @override
  State<ExerciseDetailsScreen> createState() =>
      _ExerciseDetailsScreenState(list, name);
}

class _ExerciseDetailsScreenState extends State<ExerciseDetailsScreen> {
  List<String> time = ['Year', 'Month', 'Day', 'Hour', 'Minute'];
  String _actualTime = 'Month';
  late List<Map<String, dynamic>> performings;
  late String name;
  List<Map<String, dynamic>> chartData = [];
  late List<charts.Series<String, dynamic>> series;
  _ExerciseDetailsScreenState(this.performings, this.name) {
    for (int i = 0; i < performings.length; i++) {
      performings[i].addAll({'timestamp': performings[i]['date']});
    }
    fetchData();
  }

  void fetchData() {
    chartData.clear();
    DateTime today = new DateTime.now();
    bool _isValid = false;
    performings.sort((a, b) => (a['date']).compareTo(b['date']));
    for (int i = 0; i < performings.length; i++) {
      int volume = 0;
      for (int j = 0; j < performings[i]['numberOfSets']; j++) {
        volume += performings[i]['lastTraining'][(j + 1).toString()][0] *
            performings[i]['lastTraining'][(j + 1).toString()][0] as int;
      }
      DateTime date =
          DateTime.fromMillisecondsSinceEpoch(performings[i]['timestamp']);
      switch (_actualTime) {
        case 'Year':
          if (date.year == today.year) {
            performings[i]['date'] = date.month;
            _isValid = true;
          }
          break;
        case 'Month':
          if (date.month == today.month) {
            performings[i]['date'] = date.day;
            _isValid = true;
          }
          break;
        case 'Day':
          if (date.day == today.day) {
            performings[i]['date'] = date.hour;
            _isValid = true;
          }
          break;
        case 'Hour':
          if (date.hour == today.hour) {
            performings[i]['date'] = date.minute;
            _isValid = true;
          }
          break;
        case 'Minute':
          if (date.minute == today.minute) {
            performings[i]['date'] = date.second;
            _isValid = true;
          }
          break;

        default:
        break;
      }
      chartData.add({'volume': volume, 'date': performings[i]['date']});
    }
  }

  @override
  Widget build(BuildContext context) {
    List<charts.Series<Map, num>> series = [
      charts.Series(
        id: "history",
        data: chartData,
        domainFn: (Map<dynamic, dynamic> series, _) => series['date'],
        measureFn: (Map<dynamic, dynamic> series, _) => series['volume'],
      )
    ];
    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(name),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.info)),
                Tab(icon: Icon(FontAwesomeIcons.chartLine)),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              Container(
                child: Text('name : ' + name),
              ),
              Container(
                child: chartData.isEmpty
                    ? Center(
                        child: Text('You have not performed this exercise yet'),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 200,
                            child: charts.LineChart(
                              animationDuration: Duration(milliseconds: 500),
                              series,
                              animate: true,
                            ),
                          ),
                          DropdownButton(
                              value: _actualTime,
                              items: time.map((String time) {
                                return DropdownMenuItem<String>(
                                  child: Text(time),
                                  value: time,
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _actualTime = newValue!;
                                  fetchData();
                                });
                              })
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
