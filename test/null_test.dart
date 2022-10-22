void main() {
  MyObj? blabla;

  print(blabla?.id);
}

class MyObj {
  final int id;

  MyObj(this.id);
}
