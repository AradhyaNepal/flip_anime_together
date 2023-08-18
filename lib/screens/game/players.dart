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
      indexPressed: _bestFirstMove(),
    );
  }

  void _performMoveTwo(Memory moveOneResult) {
    //Denotes index of the boardItems
    int bestMoveToPerform=_bestSecondMove(moveOneResult.value);
    if (bestMoveToPerform == -1) {
      bestMoveToPerform=_bestFirstMove();
    }
    boardController.value=PerformActionEvent(indexPressed: bestMoveToPerform);
  }

  int _bestSecondMove(String previousValue){
    var answerFromMemory =-1;
    for(int i=0;i<_computerMemory.length-1;i++){//Todo: Not the last verify. Why? Does this work?
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

  ///First from the memory check that whether there are any same two value stored in the memory
  ///Then tries to click a item which are not known to the computer, to explore the unknown.
  ///If computer knows all items location then randomly pick an items.
  int _bestFirstMove(){
    var answer=-1;
    //Way 1: Find whether both answer for specific card is saved in memory.
    // On no both element found go to Way 2
    final redundantMoveFromMemory=_findIndexFromRedundancy();
    if(redundantMoveFromMemory!=null)return redundantMoveFromMemory;
    //Way 2: Find a card index which is not saved in memory, to explore new unknown and to expand computer memory
    //On all availableIndex already saved in memory, go to Way 3
    for(int i=0;i<availableIndex.length;i++){
      if(_computerMemory.indexWhere((element) => element.index==availableIndex[i])==-1){
        answer=availableIndex[i];
        break;
      }
    }
    //Way 3: Randomly pick any available index
    if(answer==-1){
      answer=availableIndex[_random.nextInt(availableIndex.length)];
    }
    return answer;
  }


  int? _findIndexFromRedundancy() {
    List<Memory> uniqueElements = [];
    for(var item in _computerMemory){
      if(uniqueElements.indexWhere((element) => element.value==item.value)!=-1){
        return item.index;
      }else{
        uniqueElements.add(item);
      }
    }
    return null;
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
