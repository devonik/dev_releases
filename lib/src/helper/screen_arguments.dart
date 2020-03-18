// You can pass any object to the arguments parameter.
// In this example, create a class that contains a customizable
// title and message.
class TechScreenArguments {
  final List<String> favTechIdsStringList;
  final bool isScreenCalledByNavigator;
  final String snackBarText;

  TechScreenArguments(this.favTechIdsStringList, this.isScreenCalledByNavigator, this.snackBarText);
}