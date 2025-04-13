part of 'dropdown_widget.dart';

class DropdownData<T> {
  T? value;
  String? validation;

  DropdownData({this.value, this.validation});
}

class DropdownController<V, T extends DropdownData<V>>
    extends ValueNotifier<T> {
  DropdownController({required T value}) : super(value);

  void setError(String validation) {
    value.validation = validation;
    notifyListeners();
  }

  void resetValidaiton() {
    value.validation = null;
    notifyListeners();
  }

  void setData(V? data) {
    if (data != value.value) {
      value.value = data;
      resetValidaiton();
    }
  }

  V? get data => value.value;
}
