import 'dart:async';
import 'dart:math';

import 'package:flip_anime_together/screens/game/board_controller.dart';
import 'package:flip_anime_together/screens/game/board_event.dart';

enum GameplayType {
  offline,
  online,
}

enum ComputerExpertise {
  noob,
  intermediate,
  pro,
}

abstract class Players {
  String name;
  GameplayType gameplayType;

  Players({
    required this.name,
    required this.gameplayType,
  });
}

class Memory {
  int index;
  String value;

  Memory({
    required this.index,
    required this.value,
  });
}

class Computer extends Players {
  Random _random=Random();
  ComputerExpertise computerExpertise;
  final List<int> availableIndex;
  final BoardController boardController;

  //Todo: UseCase
  //Computer have memory
  //Computer makes moves from the memory
  //Computer sometimes makes mistake despite its memory, yet rare
  //Computer expertise is either noob, intermediate, or pro
  //More expertise means more memory and less mistake

  final List<Memory> _computerMemory = [];

  void observerTheCard(Memory memory) {
    _computerMemory.add(memory);
  }

  void performMove() {
    boardController.value = PerformActionEvent(
      onPerformed: _performMoveTwo,
      indexPressed: 1,//Todo: Calculate the best
    );
  }

  void _performMoveTwo(Memory moveOneResult) {
    int bestMoveIndexToPerform=_getMoveFromMemory(moveOneResult.value);
    if (bestMoveIndexToPerform == -1) {
      bestMoveIndexToPerform=availableIndex[_random.nextInt(availableIndex.length)];//Todo: Something that's not available to the memory to expand the memory
    }
    boardController.value=PerformActionEvent(indexPressed: bestMoveIndexToPerform);
  }

  int _getMoveFromMemory(String previousValue){
    var answerFromMemory =-1;
    for(int i=0;i<_computerMemory.length-1;i++){//Todo: Not the last verify
      if(_computerMemory[i].value == previousValue){
        if(availableIndex.contains(_computerMemory[i].index)){
          answerFromMemory=i;
          break;
        }else{
          Future.delayed(Duration.zero,(){//Todo: Does this logic work, if yes then you learned today something new
            availableIndex.removeAt(i);
          });
        }
      }
    }
    return answerFromMemory;
  }

  Computer({
    required super.name,
    required super.gameplayType,
    required this.computerExpertise,
    required this.availableIndex,
    required this.boardController,
  });
}

class RealPerson extends Players {
  RealPerson({
    required super.name,
    required super.gameplayType,
  });
}
