class StaticMethods{
  DateTime _date = DateTime.now();

  String getCurrentDate() {
    return "${_date.day}-${_date.month}-${_date.year}";
  }

}