import 'package:dev_releases/src/helper/global_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';

class ProgressDialogWidget{
  ProgressDialog pr;
  ProgressDialog init(BuildContext context){
    pr = new ProgressDialog(context);
    pr.style(
    message: 'Search...',
    borderRadius: 10.0,
    backgroundColor: Colors.white,
    progressWidget: buildRiveLoadingCircle(),
    elevation: 10.0,
    insetAnimCurve: Curves.easeInOut,
    progress: 0.0,
    maxProgress: 100.0,
    progressTextStyle: TextStyle(
    color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
    messageTextStyle: TextStyle(
    color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600)
    );
    return pr;
  }
}