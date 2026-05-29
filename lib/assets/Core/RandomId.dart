import 'dart:math';

class Randomid {

  String generateId(String firstName, String f_Name){
    final random = Random();

    final initialFirst = firstName[0].toUpperCase();
    final initailLast = f_Name[0].toUpperCase();

    final randomNumber = 100000 + random.nextInt(900000);

    return "$initialFirst$initailLast-$randomNumber";
  }
}