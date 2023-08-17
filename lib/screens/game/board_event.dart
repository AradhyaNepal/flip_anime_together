import 'package:flip_anime_together/screens/game/players.dart';

abstract class BoardEvent {}

class InitialEvent extends BoardEvent {}

class NewGameEvent extends BoardEvent {}

class WonGameEvent extends BoardEvent {}

class ActionPerformedEvent extends BoardEvent {}

class PerformActionEvent extends BoardEvent {
  int indexPressed;
  Function(Memory memory)? onPerformed;

  PerformActionEvent({
    required this.indexPressed,
    this.onPerformed,
  });
}
