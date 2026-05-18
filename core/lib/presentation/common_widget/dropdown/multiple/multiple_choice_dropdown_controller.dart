part of 'multiple_choice_dropdown_widget.dart';

class MultipleChoiceDropdownData<T> {
  List<T> value;
  String? validation;

  MultipleChoiceDropdownData({this.value = const [], this.validation});
}

class MultipleChoiceDropdownController<V,
    T extends MultipleChoiceDropdownData<V>> extends ValueNotifier<T> {
  MultipleChoiceDropdownController({required T value}) : super(value);

  void setError(String validation) {
    value.validation = validation;
    notifyListeners();
  }

  void resetValidaiton() {
    value.validation = null;
    notifyListeners();
  }

  void setData(List<V> data) {
    if (data != value.value) {
      value.value = data;
      resetValidaiton();
    }
  }

  List<V> get data => value.value;
}
