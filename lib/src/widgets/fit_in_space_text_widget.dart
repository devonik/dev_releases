//Allow the text size to shrink to fit in the space
import 'package:flutter/cupertino.dart';

class FitInSpaceTextWidget extends StatelessWidget {
  const FitInSpaceTextWidget(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: AlignmentDirectional.centerStart,
      child: Text(text),
    );
  }
}