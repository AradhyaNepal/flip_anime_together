enum GameplayType {
  offline,
  online,
}

abstract class Players {
  String name;
  GameplayType gameplayType;

  Players({
    required this.name,
    required this.gameplayType,
  });
}

class Computer extends Players {
  //Todo: UseCase
  //Computer have memory
  //Computer makes moves from the memory
  //Computer sometimes makes mistake despite its memory, yet rare
  //Computer expertise is either noob, intermediate, or pro
  //More expertise means more memory and less mistake
  Computer({
    required super.name,
    required super.gameplayType,
  });
}

class RealPerson extends Players {
  RealPerson({
    required super.name,
    required super.gameplayType,
  });
}
