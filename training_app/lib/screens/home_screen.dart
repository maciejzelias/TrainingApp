import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:training_app/screens/training_Screen.dart';
import 'package:training_app/widgets/excersises.dart';
import 'package:training_app/widgets/home_widget.dart' show HomeWidget;
import 'package:training_app/widgets/measures.dart';
import '../widgets/settings.dart';
import 'package:draggable_fab/draggable_fab.dart' show DraggableFab;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static bool _isWorkout = false;
  late TrainingScreen trainingScreen;
  List<dynamic> ex = [];
  List isolates = [];
  String title = 'title';

  final List<Widget> pages = [
    HomeWidget(_isWorkout),
    Excersises(),
    Measures(),
    ProfileSettings(),
  ];
  int _currentIndex = 0;

  void _changePage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<trainingScreenNotifier>(
        builder: ((context, value, child) {
          return Scaffold(
            floatingActionButton: value.getIsWorkoutStatus()
                ? DraggableFab(
                    child: FloatingActionButton(
                        child: Icon(color: Colors.black, Icons.timer),
                        backgroundColor: Colors.white,
                        onPressed: () {
                          showModalBottomSheet<dynamic>(
                              isScrollControlled: true,
                              context: context,
                              builder: (BuildContext context) {
                                value.setNewContext(context);
                                return value.getTrainingScreen();
                              });
                        }),
                  )
                : null,
            backgroundColor: Theme.of(context).colorScheme.secondary,
            bottomNavigationBar: SalomonBottomBar(
              currentIndex: _currentIndex,
              selectedItemColor: Theme.of(context).secondaryHeaderColor,
              items: [
                SalomonBottomBarItem(
                  icon: Icon(Icons.home),
                  title: Text('Home'),
                ),
                SalomonBottomBarItem(
                  icon: Icon(Icons.fitness_center),
                  title: Text('Exercises'),
                ),
                SalomonBottomBarItem(
                  icon: Icon(FontAwesomeIcons.ruler),
                  title: Text('Measurement'),
                ),
                SalomonBottomBarItem(
                  icon: Icon(Icons.person),
                  title: Text('Profile'),
                ),
              ],
              onTap: _changePage,
            ),
            body: Stack(children: <Widget>[
              pages[_currentIndex],
            ]),
          );
        }),
      ),
    );
  }
}

class trainingScreenNotifier extends ChangeNotifier {
  var _trainingScreen;
  late bool _isWorkout;
  late BuildContext _context;

  trainingScreenNotifier() {
    _isWorkout = false;
  }

  getTrainingScreen() => _trainingScreen;

  getIsWorkoutStatus() => _isWorkout;

  setTrainingScreen(TrainingScreen trainingScreen, BuildContext context) {
    _context = context;
    _trainingScreen = trainingScreen;
    _isWorkout = true;
    notifyListeners();
  }

  setNewContext(BuildContext context) {
    _context = context;
  }

  removeTrainingScreen() {
    Navigator.of(_context).pop();
    _trainingScreen = null;
    _isWorkout = false;
    notifyListeners();
  }
}
