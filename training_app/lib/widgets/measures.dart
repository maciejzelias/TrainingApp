import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Measures extends StatefulWidget {
  const Measures({Key? key}) : super(key: key);

  @override
  State<Measures> createState() => _MeasuresState();
}

class _MeasuresState extends State<Measures> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  List<String> time = ['Year', 'Month', 'Day', 'Hour', 'Minute'];
  String _actualTime = 'Month';
  List<String> bodyParts = ['Chest', 'Weight', 'Arm'];
  String _actualPart = 'Weight';
  String _actualToFirebase = 'weight';
  late String id;
  bool _isFirst = true;
  late int _value;
  late QuerySnapshot<Map<String, dynamic>> docs;
  List<Map<String, dynamic>> chartData = [];
  late List<charts.Series<String, dynamic>> series;
  _MeasuresState() {
    _isLoading = true;
    this.id = FirebaseAuth.instance.currentUser!.uid;
    fetchData();
  }

  void addMeasure() async {
    setState(() {
      _isFirst = true;
    });
    FocusScope.of(context).unfocus();
    bool _isValid = await _formKey.currentState!.validate();
    if (_isValid) {
      _formKey.currentState!.save();
      await FirebaseFirestore.instance
          .collection('users/$id/measures/$_actualToFirebase/measures')
          .add(
              {'value': _value, 'date': DateTime.now().millisecondsSinceEpoch});
      if (_actualToFirebase == 'weight')
        await FirebaseFirestore.instance.collection('users').doc(id).set({
          'weight': _value,
        }, SetOptions(merge: true));
      await fetchData();
      setState(() {
        _isFirst = false;
      });
    }
  }

  Future fetchData() async {
    if (_isFirst) {
      if (!_isLoading)
        setState(() {
          _isLoading = true;
        });
      docs = await FirebaseFirestore.instance
          .collection('users/$id/measures/$_actualToFirebase/measures')
          .get();
    }
    chartData.clear();
    if (!docs.docs.isEmpty) {
      final List<QueryDocumentSnapshot<Map<String, dynamic>>> documents =
          docs.docs;
      documents.sort((a, b) => (a['date'].compareTo(b['date'])));
      final List<Map<String, dynamic>> allData =
          docs.docs.map((doc) => doc.data()).toList();
      allData.sort((a, b) => (a['date'].compareTo(b['date'])));
      bool _isValid = false;
      DateTime today = new DateTime.now();
      for (int i = 0; i < allData.length; i++) {
        _isLoading = false;
        int timestamp = allData[i]['date'];
        allData[i].addAll({'timestamp': timestamp, 'id': documents[i].id});
        DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
        switch (_actualTime) {
          case 'Year':
            if (date.year == today.year) {
              allData[i]['date'] = date.month;
              _isValid = true;
            } else
              allData.remove(allData[i]);
            break;
          case 'Month':
            if (date.month == today.month) {
              allData[i]['date'] = date.day;
              _isValid = true;
            } else
              allData.remove(allData[i]);
            break;
          case 'Day':
            if (date.day == today.day) {
              allData[i]['date'] = date.hour;
              _isValid = true;
            } else
              allData.remove(allData[i]);
            break;
          case 'Hour':
            if (date.hour == today.hour) {
              allData[i]['date'] = date.minute;
              _isValid = true;
            } else
              allData.remove(allData[i]);
            break;
          case 'Minute':
            if (date.minute == today.minute) {
              allData[i]['date'] = date.second;
              _isValid = true;
            } else
              allData.remove(allData[i]);
            break;
        }
        if (_isValid) chartData.add(allData[i]);
      }
    } else
      chartData = [];
    if (_isFirst)
      setState(() {
        _isLoading = false;
        _isFirst = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    List<charts.Series<Map, num>> series = [
      charts.Series(
        seriesColor: charts.ColorUtil.fromDartColor(
            Theme.of(context).colorScheme.secondary),
        id: "measures",
        data: chartData,
        domainFn: (Map<dynamic, dynamic> series, _) => series['date'],
        measureFn: (Map<dynamic, dynamic> series, _) => series['value'],
      )
    ];
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
              child: Text('Measures',
                  style: GoogleFonts.roboto(
                      color: Theme.of(context).secondaryHeaderColor,
                      fontSize: 30)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.25,
                alignment: Alignment.center,
                color: Colors.white,
                child: _isLoading
                    ? Center(child: CircularProgressIndicator.adaptive())
                    : chartData.isEmpty
                        ? Container(
                            child: Text('You have no measurements yet'),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Theme.of(context).cardColor,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6.0,
                                    offset: Offset(0, 2))
                              ],
                            ),
                            child: charts.LineChart(
                              animationDuration: Duration(milliseconds: 500),
                              series,
                              animate: true,
                            ),
                          ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DropdownButton(
                    value: _actualPart,
                    dropdownColor: Theme.of(context).colorScheme.secondary,
                    items: bodyParts.map((String group) {
                      return DropdownMenuItem<String>(
                        value: group,
                        child: Text(
                          group,
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _isFirst = true;
                        _actualPart = newValue!;
                        _actualToFirebase = _actualPart.toLowerCase();
                        fetchData();
                      });
                    }),
                DropdownButton(
                    value: _actualTime,
                    dropdownColor: Theme.of(context).colorScheme.secondary,
                    items: time.map((String time) {
                      return DropdownMenuItem<String>(
                        child: Text(
                          time,
                          style: TextStyle(color: Colors.white),
                        ),
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
            Container(
              height: MediaQuery.of(context).size.height * 0.25,
              child: ListView.builder(
                  itemCount: chartData.length,
                  shrinkWrap: true,
                  itemBuilder: ((context, index) {
                    return Card(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text((chartData[index]['date'].toString())),
                          Text(chartData[index]['value'].toString()),
                          IconButton(
                              onPressed: () async {
                                setState(() {
                                  _isFirst = true;
                                });
                                await FirebaseFirestore.instance
                                    .collection(
                                        'users/$id/measures/$_actualToFirebase/measures')
                                    .doc(chartData[index]['id'])
                                    .delete();
                                fetchData();
                              },
                              icon: Icon(Icons.delete))
                        ],
                      ),
                    );
                  })),
            ),
            Center(
              child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) => Dialog(
                              child: Container(
                                  child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('How much you weight today?'),
                                      Form(
                                          key: _formKey,
                                          child: Expanded(
                                            child: TextFormField(
                                              onSaved: ((newValue) {
                                                _value = int.parse(newValue!);
                                              }),
                                              validator: (value) {
                                                // if (int.parse(value!) < 20 ||
                                                //     int.parse(value) > 400)
                                                //   return 'Please enter your real weight';
                                                return null;
                                              },
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: InputDecoration(),
                                            ),
                                          ))
                                    ],
                                  ),
                                  ElevatedButton(
                                      onPressed: () {
                                        addMeasure();
                                        Navigator.pop(context, true);
                                      },
                                      child: Text('Submit data'))
                                ],
                              )),
                            ));
                  },
                  child: Icon(Icons.add)),
            )
          ],
        ));
  }
}
