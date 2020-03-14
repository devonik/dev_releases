import 'package:flutter/cupertino.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';

Widget buildRiveLoadingCircle(){
  return Center(
    child: FlareActor("assets/animations/CircularProgressIndicator.flr",
      animation: "Loading",
      color: Colors.blueGrey
    )
  );
}