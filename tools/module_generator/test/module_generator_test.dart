import 'package:flutter_test/flutter_test.dart';
import 'package:module_generator/common/common_function.dart';

void main() {
  test('test common function', () async {
    expect(formatClassName('inputName'), 'InputName');
    expect(formatClassName('input_Name'), 'InputName');
    expect(formatClassName('input_name'), 'InputName');

    expect(formatModuleName('inputName'), 'input_name');
    expect(formatModuleName('input_Name'), 'input_name');
    expect(formatModuleName('input_name'), 'input_name');
    expect(formatModuleName('inputName'), 'input_name');
  });
}
