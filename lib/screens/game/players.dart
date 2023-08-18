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


///Computer have its memory, which observes all the moves made in the game.
///The memory keeps expanding as the game continues. With more memories,
///computer can easily figure out which Card have which item.
///
///Computer makes moves from its memory, if its memory have no match then
///it keeps on expanding its memory by picking new cards to explore the unknown.
///
///Todo:Computer sometimes gets very emotional and makes some obvious mistake despite its memory.
///
///Computer expertise is either noob, intermediate, or pro.
///Todo: More expertise might means that there are less chance of it forgetting its few memories
///More expertise means more memory and less mistakes.
//Todo: Proper encapsulation
class Computer extends Players {
  final Random _random=Random();
  ComputerExpertise computerExpertise;
  final List<int> availableIndex;
  final BoardController boardController;
  final List<String> boardImages;



  ///Todo: Make sure same index are not redundant
  final List<Memory> _computerMemory = [];

  void observerTheCard(Memory memory) {
    _computerMemory.add(memory);
  }

  void clearTheMemory(){
    _computerMemory.clear();
  }

  void performMove(Future<void> Function(int index) performAction) async{
    //Performing Move One
    final moveOneIndex=_bestFirstMove();
    await performAction(moveOneIndex);//This needs to await, then only perform next move
    //Performing Move Two
    performAction(_bestSecondMove(boardImages[moveOneIndex]));
  }



  int _bestSecondMove(String previousValue){
    var sendMoveIndex =-1;
    for(int i=0;i<_computerMemory.length-1;i++){//Todo: Not the last verify. Why? Does this work?
      if(_computerMemory[i].value == previousValue){
        if(availableIndex.contains(_computerMemory[i].index)){
          sendMoveIndex=i;
          break;
        }else{
          Future.delayed(Duration.zero,(){//Todo: Does this logic work, if yes then you learned today something new
            availableIndex.removeAt(i);
          });
        }
      }
    }
    if (sendMoveIndex == -1) {
      sendMoveIndex=_bestFirstMove();
    }
    return sendMoveIndex;
  }

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
    required this.boardImages,
  });
}

class RealPerson extends Players {
  RealPerson({
    required super.name,
    required super.gameplayType,
  });
}
