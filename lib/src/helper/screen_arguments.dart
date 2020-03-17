// You can pass any object to the arguments parameter.
// In this example, create a class that contains a customizable
// title and message.
class TechScreenArguments {
  final List<String> favTechIdsStringList;
  final bool isScreenCalledByNavigator;

  TechScreenArguments(this.favTechIdsStringList, this.isScreenCalledByNavigator);
}