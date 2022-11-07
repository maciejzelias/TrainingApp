import 'dart:async';
import 'dart:isolate';

class Training {
  // ignore: unused_field
  late final Timer _timer;
  Duration _duration = Duration();
  late SendPort sendPort;
  late List exercises;
  late String title;
  Training(this.exercises, this.sendPort) {
    _timer = Timer.periodic(Duration(seconds: 1), (_) => addTime());
  }
  Training.second(this.exercises, this.title) {
    _timer = Timer.periodic(Duration(seconds: 1), (_) => addSecond());
  }

  void addSecond() {
    final addSeconds = 1;
    final seconds = this._duration.inSeconds + addSeconds;

    this._duration = Duration(seconds: seconds);
    print('Duration from class : $_duration');
  }

  void addTime() {
    final addSeconds = 1;
    final seconds = this._duration.inSeconds + addSeconds;

    this._duration = Duration(seconds: seconds);
    print('Duration from class : $_duration');
    // sendPort.send(duration);
  }
}
