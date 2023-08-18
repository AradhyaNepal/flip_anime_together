//Write a program, which returns
//redundant value from the list

List<T> findRedundantElements<T>(List<T> list) {
  Set<T> uniqueElements = <T>{};
  Set<T> redundantElements = <T>{};

  for (T element in list) {
    if (uniqueElements.contains(element)) {
      redundantElements.add(element);
    } else {
      uniqueElements.add(element);
    }
  }

  return redundantElements.toList();
}

void main(){
  print(findRedundantElements([1,2,3,3,3]));
  print(findRedundantElements([1,1,2,4,5,3,3]));
  print(findRedundantElements([1,2,3,4,5]));
}

